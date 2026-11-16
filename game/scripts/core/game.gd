extends Node
## Global services, autoloaded as `Game`: the input map, hit-stop, screen fades
## and the debug keys used while building rooms.
##
## Debug keys:
##   F1  black-box view (hide the terrain skin and the art: just the collision)
##   F2  debug overlay (Kleo's state, animation, speed, FPS)
##   F3  slow motion (quarter speed) for judging animation
##   F5  restart the room
##   H   hit Kleo with a heavy blow (tests the knockback; costs a flame)

signal box_view_changed(on: bool)

## Default bindings: keyboard keys, gamepad buttons and mouse buttons, kept
## apart because their codes overlap. Bindings set in the project settings take
## precedence. `spell` is reserved for Kleo's Anima spells (right click).
const KEYS := {
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"jump": [KEY_SPACE, KEY_Z, KEY_K],
	"attack": [KEY_X, KEY_J],
	"spell": [KEY_V, KEY_L],
	"interact": [KEY_E, KEY_C],
}
const PADS := {
	"move_left": [JOY_BUTTON_DPAD_LEFT],
	"move_right": [JOY_BUTTON_DPAD_RIGHT],
	"move_up": [JOY_BUTTON_DPAD_UP],
	"move_down": [JOY_BUTTON_DPAD_DOWN],
	"jump": [JOY_BUTTON_A],
	"attack": [JOY_BUTTON_X],
	"spell": [JOY_BUTTON_B],
	"interact": [JOY_BUTTON_Y],
}
const MOUSE := {
	"attack": [MOUSE_BUTTON_LEFT],
	"spell": [MOUSE_BUTTON_RIGHT],
}

## The door Kleo arrives through in the next room ("" for the room's own start).
var arrival_door := ""
## Things that stay done across rooms: a freed lift, a woken shrine.
var flags := {}
## Tests set this to swap rooms themselves; otherwise the scene is changed.
var room_host := Callable()
var _changing := false

var box_view := false
var slow_motion := false
var debug_overlay := false

## Hit-stop never slows the game this much or this long, however many hits land.
const HITSTOP_SCALE := 0.05
const HITSTOP_MAX := 0.12
var _hitstop_end_us := 0  # real time (µs) the current hit-stop ends; 0 when none
var _fade_layer: CanvasLayer
var _fade_rect: ColorRect
var _debug_label: Label

## Resin, the currency (a stand-in name): beads found in secrets and caches.
## There is no save file yet, so it lasts until F5 (which clears the flags too,
## so every bead comes back).
signal currency_changed(total: int, delta: int)
var currency := 0
var _hud_count: Label
var _hud: Control
var _hud_tween: Tween

# --- The level being played -------------------------------------------------------
## Kleo's health: lantern flames (amber, top left). A hit costs one; a hazard
## costs one and sends her back to the last checkpoint; losing the last sends
## her back with her flames refilled. A checkpoint refills them.
signal health_changed(health: int, max_health: int)
## She is back at the last checkpoint after a fall or a defeat (crates and
## such put themselves back).
signal respawned
var max_health := 3
var health := 3
## The room or level being played (a Room), set by Room._ready.
var level: Node = null
## Where she comes back after a fall: the last checkpoint lit, or the start.
var checkpoint := Vector2.ZERO
var checkpoint_facing := 1
## Resin picked up since the last checkpoint: [[pickup node, value], ...].
## A fall drops it: the beads go back where they hung. A checkpoint banks it.
var _unbanked: Array = []
## Cocoons freed (their flags), and how many the level holds.
var rescued := {}
var level_cocoons: Array[String] = []
## True while she is being sent back (a fall, a defeat): nothing else may hurt her.
var respawning := false
var _flames: HBoxContainer
var _cocoon_row: HBoxContainer
var _flame_tex: Texture2D
var _cocoon_tex: Texture2D
var _banner: Label
var _timer_label: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_input()
	_setup_screen_layers()


# --- Input ------------------------------------------------------------------

