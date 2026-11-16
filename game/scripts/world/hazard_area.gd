class_name HazardArea
extends Area2D
## A hazard Kleo must not touch. Thorns are a hit: a flame, and they throw her
## back out the way she came (the creative lead "had no idea why I was dying"
## when thorns sent her to the checkpoint). Anything else (deep water) costs a
## flame and sends her back to the last checkpoint (Kleo.hazard). Pits need no
## area: the room catches a fall out of its bottom edge.

@export var kind := "thorns"


func _ready() -> void:
	add_to_group("hazard")
	collision_layer = 0
	collision_mask = 2  # the player
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body is Kleo:
		_touch(body)


func _touch(kleo: Kleo) -> void:
	if kind == "thorns":
		var centre := global_position.x
		for c in get_children():
			if c is CollisionShape2D:
				centre = (c as CollisionShape2D).global_position.x
		var dir := int(signf(kleo.global_position.x - centre))
		if dir == 0:
			dir = -kleo.facing
		kleo.hurt(dir, true, 1)
		Fx.burst(kleo, kleo.global_position + Vector2(0, -6), Color(0.86, 0.78, 0.62), 12, 110.0)
	else:
		kleo.hazard(kind)


func _physics_process(_delta: float) -> void:
	# She may already be inside when she comes back from a respawn with
	# invulnerability: check again while anything overlaps.
	for body in get_overlapping_bodies():
		if body is Kleo and not body.is_down() and body.state != Kleo.State.LOCKED:
			_touch(body)
