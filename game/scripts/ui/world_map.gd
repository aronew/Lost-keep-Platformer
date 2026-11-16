extends Node2D
## The world map: a region's stops along a road, Kleo standing on one. Each
## stop shows what is found in its level and what is still missing (letters
## K-L-E-O, bonus tokens, Morvath's thorn knot): the hunt, kept in view. A
## cleared stop's banner flies. A stop opens when the one before it is
## done; stops not built yet are dim.
##
## Left and right move her; jump or interact enters. F4 opens every built stop
## (for reviewing a level before the ones in front of it are finished).
##
## A stand-in look, drawn here: flat colours, the HUD's icons. The painted map
## of Vaelora comes with the art.

const SKY_TOP := Color("#3d8ccc")
const SKY_LOW := Color("#b4e2ee")
const HILL := Color("#3f8f5a")
const HILL_FAR := Color("#74b98a")
const ROAD := Color("#c9a26b")
const ROAD_LIT := Color("#f2b04a")
const INK := Color("#0b0812")
const PAPER := Color(1.0, 0.95, 0.82)
const DIM := Color(1, 1, 1, 0.4)
const ROAD_Y := 214.0

var _stop := 0
var _all_open := false
var _marker: Sprite2D
var _marker_x := 0.0
var _t := 0.0
var _busy := false
var _icons: Texture2D = preload("res://assets/ui/letter_icons.png")
var _token: Texture2D = preload("res://assets/items/token.png")
var _knot: Texture2D = preload("res://assets/items/knot.png")
var _banner: Texture2D = preload("res://assets/items/banner.png")
var _font: Font


func _ready() -> void:
	_font = ThemeDB.fallback_font
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	Game.show_hud(false)
	Game.level = null
	_stop = clampi(Game.map_stop, 0, Game.LEVELS.size() - 1)
	if not _open(_stop):
		_stop = 0
	_marker = Sprite2D.new()
	_marker.texture = preload("res://assets/characters/kleo/idle.png")
	_marker.region_enabled = true
	_marker.region_rect = Rect2(0, 0, 64, 64)
	_marker.offset = Vector2(0, -24)  # her feet (frame y 56) on the road
	_marker.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_marker)
	_marker_x = _x(_stop)
	_marker.position = Vector2(_marker_x, ROAD_Y)


func _x(i: int) -> float:
	return 68.0 + i * 84.0


func _open(i: int) -> bool:
	if Game.LEVELS[i].get("scene", "") == "":
		return false
	return _all_open or Game.stop_open(i)


func _process(delta: float) -> void:
	_t += delta
	_marker_x = move_toward(_marker_x, _x(_stop), 260.0 * delta)
	_marker.position = Vector2(roundf(_marker_x), ROAD_Y)
	_marker.region_rect.position.x = 64.0 * (int(_t * 8.0) % 12)
	queue_redraw()
	if _busy:
		return
	if Input.is_action_just_pressed("move_right"):
		_step(1)
	elif Input.is_action_just_pressed("move_left"):
		_step(-1)
	elif Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("attack"):
		if _open(_stop) and absf(_marker_x - _x(_stop)) < 2.0:
			_busy = true
			Game.enter_level(_stop)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F4:
		_all_open = not _all_open


func _step(dir: int) -> void:
	var next := _stop + dir
	if next < 0 or next >= Game.LEVELS.size() or not _open(next):
		return
	_stop = next
	_marker.flip_h = dir < 0
	Game.map_stop = _stop