func _setup_input() -> void:
	for action in KEYS:
		if not InputMap.has_action(action):
			InputMap.add_action(action, 0.25)
		if not InputMap.action_get_events(action).is_empty():
			continue  # bound in the project settings: keep the user's bindings
		for code in KEYS[action]:
			var key := InputEventKey.new()
			key.physical_keycode = code
			InputMap.action_add_event(action, key)
		for button in PADS[action]:
			var pad := InputEventJoypadButton.new()
			pad.button_index = button
			InputMap.action_add_event(action, pad)
		for button in MOUSE.get(action, []):
			var click := InputEventMouseButton.new()
			click.button_index = button
			InputMap.action_add_event(action, click)
		# The left stick moves too.
		match action:
			"move_left": _add_axis(action, JOY_AXIS_LEFT_X, -1.0)
			"move_right": _add_axis(action, JOY_AXIS_LEFT_X, 1.0)
			"move_up": _add_axis(action, JOY_AXIS_LEFT_Y, -1.0)
			"move_down": _add_axis(action, JOY_AXIS_LEFT_Y, 1.0)


func _add_axis(action: String, axis: JoyAxis, value: float) -> void:
	var m := InputEventJoypadMotion.new()
	m.axis = axis
	m.axis_value = value
	InputMap.action_add_event(action, m)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	match event.physical_keycode:
		KEY_F1:
			box_view = not box_view
			get_tree().call_group("box_view", "set_box_view", box_view)
			box_view_changed.emit(box_view)
		KEY_F2:
			debug_overlay = not debug_overlay
			_debug_label.visible = debug_overlay
		KEY_F3:
			slow_motion = not slow_motion
			if _hitstop_end_us == 0:
				Engine.time_scale = _base_time_scale()
		KEY_F5:
			flags.clear()
			rescued.clear()
			currency = 0
			_unbanked.clear()
			health = max_health
			_hud_count.text = "0"
			_hud.modulate.a = 0.0
			_hitstop_end_us = 0
			Engine.time_scale = _base_time_scale()
			get_tree().reload_current_scene()
		KEY_H:
			for k in get_tree().get_nodes_in_group("player"):
				k.hurt(-k.facing, true)


# --- Hit-stop ------------------------------------------------------------------

## Freeze the action for a moment so a hit lands with weight.
## It ends on the real clock, checked every frame in _process, so it always ends:
## overlapping hits only extend it, and never past HITSTOP_MAX.
func hitstop(seconds: float) -> void:
	seconds = clampf(seconds, 0.0, HITSTOP_MAX)
	if seconds <= 0.0:
		return
	var end := Time.get_ticks_usec() + int(seconds * 1000000.0)
	_hitstop_end_us = max(_hitstop_end_us, end)
	Engine.time_scale = HITSTOP_SCALE


func _base_time_scale() -> float:
	return 0.25 if slow_motion else 1.0


## True while a hit-stop is holding the game.
func in_hitstop() -> bool:
	return _hitstop_end_us > 0


func shake(amount: float) -> void:
	var cam := get_viewport().get_camera_2d()
	if cam and cam.has_method("add_trauma"):
		cam.add_trauma(amount)


# --- Screen fades and the debug overlay ---------------------------------------

