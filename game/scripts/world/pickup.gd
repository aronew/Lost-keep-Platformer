class_name Pickup
extends Area2D
## A bead of Resin, the currency (a stand-in name and sprite): it hangs in the
## air, bobbing and turning; when Kleo comes near it drifts to her, and touching
## it adds its value to the count.
##
## A bead taken is at risk until the next checkpoint: if she falls or is
## beaten first, it goes back where it hung (Game.respawn calls `restore`).
## A checkpoint banks it (`bank`): then it stays taken (Game.flags).
##
## A bead can also be spilled (a chest, a broken crate): `launch` throws it in
## an arc; it bounces once on the ground and then hangs where it settled.

@export var value := 1
## A name in Game.flags: set when banked, so it never comes back.
@export var flag := ""

const MAGNET := 30.0  # px: within this it drifts to her
const FRAMES := 6
const GRAVITY := 700.0

var _t := 0.0
var _home := Vector2.ZERO
var _taken := false
var _target: Node2D = null
var _vel := Vector2.ZERO
var _flying := false
var _bounced := false
var _query := PhysicsPointQueryParameters2D.new()

@onready var art: Sprite2D = $Art


func _ready() -> void:
	add_to_group("resin")
	if flag != "" and Game.flags.has(flag):
		queue_free()
		return
	collision_layer = 0
	collision_mask = 2  # the player
	body_entered.connect(_on_body_entered)
	_home = position
	_t = randf() * TAU
	_query.collision_mask = 1 | 64
	_query.collide_with_bodies = true


## Throw it out in an arc (spilled from a chest). It can't be taken for a
## moment, so the spill reads before the beads fly to her.
func launch(vel: Vector2) -> void:
	_vel = vel
	_flying = true
	_bounced = false
	set_deferred("monitoring", false)
	get_tree().create_timer(0.35).timeout.connect(func() -> void:
		if is_instance_valid(self) and not _taken:
			set_deferred("monitoring", true))


func _physics_process(delta: float) -> void:
	if not _flying:
		return
	_vel.y = minf(_vel.y + GRAVITY * delta, 360.0)
	var next := global_position + _vel * delta
	if _vel.y > 0.0 and _solid(next + Vector2(0, 5)):
		if _bounced or _vel.y < 120.0:
			_flying = false
			# settle a little above the ground, and hang there
			while _solid(next + Vector2(0, 5)):
				next.y -= 1.0
			global_position = (next - Vector2(0, 6)).round()
			_home = position
			return
		_bounced = true
		_vel = Vector2(_vel.x * 0.5, -_vel.y * 0.35)
		return
	if _solid(next + Vector2(signf(_vel.x) * 4.0, 0)):
		_vel.x = -_vel.x * 0.4
		next.x = global_position.x
	global_position = next


func _solid(p: Vector2) -> bool:
	_query.position = p
	return not get_world_2d().direct_space_state.intersect_point(_query, 1).is_empty()


func _process(delta: float) -> void:
	if _taken:
		return
	_t += delta
	art.frame = int(_t * 8.0) % FRAMES
	if _flying:
		return
	if _target == null:
		for k in get_tree().get_nodes_in_group("player"):
			if (k as Node2D).global_position.distance_to(global_position + Vector2(0, 12)) < MAGNET:
				_target = k
	if _target:
		var to: Vector2 = _target.global_position + Vector2(0, -14) - global_position
		global_position += to.normalized() * min(to.length(), 220.0 * delta)
	else:
		position = _home + Vector2(0, roundf(sin(_t * 2.6) * 2.0))


func _on_body_entered(body: Node) -> void:
	if _taken or not (body is Kleo):
		return
	_taken = true
	Game.take_resin(self, value)
	Fx.burst(self, global_position, Color(1.0, 0.8, 0.4), 8, 70.0)
	set_deferred("monitoring", false)
	var tw := create_tween()
	tw.tween_property(art, "scale", Vector2(1.6, 1.6), 0.12)
	tw.parallel().tween_property(art, "modulate:a", 0.0, 0.12)


## A checkpoint banked it: it is gone for good.
func bank() -> void:
	if flag != "":
		Game.flags[flag] = true
	queue_free()


## She fell before banking it: it hangs where it was again.
func restore() -> void:
	_taken = false
	_target = null
	position = _home
	art.scale = Vector2.ONE
	art.modulate.a = 1.0
	set_deferred("monitoring", true)


## Taken now or before (for tests and the tally).
func is_taken() -> bool:
	return _taken


## A new bead, ready to add to the level (chests and breakables spill these).
static func make(bead_value: int, bead_flag: String) -> Pickup:
	var p := Area2D.new()
	p.name = "Resin"
	p.set_script(load("res://scripts/world/pickup.gd"))
	p.set("value", bead_value)
	p.set("flag", bead_flag)
	p.z_index = 15
	var cs := CollisionShape2D.new()
	var cc := CircleShape2D.new()
	cc.radius = 6.0
	cs.shape = cc
	p.add_child(cs)
	var art_node := Sprite2D.new()
	art_node.name = "Art"
	art_node.texture = load("res://assets/items/resin.png")
	art_node.hframes = 6
	art_node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var m := CanvasItemMaterial.new()
	m.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	art_node.material = m
	p.add_child(art_node)
	return p as Pickup
