class_name ThornKnot
extends Area2D
## A level's great secret: one of Morvath's thorn knots, asleep (pale bark, its
## eye shut). One a level, hidden with more cunning than anything else in it
## (as Donkey Kong Country 2's DK coin). Touching it wakes it: the amber-gold
## eye opens and stays open (Game.take_knot); the world map shows which levels'
## knots are awake.
##
## `Art` is the sprite (items/knot.png: asleep, awake).

## A name in Game.flags.
@export var flag := ""

@onready var art: Sprite2D = $Art

var _t := 0.0
var _awake := false


func _ready() -> void:
	add_to_group("thorn_knot")
	collision_layer = 0
	collision_mask = 2
	Game.register_knot.call_deferred(flag)
	if flag != "" and Game.flags.has(flag):
		_awake = true
		art.frame = 1
		set_deferred("monitoring", false)
		return
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_t += delta
	if _awake:
		# Awake, it watches: a slow amber glint.
		art.modulate = Color(1.25, 1.15, 0.95) if fmod(_t, 3.0) < 0.1 else Color.WHITE
	else:
		art.position.y = roundf(sin(_t * 1.6) * 1.0)


func _on_body_entered(body: Node) -> void:
	if _awake or not (body is Kleo):
		return
	_awake = true
	set_deferred("monitoring", false)
	art.frame = 1
	art.position.y = 0.0
	Game.take_knot(flag)
	Sfx.play("knot")
	Fx.burst(self, global_position, Color(0.95, 0.69, 0.29), 22, 120.0)
	Game.hitstop(0.08)
	Game.shake(0.2)
	var tw := create_tween()
	tw.tween_property(art, "scale", Vector2(1.5, 1.5), 0.12)
	tw.tween_property(art, "scale", Vector2.ONE, 0.25)


func is_awake() -> bool:
	return _awake
