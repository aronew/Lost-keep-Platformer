extends Node2D
## The world map: region 1, on the creative lead's painted map
## (assets/ui/region1_map.png, from art/source/maps/). Its numbered pads are
## the region's stops: 1 to 5 are levels 1-1 to 1-5, 6 (the skull gate) is the
## boss, and "?" (the grotto) is the secret level, off the path from 3. Kleo
## travels pad to pad along the map's dotted paths.
##
## The map keeps score: the plate under the title counts the stops cleared,
## the bottom plate names the stop she stands on, and over it is that level's
## record (letters K-L-E-O, bonus tokens, Morvath's thorn knot), each found or
## missing. A stop opens when the one before it is done; a shut stop's pad is
## dimmed, a cleared one is ringed in amber.
##
## Left and right travel the main path; down from 3 goes to the grotto, up
## comes back. Jump, interact or attack enters. F4 opens every built stop (for
## reviewing a level before the ones in front of it are finished).
##
## The painting has a Kleo, "0/6 levels completed" and "1 · Lantern Refuge"
## painted into it. The two plates are covered here and written afresh; the
## painted Kleo at pad 1 can't be, so she stays there (see CLAUDE.md).

const MAP := preload("res://assets/ui/region1_map.png")
## The painting is 1672 px wide; the game shows it at 640.
const S := 640.0 / 1672.0
## Each stop's pad, by its index in Game.LEVELS (painting px).
const PADS := [Vector2(253, 700), Vector2(392, 312), Vector2(646, 594), Vector2(975, 522), Vector2(1062, 340),
	Vector2(1290, 728), Vector2(1487, 280)]
## The dotted paths between pads (painting px), keyed "from-to" by index.
const PATHS := {
	"0-1": [Vector2(253, 700), Vector2(330, 660), Vector2(356, 600), Vector2(322, 530), Vector2(282, 470),
		Vector2(278, 410), Vector2(322, 345), Vector2(392, 312)],
	"1-2": [Vector2(392, 312), Vector2(470, 318), Vector2(530, 372), Vector2(578, 455), Vector2(604, 540), Vector2(646, 594)],
	"2-3": [Vector2(646, 594), Vector2(740, 596), Vector2(820, 572), Vector2(900, 548), Vector2(975, 522)],
	"3-4": [Vector2(975, 522), Vector2(1030, 474), Vector2(1076, 410), Vector2(1084, 366), Vector2(1062, 340)],
	"4-6": [Vector2(1062, 340), Vector2(1130, 362), Vector2(1205, 352), Vector2(1262, 306), Vector2(1340, 290),
		Vector2(1420, 290), Vector2(1487, 280)],
	"2-5": [Vector2(646, 594), Vector2(700, 622), Vector2(742, 676), Vector2(790, 716), Vector2(872, 726),
		Vector2(960, 746), Vector2(1075, 766), Vector2(1165, 764), Vector2(1290, 728)],
}
## The main path, in order (the grotto, 5, hangs off stop 2).
const CHAIN := [0, 1, 2, 3, 4, 6]
const GROTTO := 5
const GROTTO_FROM := 2
const SPEED := 230.0

const INK := Color("#0b0812")
const PAPER := Color("#f3e3b4")
const AMBER := Color("#f2b04a")
## The plates' own colours, to cover what is painted on them.
const TOP_PLATE := Rect2(266, 32, 108, 11)
const TOP_INK := Color("#2b1f38")
const BOTTOM_PLATE := Rect2(239, 336, 162, 14)
const BOTTOM_INK := Color("#532c3f")

var _stop := 0
var _all_open := false
var _marker: Sprite2D
var _pos := Vector2.ZERO
var _route: Array[Vector2] = []
var _t := 0.0
var _busy := false
var _icons: Texture2D = preload("res://assets/ui/letter_icons.png")
var _token: Texture2D = preload("res://assets/items/token.png")
var _knot: Texture2D = preload("res://assets/items/knot.png")
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
	_marker.offset = Vector2(0, -24)  # her feet (frame y 56) on the pad
	_marker.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_marker)
	_pos = _pad(_stop)
	_marker.position = _pos.round()


func _pad(i: int) -> Vector2:
	return PADS[i] * S + Vector2(0, -2)


func _open(i: int) -> bool:
	if Game.LEVELS[i].get("scene", "") == "":
		return false
	return _all_open or Game.stop_open(i)


func _arrived() -> bool:
	return _route.is_empty()


func _process(delta: float) -> void:
	_t += delta
	# Along the path, point to point.
	var left := SPEED * delta
	while left > 0.0 and not _route.is_empty():
		var d := _pos.distance_to(_route[0])
		if d <= left:
			_pos = _route[0]
			_route.remove_at(0)
			left -= d
		else:
			if absf(_route[0].x - _pos.x) > 0.5:
				_marker.flip_h = _route[0].x < _pos.x
			_pos = _pos.move_toward(_route[0], left)
			left = 0.0
	_marker.position = _pos.round()
	_marker.region_rect.position.x = 64.0 * (int(_t * 8.0) % 12)
	queue_redraw()
	if _busy or not _arrived():
		return
	if Input.is_action_just_pressed("move_right"):
		_along(1)
	elif Input.is_action_just_pressed("move_left"):
		if _stop == GROTTO:
			_travel(GROTTO_FROM)
		else:
			_along(-1)
	elif Input.is_action_just_pressed("move_down") and _stop == GROTTO_FROM:
		_travel(GROTTO)
	elif Input.is_action_just_pressed("move_up") and _stop == GROTTO:
		_travel(GROTTO_FROM)
	elif Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("attack"):
		if _open(_stop):
			_busy = true
			Game.enter_level(_stop)