func _setup_screen_layers() -> void:
	_fade_layer = CanvasLayer.new()
	_fade_layer.layer = 100
	add_child(_fade_layer)
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0.043, 0.031, 0.071, 0.0)
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_layer.add_child(_fade_rect)
	_debug_label = Label.new()
	_debug_label.position = Vector2(4, 4)
	_debug_label.add_theme_font_size_override("font_size", 8)
	_debug_label.add_theme_color_override("font_color", Color(1, 0.95, 0.8))
	_debug_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	_debug_label.visible = false
	_fade_layer.add_child(_debug_label)
	# The HUD, top left: her flames, then the Resin count under them (hidden
	# until the first bead outside a level). Top right: the level's cocoons.
	var hud_layer := CanvasLayer.new()
	hud_layer.layer = 90
	add_child(hud_layer)
	_flame_tex = load("res://assets/ui/flame.png")
	_cocoon_tex = load("res://assets/ui/cocoon_icon.png")
	_flames = HBoxContainer.new()
	_flames.position = Vector2(8, 6)
	_flames.add_theme_constant_override("separation", 1)
	_flames.visible = false
	hud_layer.add_child(_flames)
	_hud = HBoxContainer.new()
	_hud.position = Vector2(10, 23)
	_hud.add_theme_constant_override("separation", 3)
	_hud.modulate.a = 0.0
	hud_layer.add_child(_hud)
	var icon := TextureRect.new()
	var at := AtlasTexture.new()
	at.atlas = load("res://assets/items/resin.png")
	at.region = Rect2(0, 0, 9, 9)
	icon.texture = at
	icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_hud.add_child(icon)
	_hud_count = _hud_label(10)
	_hud_count.text = "0"
	_hud.add_child(_hud_count)
	_cocoon_row = HBoxContainer.new()
	_cocoon_row.add_theme_constant_override("separation", 2)
	_cocoon_row.position = Vector2(640 - 8 - 3 * 11, 7)
	hud_layer.add_child(_cocoon_row)
	_timer_label = _hud_label(16)
	_timer_label.position = Vector2(296, 8)
	_timer_label.size = Vector2(48, 20)
	_timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_timer_label.visible = false
	hud_layer.add_child(_timer_label)
	_banner = _hud_label(14)
	_banner.position = Vector2(0, 120)
	_banner.size = Vector2(640, 120)
	_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_banner.modulate.a = 0.0
	hud_layer.add_child(_banner)


func _hud_label(size: int) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color(1.0, 0.9, 0.7))
	l.add_theme_color_override("font_shadow_color", Color(0.04, 0.03, 0.07, 0.9))
	l.add_theme_constant_override("shadow_offset_x", 1)
	l.add_theme_constant_override("shadow_offset_y", 1)
	return l


func _frame(tex: Texture2D, w: int, h: int, i: int) -> AtlasTexture:
	var at := AtlasTexture.new()
	at.atlas = tex
	at.region = Rect2(i * w, 0, w, h)
	return at


## Redraw the flames: lit ones, then spent ones. The newest change flares.
func _show_health(flare := -1) -> void:
	for c in _flames.get_children():
		c.queue_free()
	for i in max_health:
		var r := TextureRect.new()
		r.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		r.texture = _frame(_flame_tex, 11, 14, 0 if i < health else 1)
		_flames.add_child(r)
		if i == flare:
			r.modulate = Color(2.0, 1.7, 1.2)
			var tw := r.create_tween()
			tw.tween_property(r, "modulate", Color.WHITE, 0.45)


func _show_cocoons() -> void:
	for c in _cocoon_row.get_children():
		c.queue_free()
	for f in level_cocoons:
		var r := TextureRect.new()
		r.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		r.texture = _frame(_cocoon_tex, 9, 12, 1 if rescued.has(f) else 0)
		_cocoon_row.add_child(r)
	_cocoon_row.position.x = 640 - 8 - level_cocoons.size() * 11


## A line of text in the middle of the screen for a moment (a tally, a bonus).
func banner(text: String, hold := 1.6) -> void:
	_banner.text = text
	var tw := create_tween()
	tw.tween_property(_banner, "modulate:a", 1.0, 0.2)
	tw.tween_interval(hold)
	tw.tween_property(_banner, "modulate:a", 0.0, 0.4)


## The bonus rooms' countdown, top centre ("" hides it).
func show_timer(text: String) -> void:
	_timer_label.visible = text != ""
	_timer_label.text = text


# --- The level ---------------------------------------------------------------------

## A level (or room) starts: Kleo has full flames and starts from `start`.
func level_begin(room: Node, start: Vector2, facing: int) -> void:
	level = room
	health = max_health
	checkpoint = start
	checkpoint_facing = facing
	_unbanked.clear()
	respawning = false
	level_cocoons.clear()
	_flames.visible = true
	_show_health()
	# The cocoons register themselves as they enter the tree.
	await get_tree().process_frame
	_show_cocoons()
	if room.get("is_level"):
		_hud.modulate.a = 0.85


func register_cocoon(flag: String) -> void:
	if not level_cocoons.has(flag):
		level_cocoons.append(flag)
	_show_cocoons()


func rescue(flag: String) -> void:
	rescued[flag] = true
	flags[flag] = true
	_show_cocoons()


