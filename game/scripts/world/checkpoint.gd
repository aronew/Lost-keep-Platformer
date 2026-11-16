class_name Checkpoint
extends Node2D
## The midway checkpoint: an Ironbark Guard's banner on a pole, furled until
## Kleo passes it. Then it unfurls and flies (a puff of amber sparks), and from
## then on a fall or a defeat brings her back here. Reaching it refills her
## flames and banks the Resin she carries (Game.reach_checkpoint). One a
## level, at its middle (the creative lead: "there should be a middle point
## where you get a checkpoint; I don't want lanterns").
##
## The node sits at the pole's foot (the floor line). `Dark` is the furled
## banner and `Lit` the flying one (items/banner.png); `Light` a faint warm
## glow at its top; `Trigger` the area she walks into.

## A name in Game.flags: set when lit, so it stays lit for this visit.
@export var flag := ""
## Where she comes back, relative to the post (beside it, not inside it).
@export var return_offset := Vector2(14, 0)
@export var light_energy := 1.0

@onready var dark: Sprite2D = $Dark
@onready var lit_art: Sprite2D = $Lit
@onready var lamp: PointLight2D = $Light
@onready var trigger: Area2D = $Trigger

var lit := false
var _t := 0.0


func _ready() -> void:
	add_to_group("checkpoint")
	trigger.collision_layer = 0
	trigger.collision_mask = 2
	trigger.body_entered.connect(_on_body_entered)
	_show(flag != "" and Game.flags.has(flag), false)


func _process(delta: float) -> void:
	if lit and lit_art.hframes > 1:
		_t += delta
		lit_art.frame = 1 + int(_t * 5.0) % 2  # flying


func _show(on: bool, animate: bool) -> void:
	lit = on
	dark.visible = not on
	lit_art.visible = on
	if not animate:
		lamp.energy = light_energy if on else 0.0
		lamp.set("_base", lamp.energy)
		return
	var tw := create_tween()
	tw.tween_method(func(v: float) -> void:
		lamp.energy = v
		lamp.set("_base", v), 0.0, light_energy * 1.6, 0.12)
	tw.tween_method(func(v: float) -> void:
		lamp.energy = v
		lamp.set("_base", v), light_energy * 1.6, light_energy, 0.5).set_ease(Tween.EASE_OUT)


func _on_body_entered(body: Node) -> void:
	if not (body is Kleo) or (body as Kleo).is_down():
		return
	var first := not lit
	if first:
		_show(true, true)
		if flag != "":
			Game.flags[flag] = true
		var flame_pos := lamp.global_position
		Fx.burst(self, flame_pos, Color(1.0, 0.75, 0.35), 16, 80.0)
		Fx.burst(self, flame_pos, Color(1.0, 0.92, 0.7), 6, 40.0)
		# the old flame flares in the post's glass for a moment
		lit_art.modulate = Color(1.6, 1.4, 1.1)
		create_tween().tween_property(lit_art, "modulate", Color.WHITE, 0.4)
	Game.reach_checkpoint(global_position + return_offset, 1)
