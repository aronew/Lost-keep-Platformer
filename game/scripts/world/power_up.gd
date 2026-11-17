class_name PowerUp
extends Area2D
## A power-up, as Mario's: found in a level, held one at a time, lost when she
## is hit (the hit costs the power instead of a flame). Touching it gives her
## its power (Game.set_power). Taken, it is gone until she is sent back to a
## checkpoint, when it returns, so a lost power is never a dead end.
##
## `Art` is its sprite (4 turning frames).

@export var kind := "spark"

@onready var art: Sprite2D = $Art

var _t := 0.0
var _taken := false


func _ready() -> void:
	add_to_group("power_up")
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)
	Game.respawned.connect(func() -> void:
		_taken = false
		visible = true
		set_deferred("monitoring", true))
	_t = randf() * TAU


func _process(delta: float) -> void:
	_t += delta
	art.frame = int(_t * 8.0) % 4
	art.position.y = roundf(sin(_t * 2.2) * 2.0)


func _on_body_entered(body: Node) -> void:
	if _taken or not (body is Kleo):
		return
	_taken = true
	visible = false
	set_deferred("monitoring", false)
	Game.set_power(kind)
	Fx.burst(self, global_position, Color(0.4, 0.95, 0.85), 16, 100.0)
	Game.hitstop(0.04)
