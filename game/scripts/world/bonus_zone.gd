class_name BonusZone
extends Node2D
## A bonus area: another zone of the level, out of the way, reached through a
## hidden entrance (BonusDoor). Two kinds, as in Donkey Kong Country 1 and 2:
##   "gather": beads light up; gather every one before the time runs out and
##             the token appears.
##   "course": a short run of jumps; reach the token at its end in time.
## Won: she takes the token (Game.take_token) and goes back out, just past the
## entrance. Out of time, or a fall: no prize and back out, with no harm done;
## the entrance stays open to try again. Won stays won (the entrance then only
## says so).
##
## Children: `Start` (Marker2D, where she arrives), `Beads` (gather: Area2Ds
## each with an `Art`), `Token` (a BonusToken). `area` is the zone's rect in
## tiles: the camera and the pit edge hold to it while she is inside.

@export_enum("gather", "course") var kind := "gather"
@export var time_limit := 12.0
@export var area := Rect2i()
@export var title := "Gather every bead!"

@onready var start: Marker2D = $Start
@onready var beads: Node2D = get_node_or_null("Beads")
@onready var token: BonusToken = $Token

enum S { IDLE, ENTERING, RUNNING, ENDING }
var state := S.IDLE
var _left := 0.0
var _t := 0.0
var _door: Node = null
var _kleo: Kleo = null


func _ready() -> void:
	add_to_group("bonus_zone")
	token.taken.connect(_on_token)
	token.visible = false
	token.monitoring = false
	if token.flag != "":
		Game.register_token.call_deferred(token.flag)
	if beads:
		for b in beads.get_children():
			var a := b as Area2D
			a.collision_layer = 0
			a.collision_mask = 2
			a.body_entered.connect(_on_bead.bind(a))
	_show_beads(false)


func won() -> bool:
	return token.flag != "" and Game.flags.has(token.flag)


func running() -> bool:
	return state == S.RUNNING


## In through the hidden entrance: fade out, arrive at `Start`, fade in, go.
func begin(kleo: Kleo, door: Node) -> void:
	if state != S.IDLE:
		return
	state = S.ENTERING
	_door = door
	_kleo = kleo
	if kleo.held and is_instance_valid(kleo.held):
		kleo.held.call("drop")
		kleo.held = null
	kleo.freeze()
	Game.bonus = self
	await Game.fade_to(1.0, 0.25)
	Game.level.call("set_area", area)
	kleo.place(start.global_position, 1)
	_snap_camera()
	_show_beads(kind == "gather")
	token.show_token(kind == "course")
	_left = time_limit
	_show_time()
	await Game.fade_to(0.0, 0.25)
	Game.banner(title, 0.9)
	state = S.RUNNING
	# A bead she already stands in (she walked on through the fade) is hers.
	if beads:
		for b in beads.get_children():
			if (b as Area2D).monitoring and (b as Area2D).overlaps_body(kleo):
				_on_bead(kleo, b as Area2D)


func _process(delta: float) -> void:
	_t += delta
	if beads:
		for b in beads.get_children():
			var art := b.get_node_or_null("Art") as Sprite2D
			if art:
				art.frame = int(_t * 8.0 + b.position.x) % 6
	if state != S.RUNNING or Game.respawning:
		return
	_left -= delta
	_show_time()
	if _left <= 0.0:
		fail("Out of time")


## The countdown, and in a gather how much Resin is still to find.
func _show_time() -> void:
	var text := "%d" % ceili(maxf(_left, 0.0))
	if kind == "gather" and remaining() > 0:
		text += "   %d left" % remaining()
	Game.show_timer(text)


func _show_beads(on: bool) -> void:
	if not beads:
		return
	for b in beads.get_children():
		b.visible = on
		b.set_deferred("monitoring", on)
		b.set_meta("taken", false)
		b.scale = Vector2.ONE


func remaining() -> int:
	var n := 0
	if beads:
		for b in beads.get_children():
			if not b.get_meta("taken", false):
				n += 1
	return n


func _on_bead(body: Node, bead: Area2D) -> void:
	if state != S.RUNNING or not (body is Kleo) or bead.get_meta("taken", false):
		return
	bead.set_meta("taken", true)
	bead.set_deferred("monitoring", false)
	Fx.burst(self, bead.global_position, Color(1.0, 0.8, 0.4), 8, 70.0)
	Sfx.resin()
	var tw := bead.create_tween()
	tw.tween_property(bead, "scale", Vector2(1.6, 1.6), 0.1)
	tw.tween_callback(func() -> void:
		bead.visible = false
		bead.scale = Vector2.ONE)
	if remaining() == 0:
		token.show_token(true)
		Game.banner("The token!", 0.6)


func _on_token() -> void:
	if state != S.RUNNING:
		return
	state = S.ENDING
	Game.show_timer("")
	# Won: the Resin she gathered is hers to keep.
	if kind == "gather" and beads:
		Game.add_currency(beads.get_child_count())
	Game.banner("Bonus!", 0.9)
	Game.shake(0.15)
	await get_tree().create_timer(1.0).timeout
	_leave()


## The time ran out, or she fell: no prize, back out.
func fail(why := "Out of time") -> void:
	if state != S.RUNNING:
		return
	state = S.ENDING
	Game.show_timer("")
	Game.banner(why, 0.8)
	_kleo.freeze()
	await get_tree().create_timer(0.9).timeout
	_leave()


func _leave() -> void:
	await Game.fade_to(1.0, 0.25)
	_close()
	_kleo.place(_door.call("return_point"), int(_door.get("facing")))
	_snap_camera()
	state = S.IDLE
	await Game.fade_to(0.0, 0.3)


## She was sent back to a checkpoint while inside (a defeat): the zone closes.
func abort() -> void:
	_close()
	state = S.IDLE


func _close() -> void:
	Game.show_timer("")
	_show_beads(false)
	token.visible = false
	token.set_deferred("monitoring", false)
	Game.level.call("set_area", Rect2i())
	Game.bonus = null


func _snap_camera() -> void:
	var cam := get_viewport().get_camera_2d()
	if cam and cam.has_method("snap_to_target"):
		cam.snap_to_target()
