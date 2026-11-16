class_name Lunger
extends CharacterBody2D
## A creature that fights by lunging (in 1-1, the creative lead's rat from
## their enemy roster). It patrols its stretch of floor; when Kleo comes into view it
## NOTICES her (stops dead, head and ears snap up), STALKS closer, WINDS UP (a
## crouch and a shiver, about half a second: the tell), LUNGES (a long leap
## that hurts), and LANDS in a skid, open to a counter. Struck, it FLINCHES:
## knocked back, its wind-up broken. Four sword hits put it down; a thrown
## crate does it in one.
##
## Its `Art` is either an animation sheet (10 frames: walk 0-3, notice, wind-up,
## lunge, land, flinch, down) or a single pose (the roster's stand-ins): then
## each move is acted out by squash, stretch and lean (`_pose`).
##
## The node sits at its feet. It is a CharacterBody2D only for gravity and the
## floor (no collision with Kleo: she takes a hit when its `Touch` meets her).
## It never leaves [left_x, right_x] (world px), so it never runs off a ledge.

enum S { PATROL, NOTICE, STALK, WINDUP, LUNGE, LAND, FLINCH, DEAD }

@export var left_x := 0.0
@export var right_x := 0.0
@export var hits_to_kill := 4
@export var walk_speed := 26.0
@export var stalk_speed := 64.0
@export var sight := 150.0
@export var lunge_range := 92.0
@export var lunge_speed := 230.0
@export var lunge_rise := 190.0
@export var windup_time := 0.5
## How hard a hit on it lands for Kleo's hit-stop and shake.
@export var hit_weight := 1.0

const GRAVITY := 900.0
const F_WALK := 0
const F_NOTICE := 4
const F_WINDUP := 5
const F_LUNGE := 6
const F_LAND := 7
const F_FLINCH := 8
const F_DOWN := 9

@onready var art: Sprite2D = $Art
@onready var hurtbox: Area2D = $Hurtbox
@onready var touch: Area2D = $Touch

var state := S.PATROL
var dir := 1
var hits := 0
var _t := 0.0      # time in the current state
var _clock := 0.0
var _rest := 0.0
var _lost := 0.0   # how long Kleo has been out of sight
var _cool := 0.0   # after a lunge, before the next wind-up
var _kleo: Kleo = null


func _ready() -> void:
	add_to_group("enemy")
	collision_layer = 0
	collision_mask = 1 | 64
	floor_snap_length = 4.0
	dir = 1 if (int(position.x) / 16) % 2 == 0 else -1


func _go(s: S) -> void:
	state = s
	_t = 0.0


func _physics_process(delta: float) -> void:
	if state == S.DEAD:
		return
	_t += delta
	_clock += delta
	_cool = maxf(_cool - delta, 0.0)
	if _kleo == null:
		var ks := get_tree().get_nodes_in_group("player")
		if not ks.is_empty():
			_kleo = ks[0]
	velocity.y = minf(velocity.y + GRAVITY * delta, 400.0)
	art.offset.x = 0.0
	match state:
		S.PATROL:
			_patrol(delta)
		S.NOTICE:
			velocity.x = 0.0
			_pose(F_NOTICE)
			if _t >= 0.38:
				_go(S.STALK)
		S.STALK:
			_stalk(delta)
		S.WINDUP:
			velocity.x = 0.0
			_pose(F_WINDUP)
			art.offset.x = (1.0 if int(_t * 30.0) % 2 == 0 else -1.0) if _t > windup_time * 0.4 else 0.0
			_flash(0.35 if int(_t * 12.0) % 2 == 0 and _t > windup_time * 0.5 else 0.0)
			if _t >= windup_time:
				_lunge()
		S.LUNGE:
			_pose(F_LUNGE)
			if is_on_floor() and _t > 0.08:
				_go(S.LAND)
				Fx.dust(self, global_position, Fx.LANDING, dir)
				Game.shake(0.08)
		S.LAND:
			velocity.x = move_toward(velocity.x, 0.0, 700.0 * delta)
			_pose(F_LAND)
			if _t > 0.08 and _t < 0.3 and Engine.get_physics_frames() % 5 == 0:
				Fx.dust(self, global_position, Fx.SKID, dir)
			if _t >= 0.6:
				_cool = 0.5
				_go(S.STALK)
		S.FLINCH:
			velocity.x = move_toward(velocity.x, 0.0, 500.0 * delta)
			_pose(F_FLINCH)
			if _t >= 0.34 and is_on_floor():
				_cool = 0.35
				_go(S.STALK)
	move_and_slide()
	# Never leave its stretch of floor.
	if global_position.x < left_x or global_position.x > right_x:
		global_position.x = clampf(global_position.x, left_x, right_x)
		velocity.x = 0.0
	art.flip_h = dir < 0
	_touch_kleo()


## Show a move: its frame on a sheet; on a single pose, a squash, stretch or
## lean of the one drawing (anchored at its feet), so it still reads.
func _pose(f: int) -> void:
	if art.hframes > 1:
		art.frame = f
		return
	var sc := Vector2.ONE
	var rot := 0.0
	match f:
		F_NOTICE:
			sc = Vector2(0.92, 1.1)        # rears up
		F_WINDUP:
			sc = Vector2(1.14, 0.84)       # crouched low
		F_LUNGE:
			sc = Vector2(1.18, 0.88)       # stretched long
			rot = -0.12
		F_LAND:
			sc = Vector2(1.12, 0.9)
		F_FLINCH:
			sc = Vector2(0.88, 1.08)
			rot = 0.18
		F_DOWN:
			sc = Vector2(1.1, 0.7)
		_:
			# walking: a small bob in step with the stride
			var step := f - F_WALK
			sc = Vector2(1.0, 1.0 - 0.04 * float(step % 2))
	art.scale = sc
	art.rotation = rot * (-1.0 if dir < 0 else 1.0)


