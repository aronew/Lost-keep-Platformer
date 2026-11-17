extends Node
## Checks of the game's shell: the sounds, the pause menu, and getting up
## after a heavy blow. Run:
##   xvfb-run -a godot --path . --fixed-fps 60 --audio-driver Dummy res://tests/checks.tscn
## Prints PASS / FAIL lines and ALL PASS; exits 1 on a failure.

var _fails := 0
var _kleo: Kleo


func _check(ok: bool, what: String, note := "") -> void:
	print(("PASS " if ok else "FAIL ") + what + ("  (" + note + ")" if note != "" else ""))
	if not ok:
		_fails += 1


func _press(action: String, on := true) -> void:
	var e := InputEventAction.new()
	e.action = action
	e.pressed = on
	Input.parse_input_event(e)


func _ticks(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


func _ready() -> void:
	Game.save_enabled = false
	Game.flags.clear()
	var level: Node = load("res://scenes/levels/systems_arena.tscn").instantiate()
	add_child(level)
	_kleo = level.get_node("Kleo")
	await _ticks(30)

	# --- The sounds
	var missing := []
	for cue in Sfx.CUES.keys() + Sfx.VOICE.keys():
		if (Sfx._takes.get(cue, []) as Array).is_empty():
			missing.append(cue)
	_check(missing.is_empty(), "every sound cue has a file", ", ".join(missing))
	Sfx.play("jump")
	var sounding := false
	for p in Sfx._players:
		if p.playing:
			sounding = true
	_check(sounding, "a cue plays")
	var shouts := 0
	for i in 40:
		Sfx._last_time.erase("shout")
		Sfx._voice.stop()
		Sfx.voice("shout")
		if Sfx._voice.playing:
			shouts += 1
	_check(shouts > 8 and shouts < 32, "a light swing shouts only some of the time", "%d of 40" % shouts)
	Sfx.voice("shout_heavy")
	_check(Sfx._voice.playing and Sfx._voice.stream.resource_path.contains("vo_swing_heavy"), "a heavy swing always shouts, cutting off the last")

	# --- The pause menu
	_press("pause")
	await get_tree().process_frame
	await get_tree().process_frame
	_check(get_tree().paused and Game.is_paused(), "pause stops the level")
	_press("pause", false)
	var y := _kleo.global_position.y
	_press("jump")  # chooses Resume
	await get_tree().process_frame
	await get_tree().process_frame
	_check(not get_tree().paused and not Game.is_paused(), "Resume goes on")
	_press("jump", false)
	await _ticks(6)
	_check(absf(_kleo.global_position.y - y) < 1.0 and _kleo.is_on_floor(), "the press that resumed is not a jump", "y %.1f -> %.1f, floor %s, %s" % [y, _kleo.global_position.y, _kleo.is_on_floor(), _kleo.debug_text()])
	_press("pause")
	await get_tree().process_frame
	await get_tree().process_frame
	_press("pause", false)
	_press("move_down")
	await get_tree().process_frame
	_press("move_down", false)
	_press("jump")
	await get_tree().process_frame
	_press("jump", false)
	await get_tree().process_frame
	_check(get_tree().paused and Game._leave_armed, "leaving the level asks once more")
	_press("pause")
	await get_tree().process_frame
	await get_tree().process_frame
	_press("pause", false)
	_check(not get_tree().paused, "pause again closes the menu")
	await _ticks(10)

	# --- A heavy blow: how long she is down, how long she is safe after
	_kleo._invuln = 0.0
	_kleo.hurt(-1, true)
	var down := 0
	while _kleo.state == Kleo.State.HURT and down < 300:
		await get_tree().physics_frame
		down += 1
	var safe := _kleo._invuln
	_check(_kleo.state == Kleo.State.NORMAL and safe >= 0.55, "after a heavy blow she is safe for a moment on her feet",
		"down %.2f s, then safe %.2f s" % [down / 60.0, safe])
	await _ticks(90)
	_kleo._invuln = 0.0
	Game.health = Game.max_health
	_kleo.hurt(-1, true)
	_press("move_right")
	var down_held := 0
	while _kleo.state == Kleo.State.HURT and down_held < 300:
		await get_tree().physics_frame
		down_held += 1
	_press("move_right", false)
	_check(down_held < down - 6, "moving gets her up early", "%.2f s against %.2f s" % [down_held / 60.0, down / 60.0])
	_check(_kleo._invuln >= 0.55, "and she is still safe for a moment", "%.2f s" % _kleo._invuln)

	print("ALL PASS" if _fails == 0 else "%d FAILED" % _fails)
	get_tree().quit(1 if _fails > 0 else 0)
