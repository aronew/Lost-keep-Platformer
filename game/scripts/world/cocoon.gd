extends Interactable
## A cocoon: one of the missing, sealed in silk. Kleo uses it (interact) and
## cuts it open; the one inside is free, and goes to the Refuge. Three hide in
## every level: they are the game's main collectible (Game.rescue, the HUD's
## cocoons at top right).
##
## Its parent holds `Sealed` and `Open` (the two sprites); this area is the
## part she reaches.

## A name in Game.flags (and Game.rescued).
@export var flag := ""
## Who is inside, for the line on screen.
@export var who := "a villager"

var freed := false


func _ready() -> void:
	super()
	add_to_group("cocoon")
	freed = flag != "" and Game.rescued.has(flag)
	_show()
	if flag != "":
		Game.register_cocoon.call_deferred(flag)


func _show() -> void:
	get_parent().get_node("Sealed").visible = not freed
	get_parent().get_node("Open").visible = freed


func can_interact(_kleo: Node) -> bool:
	return not freed


func interact(kleo: Node) -> void:
	if freed:
		return
	freed = true
	kleo.call("perform", "rescue", 0.7)
	Game.hitstop(0.05)
	var sealed: Sprite2D = get_parent().get_node("Sealed")
	sealed.modulate = Color(1.8, 1.8, 1.8)
	var tw := create_tween()
	tw.tween_interval(0.25)
	tw.tween_callback(func() -> void:
		_show()
		Fx.burst(self, global_position + Vector2(0, -20), Color(0.86, 0.82, 0.92), 18, 100.0)
		Fx.burst(self, global_position + Vector2(0, -20), Color(1.0, 0.8, 0.45), 10, 60.0)
		_rise()
		if flag != "":
			Game.rescue(flag)
		Game.banner("Freed: " + who))


## A warm mote rising away: the one inside, on the way to the Refuge.
func _rise() -> void:
	var mote := Sprite2D.new()
	mote.texture = load("res://assets/fx/mote.png")
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	m.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	mote.material = m
	mote.modulate = Color(1.0, 0.82, 0.5)
	mote.scale = Vector2(2, 2)
	mote.z_index = 25
	get_parent().add_child(mote)
	mote.global_position = global_position + Vector2(0, -24)
	var tw := mote.create_tween()
	tw.set_parallel(true)
	tw.tween_property(mote, "global_position:y", mote.global_position.y - 120.0, 1.6).set_ease(Tween.EASE_IN)
	tw.tween_property(mote, "modulate:a", 0.0, 1.6).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(mote.queue_free)
