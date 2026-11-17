class_name AnimaBolt
extends Area2D
## The Anima Spark's shot: a teal bolt flying level from Kleo's hand. It
## strikes the first thing a sword could strike (an enemy, a pot, a chest) and
## bursts; it bursts on a wall, or fades after `reach` px.

const SPEED := 300.0

var dir := 1
var reach := 180.0
var _gone := false
var _t := 0.0

@onready var art: Sprite2D = $Art


func _ready() -> void:
	collision_layer = 0
	collision_mask = 4 | 1   # hurtboxes (areas); the world (bodies)
	area_entered.connect(_on_area)
	body_entered.connect(func(_b: Node) -> void: _burst())
	art.flip_h = dir < 0


func _physics_process(delta: float) -> void:
	if _gone:
		return
	_t += delta
	art.frame = 2 + int(_t * 16.0) % 3
	position.x += dir * SPEED * delta
	reach -= SPEED * delta
	if reach <= 0.0:
		_burst()


func _on_area(area: Area2D) -> void:
	if _gone:
		return
	var target := area.get_parent()
	if target.has_method("take_hit"):
		# After the physics step: what it strikes may add or free bodies.
		_gone = true
		_strike.call_deferred(target)


func _strike(target: Node) -> void:
	if is_instance_valid(target) and target.take_hit({"dir": dir, "power": 1, "attack": "spark", "pos": global_position}):
		Game.hitstop(0.03)
	_gone = false
	_burst()


func _burst() -> void:
	if _gone:
		return
	_gone = true
	Fx.burst(self, global_position, Color(0.4, 0.95, 0.85), 10, 90.0)
	queue_free()


static func make(from: Vector2, facing: int) -> AnimaBolt:
	var b := AnimaBolt.new()
	b.dir = facing
	b.z_index = 11
	var art := Sprite2D.new()
	art.name = "Art"
	art.texture = load("res://assets/characters/kleo/fx_spark.png")
	art.hframes = 8
	art.frame = 2
	b.add_child(art)
	var cs := CollisionShape2D.new()
	var sh := CircleShape2D.new()
	sh.radius = 5.0
	cs.shape = sh
	b.add_child(cs)
	b.position = from
	return b
