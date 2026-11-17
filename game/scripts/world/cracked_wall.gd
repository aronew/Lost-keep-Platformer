class_name CrackedWall
extends StaticBody2D
## A cracked wall: solid, and too strong for her sword (it rings off it with a
## spark), but a thrown crate or barrel smashes it open. Behind it there is
## usually a secret: a hollow, a bonus room. Broken, it stays broken
## (Game.flags).
##
## `Shape` is its collision, `Art` how it looks, `Hurtbox` (a little larger)
## what blows strike.

@export var flag := ""

@onready var art: Node2D = $Art
@onready var hurtbox: Area2D = $Hurtbox

var broken := false


func _ready() -> void:
	add_to_group("cracked_wall")
	if flag != "" and Game.flags.has(flag):
		_open(false)


func take_hit(hit: Dictionary) -> bool:
	if broken:
		return false
	if str(hit.get("attack", "")) != "throw":
		# The sword rings off it: a spark, a jolt, nothing gives.
		Fx.burst(self, hit.get("pos", global_position), Color(0.85, 0.82, 0.9), 5, 70.0)
		art.position.x = int(hit.get("dir", 1))
		Sfx.play("ring_off")
		create_tween().tween_property(art, "position:x", 0.0, 0.08)
		return true
	if flag != "":
		Game.flags[flag] = true
	_open(true)
	return true


func _open(animate: bool) -> void:
	broken = true
	$Shape.set_deferred("disabled", true)
	hurtbox.set_deferred("monitorable", false)
	if not animate:
		art.visible = false
		return
	var box: Rect2 = get_meta("rect", Rect2(-16, -32, 32, 32))
	if has_meta("rubble"):
		# The sheet's own rubble (Book 3's T2), thrown out of the wall.
		var tex: Texture2D = load(get_meta("rubble_tex"))
		for r in get_meta("rubble"):
			var stone := Debris.new()
			stone.texture = tex
			stone.region_enabled = true
			stone.region_rect = r
			stone.life = randf_range(1.2, 1.8)
			stone.velocity = Vector2(randf_range(40.0, 170.0) * (1 if randf() > 0.25 else -1), -randf_range(90.0, 220.0))
			get_parent().add_child(stone)
			stone.global_position = global_position + box.position + Vector2(randf() * box.size.x, randf() * box.size.y)
	for i in (0 if has_meta("rubble") else 10):
		var chunk := Debris.new()
		chunk.texture = load("res://assets/fx/pixel.png")
		chunk.scale = Vector2(randf_range(3.0, 6.0), randf_range(3.0, 6.0)).round()
		chunk.region_enabled = true
		chunk.region_rect = Rect2(0, 0, 1, 1)
		chunk.modulate = Color(0.42, 0.36, 0.5)
		chunk.life = randf_range(0.9, 1.5)
		chunk.velocity = Vector2(randf_range(40.0, 160.0) * (1 if randf() > 0.3 else -1), -randf_range(80.0, 200.0))
		get_parent().add_child(chunk)
		chunk.global_position = global_position + box.position + Vector2(randf() * box.size.x, randf() * box.size.y)
	Fx.burst(self, global_position + box.get_center(), Color(0.6, 0.55, 0.66), 24, 140.0)
	Fx.dust(self, global_position + Vector2(box.get_center().x, box.end.y), Fx.HARD_LANDING, 1)
	Game.shake(0.35)
	Sfx.play("smash_stone")
	var tw := create_tween()
	tw.tween_property(art, "modulate:a", 0.0, 0.18)
	tw.tween_callback(func() -> void: art.visible = false)
