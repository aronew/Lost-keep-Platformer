class_name MillBell
extends Node2D
## What sets a windmill going, or turns it round. Struck with the sword, or
## with a thrown crate when it hangs out of reach.
##
##   "bell": the millers' bell. It wakes a sleeping mill (Windmill.wake), and
##           the mill stays awake. Ringing it again only rings.
##   "vane": a wind vane. Each strike turns its mill the other way
##           (Windmill.reverse); its arrow shows which way the sails' top
##           now moves.
##
## One meaning each, everywhere in the game: a bell starts, a vane turns.
## A rope runs from it to each mill it works, so the player sees the link.
##
## The node sits where the bell hangs (or on the vane's pivot). `Hurtbox` is
## what blows strike.

@export_enum("bell", "vane") var kind := "bell"
@export var mills: Array[NodePath] = []
## Props ask for a lighter impact than things that fight back.
@export var hit_weight := 0.5
## Length of the post under a vane, or of the bracket's drop over a bell (px).
@export var stem := 30.0
## A bell on a post of its own: how far below the bell the ground is (px).
## 0: it hangs from something else (a mill's arm).
@export var post_drop := 0.0

const BRASS := Color("#d9b45a")
const BRASS_DARK := Color("#8a6a2c")
const IRON := Color("#2f2a3a")
const ROPE := Color(0.95, 0.93, 0.82, 0.5)
const ARROW := Color("#efe9d6")

## How many times it has been struck (the tours read this).
var rung := 0

var _mills: Array[Windmill] = []
var _swing := 0.0        # the bell's swing, or the vane's spin, dying away
var _t := 0.0
var _quiet := 0.0        # a moment after a strike in which another does nothing


func _ready() -> void:
	add_to_group("mill_bell")
	for p in mills:
		var m := get_node_or_null(p) as Windmill
		if m:
			_mills.append(m)


func _process(delta: float) -> void:
	_t += delta
	_quiet = maxf(_quiet - delta, 0.0)
	if _swing > 0.0:
		_swing = maxf(_swing - delta * 0.7, 0.0)
	queue_redraw()


func take_hit(hit: Dictionary) -> bool:
	if _quiet > 0.0:
		return false
	# One strike, one change: a whole combo doesn't flip a vane four times.
	_quiet = 0.9
	rung += 1
	_swing = 1.0
	var from := int(hit.get("dir", 1))
	var changed := false
	for m in _mills:
		if kind == "vane":
			m.reverse()
			changed = true
		else:
			changed = m.wake() or changed
	Fx.burst(self, global_position, BRASS if kind == "bell" else ARROW, 14 if changed else 6, 120.0 if changed else 70.0)
	Fx.spark(self, global_position + Vector2(-from * 4, 0))
	if changed:
		Game.shake(0.16)
	return true


## True when its mill is awake (a bell) or turns clockwise (a vane).
func state() -> bool:
	if _mills.is_empty():
		return false
	return _mills[0].turn > 0 if kind == "vane" else _mills[0].is_awake()


func _draw() -> void:
	# The rope to each mill it works (dotted, so it reads as a link, not a floor).
	for m in _mills:
		var to := to_local(m.global_position + Vector2(0, -Windmill.HANG))
		var n := int(to.length() / 7.0)
		for k in range(1, n):
			if k % 2 == 0:
				draw_rect(Rect2((to * (float(k) / n)).round() - Vector2(1, 1), Vector2(2, 2)), ROPE)
	if kind == "vane":
		_draw_vane()
	else:
		_draw_bell()


func _draw_bell() -> void:
	# A bracket above, the bell swinging under it.
	if post_drop > 0.0:
		draw_line(Vector2(-11, -stem), Vector2(-11, post_drop), IRON, 3.0)
		draw_line(Vector2(-12, -stem), Vector2(2, -stem), IRON, 2.0)
	draw_line(Vector2(0, -stem), Vector2(0, -10), IRON, 2.0)
	draw_line(Vector2(-8, -stem), Vector2(8, -stem), IRON, 2.0)
	var a := sin(_t * 14.0) * 0.5 * _swing
	draw_set_transform(Vector2(0, -10), a, Vector2.ONE)
	draw_colored_polygon(PackedVector2Array([Vector2(-3, 0), Vector2(3, 0), Vector2(6, 9), Vector2(9, 17), Vector2(-9, 17), Vector2(-6, 9)]), BRASS)
	draw_line(Vector2(-9, 17), Vector2(9, 17), BRASS_DARK, 2.0)
	draw_rect(Rect2(-2, 3, 2, 9), Color(1.0, 0.95, 0.75, 0.8))
	draw_circle(Vector2(0, 20), 2.5, BRASS_DARK)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_vane() -> void:
	# A post, and an arrow on its top pointing the way the sails' top moves.
	draw_line(Vector2(0, 0), Vector2(0, stem), IRON, 2.0)
	draw_circle(Vector2.ZERO, 3.0, BRASS)
	var dir := 1.0 if state() else -1.0
	# Struck, it spins round once and settles the other way.
	var sx := dir * cos(_swing * _swing * TAU * 1.5)
	draw_set_transform(Vector2(0, -2), 0.0, Vector2(sx if absf(sx) > 0.08 else 0.08, 1.0))
	draw_colored_polygon(PackedVector2Array([Vector2(-15, -3), Vector2(4, -3), Vector2(4, -8), Vector2(16, 0), Vector2(4, 8), Vector2(4, 3), Vector2(-15, 3),
		Vector2(-11, 0)]), ARROW)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
