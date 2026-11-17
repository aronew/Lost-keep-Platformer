class_name Carriable
extends CharacterBody2D
## A crate or barrel Kleo can lift overhead (interact), carry, and throw
## (attack). Thrown, it flies in an arc and smashes on whatever it meets: the
## ground, a wall, an enemy (which it fells at once), a cracked wall (which it
## breaks open). Down + attack sets it down gently.
##
## When she comes back from a checkpoint, a crate that was used up is back
## where it stood (Game.respawned), so a missed throw is never a dead end.
##
## The node sits at its base. `Art` is the sprite; `Handle` the area she uses
## to lift it; `Hit` the area that strikes while it flies.

enum S { REST, HELD, FLYING, GONE }

@export var chip_color := Color(0.6, 0.42, 0.28)
## Resin it spills when it smashes (once: remembered by `flag`).
@export var resin := 0
@export var flag := ""

const GRAVITY := 760.0

@onready var art: Sprite2D = $Art
@onready var handle: Area2D = $Handle
@onready var hit: Area2D = $Hit

var state := S.REST
var _home := Vector2.ZERO
var _holder: Kleo = null
var _dir := 1
var _spin := 0.0
var _rest_z := 0


func _ready() -> void:
	add_to_group("carriable")
	collision_layer = 0
	collision_mask = 1 | 64
	_home = global_position
	_rest_z = z_index
	hit.collision_layer = 0
	hit.collision_mask = 4  # hurtboxes: enemies, breakables, cracked walls
	hit.monitoring = false
	Game.respawned.connect(_on_respawned)


func can_lift(_kleo: Node) -> bool:
	return state == S.REST


func lift(kleo: Node) -> void:
	if state != S.REST:
		return
	_holder = kleo
	state = S.HELD
	handle.monitorable = false
	kleo.call("pick_up", self)
	# Held behind her, so her hands and hair show in front of it; it follows
	# her hands frame by frame (Kleo.carry_point) as she lifts it.
	z_index = (kleo as CanvasItem).z_index - 1


func throw(vel: Vector2) -> void:
	state = S.FLYING
	z_index = _rest_z
	velocity = vel
	_dir = 1 if vel.x >= 0.0 else -1
	_holder = null
	hit.monitoring = true


func set_down(pos: Vector2) -> void:
	state = S.REST
	z_index = _rest_z
	_holder = null
	global_position = pos.round()
	velocity = Vector2.ZERO
	handle.monitorable = true


func drop() -> void:
	if state != S.HELD:
		return
	state = S.REST
	z_index = _rest_z
	_holder = null
	velocity = Vector2(0, -40)
	handle.monitorable = true


func _physics_process(delta: float) -> void:
	match state:
		S.HELD:
			if is_instance_valid(_holder):
				var to: Vector2 = _holder.call("carry_point")
				global_position = global_position.lerp(to, 0.6).round() if global_position.distance_to(to) > 1.0 else to
				art.flip_h = _holder.facing < 0
		S.REST:
			velocity.y = minf(velocity.y + GRAVITY * delta, 400.0)
			velocity.x = move_toward(velocity.x, 0.0, 600.0 * delta)
			move_and_slide()
			if Game.level and global_position.y > Game.level.room_rect.end.y * 16 + 40:
				_gone(false)
		S.FLYING:
			velocity.y = minf(velocity.y + GRAVITY * delta, 420.0)
			# a tumble in whole flips, so its pixels stay square
			_spin += delta
			if _spin > 0.09:
				_spin = 0.0
				art.flip_h = not art.flip_h
			for a in hit.get_overlapping_areas():
				var target := a.get_parent()
				if target != self and target.has_method("take_hit"):
					var landed: bool = target.call("take_hit", {"dir": _dir, "power": 3, "attack": "throw",
						"pos": global_position + Vector2(0, -8)})
					if landed:
						Game.hitstop(0.06)
						Game.shake(0.2)
						_smash()
						return
			var c := move_and_collide(velocity * delta)
			if c:
				# Something solid it can break (a cracked wall) takes the blow.
				var body := c.get_collider()
				if body and body.has_method("take_hit"):
					body.call("take_hit", {"dir": _dir, "power": 3, "attack": "throw", "pos": c.get_position()})
					Game.hitstop(0.06)
					Game.shake(0.2)
				_smash()
				return
			if Game.level and global_position.y > Game.level.room_rect.end.y * 16 + 40:
				_gone(false)


func _smash() -> void:
	Sfx.play("smash")
	var r := art.region_rect
	var grid := Vector2i(3 if r.size.x >= 26.0 else 2, 3 if r.size.y >= 26.0 else 2)
	var pw := floorf(r.size.x / grid.x)
	var ph := floorf(r.size.y / grid.y)
	var host := get_parent()
	for i in grid.x:
		for j in grid.y:
			var piece := Debris.new()
			piece.texture = art.texture
			piece.region_enabled = true
			piece.region_rect = Rect2(r.position.x + i * pw, r.position.y + j * ph, pw, ph)
			piece.z_index = z_index
			piece.life = randf_range(1.2, 1.8)
			piece.velocity = Vector2(_dir * randf_range(-30.0, 80.0) + (i - 1) * 60.0, -randf_range(120.0, 200.0))
			host.add_child(piece)
			piece.global_position = (art.global_position + Vector2(i * pw + pw * 0.5, j * ph + ph * 0.5)).round()
	Fx.burst(self, global_position + Vector2(0, -10), chip_color, 16, 120.0)
	Fx.dust(self, global_position, Fx.LANDING, _dir)
	if resin > 0 and not (flag != "" and Game.flags.has(flag)):
		if flag != "":
			Game.flags[flag] = true
		for i in resin:
			var p := Pickup.make(1, "")
			host.add_child(p)
			p.global_position = (global_position + Vector2(0, -10)).round()
			p.launch(Vector2(randf_range(-60.0, 60.0), -170.0))
	_gone(true)


func _gone(_smashed: bool) -> void:
	state = S.GONE
	visible = false
	hit.set_deferred("monitoring", false)
	handle.set_deferred("monitorable", false)
	set_physics_process(false)


## Back where it stood (she came back from a checkpoint).
func _on_respawned() -> void:
	if state == S.HELD or state == S.GONE or state == S.FLYING:
		state = S.REST
		_holder = null
		z_index = _rest_z
		visible = true
		velocity = Vector2.ZERO
		global_position = _home
		handle.set_deferred("monitorable", true)
		hit.set_deferred("monitoring", false)
		set_physics_process(true)


func is_gone() -> bool:
	return state == S.GONE
