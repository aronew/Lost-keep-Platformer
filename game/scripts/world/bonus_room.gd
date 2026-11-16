class_name BonusRoom
extends Node2D
## A bonus room behind a secret (a cracked wall): a little game against the
## clock. When Kleo steps in, beads of Resin light up around the room and a
## countdown starts; gather every one before it runs out and the room gives
## its prize (its `Reward`: a cocoon, a spill of Resin). Run out of time and
## the beads go dark; step out and back in to try again. Won, it stays won.
##
## `Zone` covers the room; `Beads` holds the beads (Area2D, each with a
## sprite `Art`); `Reward` is shown when she wins.

@export var time_limit := 10.0
@export var flag := ""
@export var prize_resin := 10

@onready var zone: Area2D = $Zone
@onready var beads: Node2D = $Beads
@onready var reward: Node2D = $Reward

enum S { IDLE, RUNNING, FAILED, WON }
var state := S.IDLE
var _left := 0.0
var _t := 0.0


func _ready() -> void:
	add_to_group("bonus_room")
	zone.collision_layer = 0
	zone.collision_mask = 2
	zone.body_entered.connect(_on_enter)
	zone.body_exited.connect(_on_exit)
	for b in beads.get_children():
		var a := b as Area2D
		a.collision_layer = 0
		a.collision_mask = 2
		a.body_entered.connect(_on_bead.bind(a))
	if flag != "" and Game.flags.has(flag):
		state = S.WON
		_show_beads(false)
		reward.visible = true
	else:
		_show_beads(false)
		reward.visible = false
		_set_reward_active(false)


func _set_reward_active(on: bool) -> void:
	for n in reward.find_children("*", "Area2D", true, false):
		n.set_deferred("monitorable", on)
		n.set_deferred("monitoring", on)


func _show_beads(on: bool) -> void:
	for b in beads.get_children():
		b.visible = on
		b.set_deferred("monitoring", on)
		b.set_meta("taken", false)


func _on_enter(body: Node) -> void:
	if not (body is Kleo) or state != S.IDLE:
		return
	state = S.RUNNING
	_left = time_limit
	_show_beads(true)
	for b in beads.get_children():
		Fx.burst(self, b.global_position, Color(1.0, 0.82, 0.45), 4, 40.0)
	Game.banner("Gather every bead!", 0.9)


func _on_exit(body: Node) -> void:
	if not (body is Kleo):
		return
	if state == S.FAILED or state == S.RUNNING:
		state = S.IDLE
		_show_beads(false)
		Game.show_timer("")


func _on_bead(body: Node, bead: Area2D) -> void:
	if state != S.RUNNING or not (body is Kleo) or bead.get_meta("taken", false):
		return
	bead.set_meta("taken", true)
	bead.set_deferred("monitoring", false)
	Fx.burst(self, bead.global_position, Color(1.0, 0.8, 0.4), 8, 70.0)
	var tw := bead.create_tween()
	tw.tween_property(bead, "scale", Vector2(1.6, 1.6), 0.1)
	tw.tween_callback(func() -> void:
		bead.visible = false
		bead.scale = Vector2.ONE)
	if remaining() == 0:
		_win.call_deferred()


func remaining() -> int:
	var n := 0
	for b in beads.get_children():
		if not b.get_meta("taken", false):
			n += 1
	return n


func _process(delta: float) -> void:
	_t += delta
	for b in beads.get_children():
		var art := b.get_node_or_null("Art") as Sprite2D
		if art:
			art.frame = int(_t * 8.0 + b.position.x) % 6
	if state != S.RUNNING:
		return
	_left -= delta
	Game.show_timer("%d" % ceili(maxf(_left, 0.0)))
	if _left <= 0.0:
		state = S.FAILED
		Game.show_timer("")
		Game.banner("Out of time", 0.9)
		for b in beads.get_children():
			if b.visible:
				var tw := b.create_tween()
				tw.tween_property(b, "modulate:a", 0.0, 0.3)
				tw.tween_callback(func() -> void:
					b.visible = false
					b.modulate.a = 1.0)


func _win() -> void:
	state = S.WON
	Game.show_timer("")
	if flag != "":
		Game.flags[flag] = true
	Game.banner("Bonus!", 1.0)
	Game.shake(0.15)
	reward.visible = true
	_set_reward_active(true)
	reward.modulate.a = 0.0
	create_tween().tween_property(reward, "modulate:a", 1.0, 0.4)
	for i in prize_resin:
		var p := Pickup.make(1, "%s_prize_%d" % [flag, i] if flag != "" else "")
		add_child(p)
		p.global_position = reward.global_position + Vector2(0, -24)
		var t := float(i) / maxf(1.0, prize_resin - 1.0) - 0.5
		p.launch(Vector2(t * 200.0, -200.0 - randf() * 40.0))
