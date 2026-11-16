class_name MovingPlatform
extends AnimatableBody2D
## A platform that travels: a timber raft, a stone slab, a lift. It runs back
## and forth along `path` (offsets from where it starts, in px), easing out of
## each stop and into the next so it never jerks, and pausing at each end.
## Kleo rides it (it carries her: sync_to_physics). With `wait_for_rider` it
## stays put until she steps on, then makes its run (and comes back for her
## when she has left it).
##
## Its collision is one-way (layer 7, she jumps up through it and drops down
## through it) unless `solid`.

@export var path: Array[Vector2] = [Vector2(0, 0), Vector2(128, 0)]
@export var speed := 48.0
@export var pause := 0.6
@export var wait_for_rider := false
## Seconds into its cycle at the start (to set platforms out of step).
@export var phase := 0.0

var _leg := 0       # moving from path[_leg] to path[_leg + _step]
var _step := 1
var _t := 0.0       # 0..1 along the current leg
var _hold := 0.0
var _origin := Vector2.ZERO
var _waiting := false
var _ridden_off := 0.0


func _ready() -> void:
	add_to_group("moving_platform")
	sync_to_physics = true
	_origin = position
	_waiting = wait_for_rider
	if phase > 0.0:
		var steps := int(phase * 60.0)
		for i in steps:
			_advance(1.0 / 60.0)
		position = _origin + _at()


func _leg_length() -> float:
	return path[_leg].distance_to(path[_leg + _step])


func _at() -> Vector2:
	if path.size() < 2:
		return Vector2.ZERO
	# Ease in and out of each stop: a smooth start and a soft arrival.
	var e := 0.5 - 0.5 * cos(PI * _t)
	return path[_leg].lerp(path[_leg + _step], e)


func _advance(delta: float) -> void:
	if path.size() < 2:
		return
	if _hold > 0.0:
		_hold -= delta
		return
	var length := maxf(_leg_length(), 1.0)
	# Eased travel takes a little longer than the straight run: keep the top
	# speed near `speed`.
	_t += delta * speed / (length * 1.4)
	if _t >= 1.0:
		_t = 0.0
		_leg += _step
		if _leg + _step < 0 or _leg + _step >= path.size():
			_step = -_step
		_hold = pause


func _physics_process(delta: float) -> void:
	if _waiting:
		if _has_rider():
			_waiting = false
			_hold = 0.15
		else:
			return
	elif wait_for_rider:
		# Once back at the start with no one on it, it waits again.
		if _has_rider():
			_ridden_off = 0.0
		else:
			_ridden_off += delta
		if _leg == 0 and _t == 0.0 and _step == 1 and _ridden_off > 0.5:
			_waiting = true
			return
	_advance(delta)
	position = (_origin + _at()).round()


func _has_rider() -> bool:
	for k in get_tree().get_nodes_in_group("player"):
		var kleo := k as CharacterBody2D
		if kleo.is_on_floor():
			for i in kleo.get_slide_collision_count():
				if kleo.get_slide_collision(i).get_collider() == self:
					return true
	return false