func cocoons_found() -> int:
	var n := 0
	for f in level_cocoons:
		if rescued.has(f):
			n += 1
	return n


## A checkpoint is lit: she comes back here, her flames are refilled and the
## Resin she carries is banked.
func reach_checkpoint(pos: Vector2, facing: int) -> void:
	checkpoint = pos
	checkpoint_facing = facing
	for e in _unbanked:
		var p: Node = e[0]
		if is_instance_valid(p):
			p.call("bank")
	_unbanked.clear()
	if health < max_health:
		health = max_health
		_show_health(max_health - 1)
		health_changed.emit(health, max_health)


## A bead was taken; it stays at risk until the next checkpoint.
func take_resin(pickup: Node, value: int) -> void:
	_unbanked.append([pickup, value])
	add_currency(value)


## Lose `amount` flames. Returns the flames left.
func damage(amount: int) -> int:
	if amount <= 0:
		return health
	health = max(health - amount, 0)
	_show_health(health)
	health_changed.emit(health, max_health)
	return health


## Gain flames (amber sap), up to the most she can hold.
func heal(amount: int) -> void:
	health = min(health + amount, max_health)
	_show_health(health - 1)
	health_changed.emit(health, max_health)


## Send her back to the last checkpoint: fade out, put the Resin she carried
## back where it hung, place her, fade in. `refill`: after a defeat, her
## flames come back too.
func respawn(kleo: Node, refill: bool) -> void:
	if respawning:
		return
	respawning = true
	await fade_to(1.0, 0.3)
	var lost := 0
	for e in _unbanked:
		var p: Node = e[0]
		lost += int(e[1])
		if is_instance_valid(p):
			p.call("restore")
	_unbanked.clear()
	if lost > 0:
		currency -= lost
		_hud_count.text = str(currency)
	if refill:
		health = max_health
		_show_health()
		health_changed.emit(health, max_health)
	kleo.call("place", checkpoint, checkpoint_facing)
	var cam := get_viewport().get_camera_2d()
	if cam and cam.has_method("snap_to_target"):
		cam.snap_to_target()
	respawned.emit()
	await get_tree().create_timer(0.15).timeout
	respawning = false
	await fade_to(0.0, 0.35)


## Add Resin to the count and show it.
func add_currency(amount: int) -> void:
	currency += amount
	_hud_count.text = str(currency)
	currency_changed.emit(currency, amount)
	if _hud_tween:
		_hud_tween.kill()
	_hud.modulate = Color(1.6, 1.4, 1.0, 1.0)
	_hud_tween = create_tween()
	_hud_tween.tween_property(_hud, "modulate", Color(1, 1, 1, 0.85), 0.5)


## Leave the room for another: fade out, load it, arrive at `door`, fade in.
func go_to(scene: String, door: String, kleo: Node = null) -> void:
	if _changing:
		return
	_changing = true
	if kleo and kleo.has_method("freeze"):
		kleo.freeze()
	await fade_to(1.0, 0.18)
	arrival_door = door
	if room_host.is_valid():
		await room_host.call(scene)
	else:
		get_tree().change_scene_to_file(scene)
	await get_tree().process_frame
	await get_tree().process_frame
	await fade_to(0.0, 0.22)
	_changing = false


func fade_to(alpha: float, seconds: float) -> void:
	var tw := create_tween()
	tw.tween_property(_fade_rect, "color:a", alpha, seconds)
	await tw.finished


func _process(_delta: float) -> void:
	# End the hit-stop on time. Also a safety net: outside a hit-stop the game
	# always runs at its normal speed.
	if _hitstop_end_us > 0 and Time.get_ticks_usec() >= _hitstop_end_us:
		_hitstop_end_us = 0
	if _hitstop_end_us == 0 and not is_equal_approx(Engine.time_scale, _base_time_scale()):
		Engine.time_scale = _base_time_scale()
	if not debug_overlay:
		return
	var lines := ["FPS %d" % Engine.get_frames_per_second()]
	for k in get_tree().get_nodes_in_group("player"):
		lines.append(k.debug_text())
	_debug_label.text = "\n".join(lines)
