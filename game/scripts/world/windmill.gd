class_name Windmill
extends Node2D
## A windmill's sails, turning, with a hoist cradle hung from the tip of each
## arm: the Hearth-Plains' moving platforms. The cradles stay level as the
## sails turn (a Ferris wheel), so Kleo steps on one and is carried round:
## up and over, or down and under, depending on which way the mill turns.
##
## A mill is a loop. Staying on never drops her: it brings her round again,
## so missing an exit costs time, never a flame. That is what makes a mill
## safe to explore (see the secrets in design/levels/2-2_millers_row.md).
##
## The node sits at the centre of the circle the cradles' tops travel; a
## cradle's top is at `radius` from it. The sails' own hub is drawn `HANG` px
## above (the cradles hang below the arm tips).
##
## Two things change a mill, both struck with the sword or a thrown crate
## (MillBell): a **bell** wakes a sleeping mill (`wake`), and a **wind vane**
## turns it the other way (`reverse`). It eases into every change: a mill
## never jerks, and a rider is never thrown.
##
## Children: `Cradle0` .. `CradleN-1` (AnimatableBody2D, one-way, layer 7).

## Radius of the cradles' circle (px).
@export var radius := 80.0
## Seconds for a full turn at working pace.
@export var period := 10.0
## 1: clockwise on screen (the top moves right); -1: counter-clockwise.
@export var turn := 1
## False: asleep (its sails furled, its cradles still) until a bell wakes it.
@export var running := true
## Where arm 0 is at the start, in degrees: 0 east (3 o'clock), 90 the bottom,
## 180 west (9 o'clock), 270 the top.
@export var start_angle := 0.0
## Seconds to ease from still to working pace (and twice that to reverse).
@export var spin_time := 1.1
## A faint ring along the cradles' path (the ride is always in sight).
@export var show_path := true

## How far a cradle hangs below its arm's tip (px).
const HANG := 20.0
const SPAR := Color("#3a3148")
const SPAR_ASLEEP := Color("#4c4660")
const SAIL := Color(0.93, 0.9, 0.78)
const ROPE := Color(0.2, 0.17, 0.26, 0.9)
const RING := Color(1.0, 1.0, 1.0, 0.13)

var _cradles: Array[AnimatableBody2D] = []
var _angle := 0.0        # arm 0, radians
var _rate := 0.0         # -1 .. 1 of working pace, signed by the turn
var _flash := 0.0


func _ready() -> void:
	add_to_group("windmill")
	for c in get_children():
		if c is AnimatableBody2D:
			(c as AnimatableBody2D).sync_to_physics = true
			_cradles.append(c)
	_angle = deg_to_rad(start_angle)
	_rate = float(turn) if running else 0.0
	_place()


func _physics_process(delta: float) -> void:
	var want := float(turn) if running else 0.0
	_rate = move_toward(_rate, want, delta / maxf(spin_time, 0.01))
	_angle = fposmod(_angle + TAU / period * _rate * delta, TAU)
	_flash = maxf(_flash - delta * 2.5, 0.0)
	_place()
	queue_redraw()


func _place() -> void:
	for i in _cradles.size():
		var c := _cradles[i]
		c.position = (_offset(i) - Vector2(_width(c) * 0.5, 0.0)).round()


func _offset(i: int) -> Vector2:
	var a := _angle + TAU * i / maxf(_cradles.size(), 1.0)
	return Vector2(cos(a), sin(a)) * radius


func _width(c: AnimatableBody2D) -> float:
	return float(c.get_meta("width", 48.0))


# --- What a bell or a vane does --------------------------------------------------------------

## A bell: a sleeping mill wakes (and stays awake). True if it was asleep.
func wake() -> bool:
	_flash = 1.0
	if running:
		return false
	running = true
	return true


## A wind vane: the mill turns the other way.
func reverse() -> void:
	turn = -turn
	_flash = 1.0


func is_awake() -> bool:
	return running


# --- For the level's scripted tours ----------------------------------------------------------

func cradle_count() -> int:
	return _cradles.size()


## The middle of cradle `i`'s top (global px).
func cradle_top(i: int) -> Vector2:
	return global_position + _offset(i)


func cradle(i: int) -> AnimatableBody2D:
	return _cradles[i]


## Cradle `i`'s place on the circle, in degrees (0 east, 90 the bottom,
## 180 west, 270 the top).
func cradle_angle(i: int) -> float:
	return fposmod(rad_to_deg(_angle) + 360.0 * i / maxf(_cradles.size(), 1.0), 360.0)


## The current share of working pace, signed (1 clockwise at full pace).
func pace() -> float:
	return _rate


# --- How it looks (a stand-in until the Hearth-Plains kit) ----------------------------------

func _draw() -> void:
	var hub := Vector2(0, -HANG)
	if show_path:
		# The cradles' path: a faint dotted ring.
		var dots := int(radius * 0.4)
		for k in dots:
			var a := TAU * k / dots
			draw_rect(Rect2((Vector2(cos(a), sin(a)) * radius + Vector2(-1, 3)).round(), Vector2(2, 2)), RING)
	var awake := absf(_rate)
	var spar := SPAR_ASLEEP.lerp(SPAR, awake).lerp(Color.WHITE, _flash * 0.6)
	for i in _cradles.size():
		var tip := _offset(i) + hub
		var dir := tip.normalized()
		var side := Vector2(-dir.y, dir.x)
		# The sail: a lattice of canvas along the spar's trailing side. Furled
		# (a thin roll) while the mill sleeps; it fills as the mill wakes.
		var w := lerpf(3.0, 13.0, awake)
		var a0 := dir * 14.0
		var a1 := dir * (radius - 4.0)
		draw_colored_polygon(PackedVector2Array([hub + a0, hub + a1, hub + a1 + side * w, hub + a0 + side * w * 0.7]),
			Color(SAIL, lerpf(0.32, 0.5, awake)))
		draw_line(hub, tip, spar, 3.0)
		# The cradle's hanger: two ropes from the arm's tip to its ends.
		var half := _width(_cradles[i]) * 0.5 - 3.0
		var top := _offset(i)
		draw_line(tip, top + Vector2(-half, 1), ROPE, 1.0)
		draw_line(tip, top + Vector2(half, 1), ROPE, 1.0)
	draw_circle(hub, 7.0, spar)
	draw_circle(hub, 3.0, Color("#d9b45a").lerp(Color.WHITE, _flash))
