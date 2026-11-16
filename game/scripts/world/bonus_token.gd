class_name BonusToken
extends Area2D
## A bonus area's prize, a gold token with a Prism shard on it (as Donkey Kong
## Country 2's Kremkoins): won by gathering every bead in time, or found at the
## end of a short course. Its zone shows it and hears when it is taken.
##
## `Art` is the sprite (items/token.png, 4 turning frames).

## A name in Game.flags.
@export var flag := ""

signal taken

@onready var art: Sprite2D = $Art

var _t := 0.0
var _taken := false


func _ready() -> void:
	add_to_group("bonus_token")
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_t += delta
	art.frame = int(_t * 7.0) % 4
	art.position.y = roundf(sin(_t * 2.0) * 2.0)


## Show it (and let it be taken) or hide it.
func show_token(on: bool) -> void:
	visible = on
	set_deferred("monitoring", on)
	if on:
		_taken = false
		art.modulate.a = 1.0
		Fx.burst(self, global_position, Color(0.62, 0.9, 0.96), 16, 90.0)


func _on_body_entered(body: Node) -> void:
	if _taken or not visible or not (body is Kleo):
		return
	_taken = true
	set_deferred("monitoring", false)
	Game.take_token(flag)
	Fx.burst(self, global_position, Color(1.0, 0.86, 0.5), 18, 110.0)
	Game.hitstop(0.05)
	var tw := create_tween()
	tw.tween_property(art, "position:y", art.position.y - 16.0, 0.3).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(art, "modulate:a", 0.0, 0.3).set_delay(0.1)
	taken.emit()
