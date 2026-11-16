class_name Room
extends Node2D
## A room: its bounds in tiles, where Kleo starts, and the camera's limits.
##
## Doors are Marker2D children of a "Doors" node, each beside a RoomExit. When
## Kleo arrives through a door (Game.arrival_door), she appears at its marker,
## facing into the room.

const TILE := 16

@export var room_rect := Rect2i(0, 0, 120, 40)
@export var spawn := Vector2(224, 384)
## A level of the platformer (as opposed to a carried-over Lost Keep room): it
## shows the whole HUD and ends at a LevelEnd.
@export var is_level := false
@export var level_name := ""

## The part of the room the camera and the pit edge hold to while she is in
## the level (bonus areas lie beside it, out of view). Empty: the whole room.
@export var main_area := Rect2i()

## Falling this far below the area's bottom edge is a pit.
const PIT_DEPTH := 40.0

@onready var kleo: Kleo = $Kleo
@onready var camera: CameraRig = $Camera


## Art hidden in box view (F1), leaving the collision, Kleo and the machines.
const ART_NODES := ["Behind", "PlacedArt", "Front", "PrismShrine/Art", "GuardLift/Frame", "EarthBackWalls", "BackWalls",
	"Foreground", "ForegroundNear", "ForegroundBands", "GroundFronts", "BierHoist/Frame"]


func _ready() -> void:
	add_to_group("box_view")
	var door := get_node_or_null("Doors/" + Game.arrival_door) as Marker2D if Game.arrival_door != "" else null
	Game.arrival_door = ""
	if door:
		kleo.place(door.global_position, int(door.get_meta("facing", 1)))
	else:
		kleo.place(spawn, 1)
	Game.level_begin(self, kleo.global_position, kleo.facing)
	camera.target = kleo
	set_area(Rect2i())
	camera.snap_to_target()


var _area := Rect2i()

## Hold the camera (and the pit edge) to `r`, in tiles: a bonus area while she
## is in one; empty, the level itself.
func set_area(r: Rect2i) -> void:
	if r.size == Vector2i.ZERO:
		r = main_area if main_area.size != Vector2i.ZERO else room_rect
	_area = r
	camera.limit_left = r.position.x * TILE
	camera.limit_top = r.position.y * TILE
	camera.limit_right = r.end.x * TILE
	camera.limit_bottom = r.end.y * TILE
	# The camera eases into these edges itself; the limits above are only a backstop.
	camera.bounds = Rect2(Vector2(r.position * TILE), Vector2(r.size * TILE))


func area() -> Rect2i:
	return _area


func _physics_process(_delta: float) -> void:
	if kleo and kleo.global_position.y > (_area.end.y * TILE) + PIT_DEPTH:
		if Game.bonus and is_instance_valid(Game.bonus):
			Game.bonus.call("fail", "Missed!")
		else:
			kleo.hazard("pit")


func set_box_view(on: bool) -> void:
	for path in ART_NODES:
		var n := get_node_or_null(path)
		if n:
			n.visible = not on
	# Islands that are paintings: their collision tiles show only in the box view.
	var masses := get_node_or_null("Masses")
	if masses and masses.has_meta("under_art"):
		masses.visible = on
