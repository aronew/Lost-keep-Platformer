class_name LevelEnd
extends Area2D
## The level's end: an arched doorway (or a waystone, a gate). Walking into it
## ends the level: Kleo walks on through, the view fades, and the tally shows
## (Resin, cocoons found). `next_scene` is where she goes after ("" stays:
## until the world map exists, the level ends on the tally).

signal finished
@export_file("*.tscn") var next_scene := ""

var done := false


func _ready() -> void:
	add_to_group("level_end")
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if done or not (body is Kleo) or body.is_down():
		return
	done = true
	var kleo := body as Kleo
	kleo.held = null
	kleo.freeze()
	kleo.sprite.play("run")
	var tw := create_tween()
	tw.tween_property(kleo, "global_position:x", kleo.global_position.x + 28.0 * kleo.facing, 0.4)
	await tw.finished
	kleo.sprite.play("idle")
	Game.flags["level_done_" + (Game.level.name if Game.level else "")] = true
	await Game.fade_to(0.85, 0.4)
	var lines := "Level complete\nResin  %d\nCocoons  %d / %d" % [Game.currency, Game.cocoons_found(), Game.level_cocoons.size()]
	Game.banner(lines, 2.4)
	await get_tree().create_timer(3.0).timeout
	finished.emit()
	if next_scene != "":
		Game.go_to(next_scene, "", kleo)
	else:
		await Game.fade_to(0.0, 0.4)
		kleo.release()
