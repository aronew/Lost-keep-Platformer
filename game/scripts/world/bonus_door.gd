class_name BonusDoor
extends Area2D
## A hidden way into a bonus area (BonusZone): a hollow, a doorway behind ivy,
## off the main line, glowing faintly with Anima. Walking into it takes her
## there. `Return` (a Marker2D) is where she comes back out.

@export var zone_path: NodePath
## Which way she faces when she comes back out.
@export var facing := 1

var _zone: BonusZone
var _told := false


func _ready() -> void:
	add_to_group("bonus_door")
	collision_layer = 0
	collision_mask = 2
	_zone = get_node(zone_path) as BonusZone
	body_entered.connect(_on_enter)
	body_exited.connect(func(b: Node) -> void:
		if b is Kleo:
			_told = false)


func _on_enter(body: Node) -> void:
	var kleo := body as Kleo
	if kleo == null or kleo.is_down() or kleo.state != Kleo.State.NORMAL or Game.bonus != null:
		return
	if _zone.won():
		if not _told:
			_told = true
			Game.banner("Bonus cleared", 0.7)
		return
	_zone.begin(kleo, self)


func return_point() -> Vector2:
	return ($Return as Marker2D).global_position


func zone() -> BonusZone:
	return _zone
