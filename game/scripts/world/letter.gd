class_name Letter
extends Area2D
## One of the level's four letters, K-L-E-O (as Donkey Kong Country's K-O-N-G):
## hung along the way, one or two of them off the main line. Touching it takes
## it (Game.take_letter); all four in one level is a bonus. Taken letters stay
## taken (Game.flags), and the HUD shows which are found (top right).
##
## `Art` is the sprite (items/letters.png, one frame per letter).

const ORDER := "KLEO"

@export var letter := "K"
## A name in Game.flags.
@export var flag := ""

@onready var art: Sprite2D = $Art

var _t := 0.0
var _taken := false


func _ready() -> void:
	add_to_group("letter")
	collision_layer = 0
	collision_mask = 2
	art.frame = maxi(ORDER.find(letter), 0)
	Game.register_letter.call_deferred(letter, flag)
	if flag != "" and Game.flags.has(flag):
		_taken = true
		visible = false
		set_deferred("monitoring", false)
		return
	body_entered.connect(_on_body_entered)
	_t = randf() * TAU


func _process(delta: float) -> void:
	_t += delta
	# A slow bob and a glint: a hard pixel step, never a blur.
	art.position.y = roundf(sin(_t * 2.4) * 2.0)
	art.modulate = Color(1.35, 1.25, 1.1) if fmod(_t, 2.2) < 0.08 else Color.WHITE


func _on_body_entered(body: Node) -> void:
	if _taken or not (body is Kleo):
		return
	_taken = true
	set_deferred("monitoring", false)
	Game.take_letter(letter, flag)
	Fx.burst(self, global_position, Color(1.0, 0.86, 0.5), 14, 90.0)
	Game.hitstop(0.03)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(art, "position:y", art.position.y - 18.0, 0.35).set_ease(Tween.EASE_OUT)
	tw.tween_property(art, "modulate:a", 0.0, 0.35).set_delay(0.12)
	tw.chain().tween_callback(func() -> void: visible = false)


func is_taken() -> bool:
	return _taken
