class_name HazardArea
extends Area2D
## A hazard Kleo must not touch: bramble thorns, a spiked root. Touching it
## costs a flame and sends her back to the last checkpoint (Kleo.hazard).
## Pits need no area: the room catches a fall out of its bottom edge.

@export var kind := "thorns"


func _ready() -> void:
	add_to_group("hazard")
	collision_layer = 0
	collision_mask = 2  # the player
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body is Kleo:
		body.hazard(kind)


func _physics_process(_delta: float) -> void:
	# She may already be inside when she comes back from a respawn with
	# invulnerability: check again while anything overlaps.
	for body in get_overlapping_bodies():
		if body is Kleo and not body.is_down() and body.state != Kleo.State.LOCKED:
			body.hazard(kind)