func _text(pos: Vector2, text: String, size: int, color: Color, centre := true) -> void:
	var w := _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var at := (pos - Vector2(w * 0.5 if centre else 0.0, 0.0)).round()
	draw_string_outline(_font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 3, INK)
	draw_string(_font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


func _draw() -> void:
	# The sky, far hills, the near hill the road runs on.
	for y in 36:
		draw_rect(Rect2(0, y * 10, 640, 10), SKY_TOP.lerp(SKY_LOW, y / 35.0))
	var far := PackedVector2Array([Vector2(0, 360)])
	var near := PackedVector2Array([Vector2(0, 360)])
	for x in range(0, 641, 16):
		far.append(Vector2(x, 176.0 + sin(x * 0.021) * 16.0 + sin(x * 0.007 + 1.0) * 12.0))
		near.append(Vector2(x, ROAD_Y + 8.0 + sin(x * 0.012 + 2.0) * 5.0))
	far.append(Vector2(640, 360))
	near.append(Vector2(640, 360))
	draw_colored_polygon(far, HILL_FAR)
	draw_colored_polygon(near, HILL)
	_text(Vector2(320, 34), "THE IRONBARK WILDS", 16, PAPER)
	_text(Vector2(320, 50), "Region 1", 8, PAPER)
	var n := Game.LEVELS.size()
	var letters := 0
	var tokens := 0
	var knots := 0
	var built := 0
	# The road: lit amber as far as she has cleared.
	for i in n - 1:
		var lit: bool = Game.record(i)["done"]
		draw_line(Vector2(_x(i), ROAD_Y), Vector2(_x(i + 1), ROAD_Y), INK, 7.0)
		draw_line(Vector2(_x(i), ROAD_Y), Vector2(_x(i + 1), ROAD_Y), ROAD_LIT if lit else ROAD, 3.0)
	for i in n:
		var l: Dictionary = Game.LEVELS[i]
		var r: Dictionary = Game.record(i)
		var x := _x(i)
		var open := _open(i)
		var tint := Color.WHITE if open else DIM
		# The stop: a stone in the road, and the Guard's banner beside it,
		# furled until the level is cleared, then flying.
		draw_circle(Vector2(x, ROAD_Y), 6.0, INK)
		draw_circle(Vector2(x, ROAD_Y), 4.0, ROAD_LIT if r["done"] else (PAPER if open else Color("#8a8f99")))
		var frame := (1 + int(_t * 5.0) % 2) if r["done"] else 0
		draw_texture_rect_region(_banner, Rect2(x + 8.0, ROAD_Y - 62.0, 40, 64), Rect2(frame * 40, 0, 40, 64), tint)
		_text(Vector2(x, ROAD_Y + 24.0), l["id"], 10, PAPER if open else Color(PAPER, 0.5))
		var words: PackedStringArray = String(l["name"]).split(" ")
		var line := ""
		var row := 0
		for w in words:
			if line != "" and (line + " " + w).length() > 11:
				_text(Vector2(x, ROAD_Y + 35.0 + row * 9.0), line, 8, PAPER if open else Color(PAPER, 0.5))
				row += 1
				line = w
			else:
				line = w if line == "" else line + " " + w
		_text(Vector2(x, ROAD_Y + 35.0 + row * 9.0), line, 8, PAPER if open else Color(PAPER, 0.5))
		if not r["built"]:
			continue
		built += 1
		# What is found, and what is missing: letters, tokens, the knot.
		var y := ROAD_Y + 62.0
		for k in 4:
			var found: bool = r["letters"][k]
			letters += 1 if found else 0
			draw_texture_rect_region(_icons, Rect2(x - 19.0 + k * 10.0, y, 9, 11), Rect2((k + (4 if found else 0)) * 9, 0, 9, 11), tint)
		for k in int(r["tokens_of"]):
			var won: bool = k < int(r["tokens"])
			draw_texture_rect_region(_token, Rect2(x - 15.0 + k * 16.0, y + 14.0, 14, 14), Rect2(1, 1, 14, 14), tint if won else Color(0.2, 0.2, 0.3, 0.55))
		tokens += int(r["tokens"])
		knots += 1 if r["knot"] else 0
		draw_texture_rect_region(_knot, Rect2(x - 10.0, y + 31.0, 20, 20), Rect2(20 if r["knot"] else 0, 0, 20, 20), tint if r["knot"] else Color(1, 1, 1, 0.4))
	_text(Vector2(320, 76), "Letters %d / %d     Tokens %d / %d     Knots awake %d / %d     Resin %d" % [
		letters, built * 4, tokens, built * 2, knots, built, Game.currency], 8, PAPER)
	var here: Dictionary = Game.LEVELS[_stop]
	_text(Vector2(320, 348), "%s  %s        left / right: travel     jump: enter" % [here["id"], here["name"]], 8, PAPER)