func _unhandled_input(event: InputEvent) -> void:
	if OS.is_debug_build() and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F4:
		_all_open = not _all_open


## A step along the main path.
func _along(dir: int) -> void:
	var at := CHAIN.find(_stop)
	if at < 0 or at + dir < 0 or at + dir >= CHAIN.size():
		return
	_travel(CHAIN[at + dir])


func _travel(to: int) -> void:
	if not _open(to):
		return
	var pts: Array = []
	if PATHS.has("%d-%d" % [_stop, to]):
		pts = PATHS["%d-%d" % [_stop, to]].duplicate()
	elif PATHS.has("%d-%d" % [to, _stop]):
		pts = PATHS["%d-%d" % [to, _stop]].duplicate()
		pts.reverse()
	_route.clear()
	for k in range(1, pts.size() - 1):
		_route.append(pts[k] * S + Vector2(0, -2))
	_route.append(_pad(to))
	_stop = to
	Game.map_stop = _stop


func _text(pos: Vector2, text: String, size: int, color: Color) -> void:
	var w := _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var at := (pos - Vector2(w * 0.5, 0.0)).round()
	draw_string_outline(_font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 2, INK)
	draw_string(_font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


## A flat ring round a pad (the pads are seen from above, at a slant).
func _ring(at: Vector2, radius: float, color: Color, width: float) -> void:
	draw_set_transform(at, 0.0, Vector2(1.0, 0.45))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 24, color, width / 0.45 * 0.6)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw() -> void:
	draw_texture_rect(MAP, Rect2(0, 0, 640, 360), false)
	var cleared := 0
	var of := 0
	for i in Game.LEVELS.size():
		var r: Dictionary = Game.record(i)
		var at: Vector2 = PADS[i] * S
		if i != GROTTO:
			of += 1
			cleared += 1 if r["done"] else 0
		if r["done"]:
			_ring(at, 15.0, AMBER, 2.0)       # cleared: ringed in amber
		elif not _open(i):
			draw_set_transform(at, 0.0, Vector2(1.0, 0.45))
			draw_circle(Vector2.ZERO, 13.0, Color(0.04, 0.03, 0.07, 0.55))  # shut: dimmed
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# The pad she stands on, or is going to.
	_ring(PADS[_stop] * S, 17.0 + sin(_t * 4.0), Color("#3fe0c8"), 1.5)
	# The plates, written afresh over what is painted on them.
	draw_rect(TOP_PLATE, TOP_INK)
	_text(TOP_PLATE.get_center() + Vector2(0, 3), "%d/%d LEVELS COMPLETED" % [cleared, of], 8, PAPER)
	var here: Dictionary = Game.LEVELS[_stop]
	draw_rect(BOTTOM_PLATE, BOTTOM_INK)
	_text(BOTTOM_PLATE.get_center() + Vector2(0, 3), ("%s · %s" % [here["id"], here["name"]]).to_upper(), 8, PAPER)
	# Over the bottom plate: what is found in this level, and what is missing.
	var rec: Dictionary = Game.record(_stop)
	var box := Rect2(264, 312, 112, 22)
	draw_rect(box.grow(1.0), Color("#c8873f"))
	draw_rect(box, Color(0.1, 0.07, 0.14, 0.92))
	if not rec["built"]:
		_text(box.get_center() + Vector2(0, 3), "not built yet", 8, Color(PAPER, 0.7))
		return
	if not _open(_stop):
		_text(box.get_center() + Vector2(0, 3), "clear the level before it", 8, Color(PAPER, 0.7))
		return
	var x := box.position.x + 5.0
	var y := box.position.y
	for k in 4:
		var found: bool = rec["letters"][k]
		draw_texture_rect_region(_icons, Rect2(x + k * 10.0, y + 6.0, 9, 11), Rect2((k + (4 if found else 0)) * 9, 0, 9, 11))
	x += 46.0
	for k in int(rec["tokens_of"]):
		var won: bool = k < int(rec["tokens"])
		draw_texture_rect_region(_token, Rect2(x + k * 15.0, y + 4.0, 14, 14), Rect2(1, 1, 14, 14), Color.WHITE if won else Color(0.25, 0.25, 0.35, 0.7))
	x += 34.0
	draw_texture_rect_region(_knot, Rect2(x, y + 1.0, 20, 20), Rect2(20 if rec["knot"] else 0, 0, 20, 20), Color.WHITE if rec["knot"] else Color(1, 1, 1, 0.45))