func _sees_kleo() -> bool:
	if _kleo == null or _kleo.is_down():
		return false
	var d := _kleo.global_position - global_position
	if absf(d.y) > 48.0 or absf(d.x) > sight:
		return false
	# It sees ahead of itself, and hears her right behind it.
	if signf(d.x) != dir and absf(d.x) > 40.0:
		return false
	# Only while she is over its stretch of floor (or just off its ends).
	return _kleo.global_position.x > left_x - 48.0 and _kleo.global_position.x < right_x + 48.0


func _patrol(delta: float) -> void:
	if _sees_kleo():
		dir = 1 if _kleo.global_position.x > global_position.x else -1
		velocity = Vector2(0.0, -70.0)  # a start: it flinches upright
		_go(S.NOTICE)
		return
	if _rest > 0.0:
		_rest -= delta
		velocity.x = 0.0
		_pose(F_WALK)
		return
	velocity.x = dir * walk_speed
	_pose(F_WALK + int(_clock * 6.0) % 4)
	if (dir > 0 and global_position.x >= right_x - 1.0) or (dir < 0 and global_position.x <= left_x + 1.0):
		dir = -dir
		_rest = 0.9
	elif fmod(_clock, 5.0) < delta:
		_rest = 1.2


func _stalk(delta: float) -> void:
	if not _sees_kleo():
		_lost += delta
		velocity.x = 0.0
		_pose(F_NOTICE)
		if _lost > 1.4:
			_lost = 0.0
			_go(S.PATROL)
		return
	_lost = 0.0
	var dx := _kleo.global_position.x - global_position.x
	dir = 1 if dx > 0.0 else -1
	if absf(dx) <= lunge_range and _cool <= 0.0 and is_on_floor():
		Fx.dust(self, global_position + Vector2(-dir * 12, 0), Fx.SKID, dir)
		_go(S.WINDUP)
		return
	if absf(dx) < 26.0:
		velocity.x = move_toward(velocity.x, -dir * stalk_speed * 0.6, 400.0 * delta)  # backs off to lunge room
	else:
		velocity.x = move_toward(velocity.x, dir * stalk_speed, 400.0 * delta)
	_pose(F_WALK + int(_clock * 10.0) % 4)


func _lunge() -> void:
	_flash(0.0)
	var dx := _kleo.global_position.x - global_position.x if _kleo else dir * lunge_range
	dir = 1 if dx > 0.0 else -1
	# Leap to where she stood, never past its stretch's ends.
	var air := 2.0 * lunge_rise / GRAVITY
	var reach := clampf(absf(dx) + 12.0, 30.0, lunge_speed * air)
	var land_x := clampf(global_position.x + dir * reach, left_x, right_x)
	velocity = Vector2((land_x - global_position.x) / air, -lunge_rise)
	Fx.dust(self, global_position, Fx.JUMP, dir)
	_go(S.LUNGE)


func _touch_kleo() -> void:
	if state in [S.FLINCH, S.DEAD]:
		return
	for body in touch.get_overlapping_bodies():
		if body is Kleo:
			var push := 1 if body.global_position.x >= global_position.x else -1
			body.hurt(push, state == S.LUNGE)


func _flash(v: float) -> void:
	var mat := art.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("flash", v)


func take_hit(hit: Dictionary) -> bool:
	if state == S.DEAD:
		return false
	var from := int(hit.get("dir", 1))
	var thrown := str(hit.get("attack", "")) == "throw"
	hits += 4 if thrown else (2 if int(hit.get("power", 1)) >= 3 else 1)
	_flash(1.0)
	var tw := create_tween()
	tw.tween_method(_flash, 1.0, 0.0, 0.14)
	Fx.burst(self, hit.get("pos", global_position + Vector2(0, -12)), Color(0.42, 0.32, 0.52), 8, 110.0)
	Fx.burst(self, hit.get("pos", global_position + Vector2(0, -12)), Color(0.76, 0.22, 0.35), 4, 90.0)
	if hits >= hits_to_kill:
		_die(from)
		return true
	# The flinch: knocked back, wind-up broken, out of the air.
	dir = -from
	velocity = Vector2(from * 130.0, -70.0)
	_go(S.FLINCH)
	return true


func _die(from: int) -> void:
	state = S.DEAD
	hurtbox.set_deferred("monitorable", false)
	touch.set_deferred("monitoring", false)
	_pose(F_DOWN)
	Fx.burst(self, global_position + Vector2(0, -10), Color(0.42, 0.32, 0.52), 18, 150.0)
	Fx.burst(self, global_position + Vector2(0, -10), Color(0.76, 0.22, 0.35), 10, 120.0)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "position", position + Vector2(from * 18.0, -6.0), 0.25).set_ease(Tween.EASE_OUT)
	tw.tween_property(art, "modulate:a", 0.0, 0.5).set_delay(0.35)
	tw.chain().tween_callback(queue_free)


func is_dead() -> bool:
	return state == S.DEAD
