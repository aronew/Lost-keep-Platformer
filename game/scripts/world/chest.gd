class_name Chest
extends Node2D
## A chest: strike it and the lid flies back and it spills its Resin in an arc
## of beads that bounce and hang where they land, then drift to Kleo. Opened,
## it stays open (Game.flags).
##
## The node sits at its base (the floor line). `Art` has two frames (shut,
## open); `Hurtbox` is what the sword hits.

@export var resin := 8
@export var flag := ""
@export var hit_weight := 0.5

@onready var art: Sprite2D = $Art
@onready var hurtbox: Area2D = $Hurtbox

var opened := false


func _ready() -> void:
	add_to_group("chest")
	if flag != "" and Game.flags.has(flag):
		opened = true
		art.frame = 1
		hurtbox.monitorable = false


func take_hit(hit: Dictionary) -> bool:
	if opened:
		return false
	opened = true
	if flag != "":
		Game.flags[flag] = true
	hurtbox.set_deferred("monitorable", false)
	var from := int(hit.get("dir", 1))
	# The lid: a jolt, then open.
	art.frame = 1
	art.position.y -= 2.0
	var tw := create_tween()
	tw.tween_property(art, "position:y", art.position.y + 2.0, 0.12).set_ease(Tween.EASE_IN)
	Fx.burst(self, global_position + Vector2(0, -14), Color(1.0, 0.82, 0.45), 14, 90.0)
	Fx.dust(self, global_position, Fx.LANDING, from)
	# The beads, fanned out ahead of the blow and a little behind.
	for i in resin:
		var t := (float(i) / maxf(1.0, resin - 1.0)) - 0.5
		var p := Pickup.make(1, "%s_bead_%d" % [flag, i] if flag != "" else "")
		get_parent().add_child(p)
		p.global_position = (global_position + Vector2(t * 8.0, -16.0)).round()
		p.launch(Vector2(from * 30.0 + t * 170.0, -190.0 - absf(t) * -60.0 - randf() * 50.0))
	return true
