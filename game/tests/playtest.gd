extends Node
## Test harness: plays the room with scripted input and captures what it sees.
##
##   xvfb-run -a godot --path game --fixed-fps 60 --audio-driver Dummy res://tests/playtest.tscn -- mode=shots
##
## `room=ib03` plays another room (default ib01, the Lantern Clearing); its
## output goes to tests/out/<room>/<mode>/. The surface rooms (`room=ib03`, the
## Ruin Gardens; `room=ib04`, the Gate Road): tour (the main line and out the
## East door), upper (the optional lines and the ways back), doors and enemy.
##
## Modes:
##   shots    screenshots of the room's key places, with art and as the black box
##   tour     the main line, scripted, every second frame saved (for a video)
##   upper    the upper line: island, ledge climb, hard landing, knockback
##   props    breaks pots and barrels, stands on the lift's crossbeam, drops through it
##   edge     runs to the room's west edge on both floors and back (the camera at the room's edge)
##   hitstop  random overlapping hit-stops for 3 s of real time: the game must
##            always come back to full speed (run it without --fixed-fps too)
##   click    checks that a left click attacks and a right click is the spell action
##   map      the whole room in screen-sized tiles, with art and as the black box
##            (stitch with tools/stitch_map.py)
##   measure  measures the jump, running jump and ledge reach; prints the numbers
## Output: tests/out/<mode>/

const ROOMS := {
	"ib01": "res://scenes/rooms/ironbark_test_room.tscn",
	"ib03": "res://scenes/rooms/ironbark_03_ruin_gardens.tscn",
	"ib04": "res://scenes/rooms/ironbark_04_gate_road.tscn",
	"sys": "res://scenes/levels/systems_arena.tscn",
	"l1_1": "res://scenes/levels/l1_1_overgrown_ruins.tscn",
	"l1_2": "res://scenes/levels/l1_2_gate_road.tscn",
}
const TILE := 16.0

var room_id := "ib01"

var room: Node
var kleo: Kleo
var cam: CameraRig
var mode := "shots"
## mode=shots only=<prefix>: just the shots whose names start with it.
var only := ""
var out_dir := ""
var _frame := 0
var _held := {}


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("mode="):
			mode = arg.substr(5)
		if arg.begins_with("room="):
			room_id = arg.substr(5)
		if arg.begins_with("only="):
			only = arg.substr(5)
	out_dir = "res://tests/out/" + ("" if room_id == "ib01" else room_id + "/") + mode
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	# Tests start from nothing and leave the player's save alone.
	Game.save_enabled = false
	Game.flags.clear()
	Game.currency = 0
	if room_id == "map":
		await _map_test()
		get_tree().quit()
		return
	Game.room_host = _swap_room  # doors swap the room under this harness
	await _swap_room(ROOMS[room_id])
	await _frames(2)
	if room_id == "sys":
		match mode:
			"systems":
				await _systems()
			"shots":
				await _shots()
			"map":
				await _map()
		get_tree().quit()
		return
	if room_id == "l1_1":
		match mode:
			"tour":
				await _tour_l1_1()
			"secrets":
				await _secrets_l1_1()
			"shots":
				await _shots()
			"map":
				await _map()
		get_tree().quit()
		return
	if room_id == "l1_2":
		match mode:
			"tour":
				await _tour_l1_2()
			"secrets":
				await _secrets_l1_2()
			"stride":
				await _stride_l1_2()
			"shots":
				await _shots()
			"map":
				await _map()
		get_tree().quit()
		return
	if room_id == "ib03" or room_id == "ib04":
		match mode:
			"shots":
				await _shots()
			"map":
				await _map()
			"tour":
				if room_id == "ib03":
					await _tour_ib03()
				else:
					await _tour_ib04()
			"upper":
				if room_id == "ib03":
					await _lower_ib03()
				else:
					await _upper_ib04()
			"doors":
				await _doors_surface()
			"enemy":
				await _enemy()
		get_tree().quit()
		return
	match mode:
		"shots":
			await _shots()
		"tour":
			await _tour()
		"upper":
			await _upper()
		"map":
			await _map()
		"click":
			await _click()
		"props":
			await _props()
		"hitstop":
			await _hitstop_test()
		"edge":
			await _edge()
		"measure":
			await _measure()
	get_tree().quit()


# --- Helpers ----------------------------------------------------------------------------------

## Load a room in place of the current one (also what a door does, via Game.room_host).
func _swap_room(scene: String) -> void:
	if room:
		# Out of the tree at once, so the new room never sees the old one's tiles
		# and this harness never holds a freed room.
		remove_child(room)
		room.queue_free()
	room = load(scene).instantiate()
	add_child(room)
	kleo = room.get_node("Kleo")
	cam = room.get_node("Camera")


func _frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame
	await get_tree().process_frame


func _capture(name: String) -> void:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(out_dir + "/" + name + ".png")


func _place(tile_x: float, floor_tile_y: float, face := 1) -> void:
	kleo.global_position = Vector2(tile_x * TILE, floor_tile_y * TILE)
	kleo.velocity = Vector2.ZERO
	kleo.facing = face
	cam.snap_to_target()


func _press(action: String) -> void:
	Input.action_press(action)
	_held[action] = true


func _release(action: String) -> void:
	Input.action_release(action)
	_held.erase(action)


func _release_all() -> void:
	for a in _held.keys():
		Input.action_release(a)
	_held.clear()


# --- Shots --------------------------------------------------------------------------------------

func _shots() -> void:
	var places := [
		["01_spawn_shrine", 14.5, 24, 1],
		["02_graveyard", 38.0, 28, 1],
		["03_training_yard", 62.0, 28, -1],
		["04_bridge_moat", 92.0, 28, 1],
		["05_crypt_east", 80.0, 37, -1],
		["06_crypt_west", 44.0, 37, -1],
		["07_west_hall_lift", 23.2, 37, 1],
		["08_island", 40.0, 21, 1],
		["09_root_shelf", 60.0, 17, 1],
		["10_bridge_gap", 100.5, 28, 1],
	]
	if room_id == "l1_1":
		places = SHOTS_L11
		_calm_enemies()
	if room_id == "l1_2":
		places = SHOTS_L12
		_calm_enemies()
		# The bonus areas' Resin, lit as it is while a bonus runs.
		for z in _find("bonus_zone"):
			z._show_beads(true)
	if room_id == "sys":
		places = [["01_arena", 20.0, 20, 1], ["02_bonus", 72.0, 20, 1], ["03_platform", 96.0, 20, 1]]
	if room_id == "ib03":
		places = SHOTS_IB03
	if room_id == "ib04":
		places = SHOTS_IB04
	if only != "":
		places = places.filter(func(p): return String(p[0]).begins_with(only))
	for p in places:
		if room.has_method("set_area"):
			room.call("set_area", p[4] if p.size() > 4 else Rect2i())
		_place(p[1], p[2], p[3])
		# long enough for a banner set off by the shot before (1.5 s) to fade
		await _frames(100 if room_id.begins_with("l1_") else 40)
		await _capture(p[0])
	get_tree().call_group("box_view", "set_box_view", true)
	for p in places:
		if room.has_method("set_area"):
			room.call("set_area", p[4] if p.size() > 4 else Rect2i())
		_place(p[1], p[2], p[3])
		await _frames(6)
		await _capture(p[0] + "_box")
	get_tree().call_group("box_view", "set_box_view", false)


# --- Tours --------------------------------------------------------------------------------------
# Goal-driven: hold keys until something is true in the world, so each tour walks a real route.

var _n := 0
var _log: FileAccess
var _cam_log: FileAccess


## One frame of a tour. `physics_frame` fires just before the frame's physics
## runs, so wait for `process_frame` too: the log then holds this frame's result.
func _step() -> void:
	await get_tree().physics_frame
	await get_tree().process_frame
	# Every frame: Kleo and the view, for tools/camera_report.py.
	var view := cam.get_screen_center_position()
	_cam_log.store_line("%.2f,%.2f,%.2f,%.2f" % [kleo.global_position.x, kleo.global_position.y, view.x, view.y])
	if _n % 2 == 0:
		await _capture("f%04d" % (_n / 2))
		var sp := kleo.get_global_transform_with_canvas().origin
		_log.store_line("%d,%d,%d,%s,%d,%d,%d" % [_n / 2, int(sp.x), int(sp.y), kleo.sprite.animation,
			kleo.sprite.frame, int(kleo.global_position.x), int(kleo.global_position.y)])
	_n += 1


func _wait(frames: int) -> void:
	for i in frames:
		await _step()


func _hold_until(actions: Array, done: Callable, limit := 900) -> void:
	for a in actions:
		_press(a)
	for i in limit:
		await _step()
		if done.call():
			break
	_release_all()


func _tap(action: String) -> void:
	_press(action)
	await _step()
	_release(action)


func _start_tour() -> void:
	_log = FileAccess.open(out_dir + "/kleo.csv", FileAccess.WRITE)
	_cam_log = FileAccess.open(out_dir + "/camera.csv", FileAccess.WRITE)
	var rr: Rect2i = room.room_rect
	_cam_log.store_line("#room,%d,%d" % [rr.size.x * TILE, rr.size.y * TILE])
	_n = 0


## The main line: down from the shrine, the training yard, the drop into the
## crypt, west to the hall, the winch, the lift back up, and rest at the shrine.
func _tour() -> void:
	_place(14.5, 24, 1)
	await _frames(20)
	_start_tour()
	await _wait(24)
	await _hold_until(["move_right"], func(): return kleo.global_position.y > 440.0 and kleo.is_on_floor())
	await _hold_until(["move_right"], func(): return kleo.global_position.x > 932.0)
	await _wait(8)
	for i in 4:
		await _tap("attack")
		await _wait(14 if i < 3 else 40)
	await _hold_until(["move_right"], func(): return kleo.global_position.x > 1205.0)
	await _wait(12)
	await _hold_until(["move_right"], func(): return kleo.global_position.y > 585.0 and kleo.is_on_floor())
	await _wait(20)
	await _hold_until(["move_left"], func(): return kleo.global_position.x < 376.0)
	await _wait(10)
	await _tap("interact")
	await _wait(170)
	await _hold_until(["move_right"], func(): return kleo.global_position.x > 412.0)
	await _wait(230)
	await _hold_until(["move_left"], func(): return kleo.global_position.x < 240.0)
	await _wait(8)
	await _tap("interact")
	await _wait(100)
	_release_all()


## The upper line: terrace to the island, a ledge climb to the root shelf, a
## long drop to a hard landing, then a heavy blow and the knockback slide.
func _upper() -> void:
	_place(25.0, 24, 1)
	await _frames(20)
	_start_tour()
	await _wait(16)
	await _hold_until(["move_right"], func(): return kleo.global_position.x > 452.0)
	await _hold_until(["move_right", "jump"], func(): return kleo.is_on_floor() and kleo.global_position.y < 340.0)
	await _wait(10)
	await _hold_until(["move_right"], func(): return kleo.global_position.x > 744.0)
	await _hold_until(["move_right", "jump"], func(): return kleo.state == Kleo.State.LEDGE_HANG)
	await _wait(6)
	await _hold_until(["jump"], func(): return kleo.state == Kleo.State.NORMAL and kleo.is_on_floor())
	await _wait(14)
	await _hold_until(["move_right"], func(): return kleo.global_position.x > 1000.0)
	await _hold_until(["move_right"], func(): return kleo.is_on_floor() and kleo.global_position.y > 440.0)
	await _wait(40)
	kleo.hurt(-1, true)
	await _wait(70)
	await _tap("jump")
	await _wait(10)
	await _tap("attack")
	await _wait(30)
	_release_all()


# --- Props ----------------------------------------------------------------------------------------

func _props() -> void:
	_start_tour()
	var lines := []
	# Break the hall's stores with the combo, walking along them.
	var before := get_tree().get_nodes_in_group("breakable").size()
	_place(8.0, 37, 1)
	await _frames(6)
	for i in 6:
		await _tap("attack")
		await _wait(12)
	await _hold_until(["move_right"], func(): return kleo.global_position.x > 13.5 * TILE, 120)
	for i in 6:
		await _tap("attack")
		await _wait(12)
	await _wait(40)
	var after := get_tree().get_nodes_in_group("breakable").size()
	lines.append("breakables: %d before, %d after the combo in the hall" % [before, after])
	var settle := Time.get_ticks_usec()
	while Engine.time_scale < 1.0 and Time.get_ticks_usec() - settle < 1000000:
		await get_tree().process_frame
	lines.append("game speed after breaking: %.2f (back to full speed in %.3f s of real time)" %
		[Engine.time_scale, (Time.get_ticks_usec() - settle) / 1000000.0])
	# Jump onto the crossbeam (3 tiles up) from the terrace beside it.
	_place(21.0, 24, 1)
	await _frames(6)
	await _hold_until(["move_right"], func(): return kleo.global_position.x > 22.6 * TILE, 60)
	await _hold_until(["move_right", "jump"], func(): return kleo.is_on_floor() and kleo.global_position.y < 24 * TILE - 40, 80)
	await _wait(20)
	var on_beam := kleo.is_on_floor() and absf(kleo.global_position.y - (24 * TILE - 48)) < 1.0
	lines.append("stood on the crossbeam: %s (feet at %.0f, beam top %d)" % [on_beam, kleo.global_position.y, 24 * TILE - 48])
	# Drop back through it.
	_press("move_down")
	await _wait(2)
	await _tap("jump")
	await _wait(40)
	_release_all()
	lines.append("dropped through it: %s (feet at %.0f)" % [kleo.global_position.y > 24 * TILE - 4, kleo.global_position.y])
	var text := "\n".join(lines)
	print(text)
	FileAccess.open(out_dir + "/props.txt", FileAccess.WRITE).store_string(text + "\n")


# --- Room IB-02 ---------------------------------------------------------------------------------

func _floor_at(row: int) -> bool:
	return kleo.is_on_floor() and absf(kleo.global_position.y - row * TILE) < 2.0


## Walk to an edge and step off it, as a player would to drop to what is below.
func _step_off(key: String, past_x: float, row: int) -> bool:
	var dir := 1 if key == "move_right" else -1
	await _hold_until([key], func(): return dir * (kleo.global_position.x - past_x) > 0.0 or (not kleo.is_on_floor() and dir * (kleo.global_position.x - past_x) > -24.0), 300)
	_release_all()
	for i in 200:
		await _step()
		if kleo.is_on_floor() and i > 4:
			break
	await _wait(6)
	if not _floor_at(row):
		print("  step off past %.0f to row %d: at x %.0f, y %.1f, floor %s" % [past_x, row, kleo.global_position.x, kleo.global_position.y, kleo.is_on_floor()])
	return _floor_at(row)


## Jump from where she stands to a floor in [x0, x1] on `row`. A climb (the
## target four or more rows up: a ledge catch) is jumped from standing at `from_x`, steering
## toward the target only near the top, so she rises beside its edge and
## catches it. Any other jump is run at from `from_x` and taken off at
## `takeoff_x` (by default straight away), steering so she comes down over it.
func _jump_to(from_x: float, x0: float, x1: float, row: int, takeoff_x := -1.0) -> bool:
	var dir := 1 if x0 > from_x else -1
	var start_row := int(roundf(kleo.global_position.y / TILE))
	var climb := row <= start_row - 4
	if kleo.global_position.x > from_x:
		await _hold_until(["move_left"], func(): return kleo.global_position.x <= from_x, 300)
	else:
		await _hold_until(["move_right"], func(): return kleo.global_position.x >= from_x, 300)
	await _wait(6)
	var mid := (x0 + x1) * 0.5
	var key := "move_right" if dir > 0 else "move_left"
	if not climb:
		_press(key)
		if takeoff_x >= 0.0:
			await _hold_until([key], func(): return dir * (kleo.global_position.x - takeoff_x) >= 0.0, 200)
			_press(key)
		else:
			await _wait(4)
	_press("jump")
	for i in 150:
		await _step()
		if climb and i == 10:
			_press(key)
		if dir * (kleo.global_position.x - mid) > -8.0:
			_release(key)
		if kleo.state == Kleo.State.LEDGE_HANG:
			_press(key)
		if kleo.is_on_floor() and i > 4 and kleo.state == Kleo.State.NORMAL:
			break
	_release_all()
	await _wait(8)
	var ok := _floor_at(row) and kleo.global_position.x >= x0 - 6.0 and kleo.global_position.x <= x1 + 6.0
	if not ok:
		print("  jump to row %d [%.0f, %.0f] from %.0f missed: at x %.0f, y %.0f" % [row, x0, x1, from_x, kleo.global_position.x, kleo.global_position.y])
	return ok


const SHOTS_L11 := [
	["01_start_terraces_stall", 12.0, 30, 1],
	["02_water_pit_mushroom_island", 61.0, 30, 1],
	["03_chest_block", 88.0, 25, 1],
	["04_plateau_rat", 112.0, 24, 1],
	["05_log_and_gap", 139.5, 24, 1],
	["06_false_wall", 186.0, 30, -1],
	["07_midway_banner_crate", 203.0, 30, 1],
	["07b_root_bank_crates", 238.5, 27, 1],
	["08_hill_false_wall", 226.0, 30, 1],
	["09_canopy_route", 248.0, 18, 1],
	["10_hidden_cave", 250.0, 34, 1],
	["11_islands", 310.5, 26, 1],
	["12_pits_thorns", 360.0, 30, 1],
	["13_end_doorway", 420.0, 24, 1],
	# The bonus areas, beside the level: the camera holds to each one's area.
	["14_bonus_gather", 470.0, 30, 1, Rect2i(452, 16, 40, 24)],
	["15_bonus_course", 512.0, 27, 1, Rect2i(496, 16, 40, 24)],
]
const SHOTS_IB03 := [
	["01_start_road", 2.5, 37, 1],
	["02_west_hill", 20.0, 31, 1],
	["03_hill_top_stepping", 28.0, 28, 1],
	["04_great_island", 52.0, 22, 1],
	["05_log_to_cliff", 68.0, 22, 1],
	["06_exit_arch", 87.0, 16, 1],
	["07_garden", 45.0, 37, 1],
	["08_low_island", 49.0, 31, 1],
	["09_cave", 75.0, 33, -1],
]
const SHOTS_IB04 := [
	["01_arrival_hilltop", 4.0, 16, 1],
	["02_terraces", 22.0, 22, 1],
	["03_great_island", 36.0, 16, 1],
	["04_second_island", 58.0, 20, 1],
	["05_lower_terraces", 38.0, 29, 1],
	["06_high_path", 92.0, 19, 1],
	["07_pool_low_path", 96.0, 36, 1],
	["08_road_end", 123.0, 37, 1],
]


## IB-03's main line: the road, the hill's stairs and its jump, the stepping
## island, the great island, the log, the cliff's stairs, and out the East door.
func _tour_ib03() -> void:
	var lines := []
	_start_tour()
	await _wait(30)
	await _hold_until(["move_right"], func(): return _floor_at(34), 300)
	lines.append("up the first flight onto the hill: %s" % _floor_at(34))
	await _hold_until(["move_right"], func(): return kleo.global_position.x > 15.3 * TILE, 200)
	await _hold_until(["move_right", "jump"], func(): return _floor_at(31), 200)
	lines.append("jumped up the three-tile step: %s" % _floor_at(31))
	await _hold_until(["move_right"], func(): return _floor_at(28) and kleo.global_position.x > 384, 300)
	lines.append("up the second flight to the hill's top: %s" % _floor_at(28))
	await _hold_until(["move_right"], func(): return kleo.global_position.x > 29.4 * TILE, 200)
	await _hold_until(["move_right", "jump"], func(): return _floor_at(25), 200)
	lines.append("hill top to the stepping island (3 across, 3 up): %s (x %.0f)" % [_floor_at(25), kleo.global_position.x])
	await _hold_until(["move_right"], func(): return kleo.global_position.x > 36.4 * TILE, 200)
	await _hold_until(["move_right", "jump"], func(): return _floor_at(22), 200)
	lines.append("stepping island to the great island (2 across, 3 up): %s (x %.0f)" % [_floor_at(22), kleo.global_position.x])
	await _hold_until(["move_right"], func(): return _floor_at(22) and kleo.global_position.x > 71.5 * TILE, 700)
	lines.append("across the great island and the log onto the cliff: %s (x %.0f)" % [_floor_at(22), kleo.global_position.x])
	await _hold_until(["move_right"], func(): return _floor_at(16), 400)
	lines.append("up the cliff's two flights to the arch: %s" % _floor_at(16))
	await _hold_until(["move_right"], func(): return room.name != "IronbarkRuinGardens", 400)
	await _wait(50)
	lines.append("out the East door into: %s, standing at x %.0f, y %.0f, on the floor: %s" % [room.name, kleo.global_position.x, kleo.global_position.y, kleo.is_on_floor()])
	_release_all()
	_report(lines, "tour")


## IB-03's garden under the islands: the way back up to the hill (two ledge
## catches), the cave, and the low island.
func _lower_ib03() -> void:
	var lines := []
	_place(45.0, 37, -1)
	await _frames(10)
	_start_tour()
	await _hold_until(["move_left"], func(): return kleo.global_position.x < 35.7 * TILE, 300)
	await _hold_until(["move_left", "jump"], func(): return _floor_at(33), 300)
	var a := _floor_at(33)
	await _hold_until(["move_left"], func(): return kleo.global_position.x < 30.7 * TILE, 200)
	await _hold_until(["move_left", "jump"], func(): return _floor_at(28), 300)
	lines.append("garden back up to the hill's top (ledge catches of 4 and 5 tiles): %s, %s" % [a, _floor_at(28)])
	_place(52.0, 37, 1)
	await _wait(10)
	await _hold_until(["move_right"], func(): return kleo.global_position.x > 56.3 * TILE, 200)
	await _hold_until(["move_right", "jump"], func(): return _floor_at(33), 300)
	await _hold_until(["move_right"], func(): return kleo.global_position.x > 76 * TILE, 400)
	lines.append("up the cliff's shelf and into the cave: %s (x %.0f)" % [_floor_at(33), kleo.global_position.x])
	await _hold_until(["move_left"], func(): return kleo.global_position.x < 57.6 * TILE, 400)
	await _hold_until(["move_left", "jump"], func(): return _floor_at(31), 300)
	lines.append("shelf to the low island (2 across, 2 up): %s (x %.0f)" % [_floor_at(31), kleo.global_position.x])
	_release_all()
	_report(lines, "upper")


## IB-04's main line: down the hill's flights and drops, the road, the pool's piers, and out the East door into IB-01.
func _tour_ib04() -> void:
	var lines := []
	_start_tour()
	await _wait(30)
	await _hold_until(["move_right"], func(): return _floor_at(22), 400)
	lines.append("down two flights: %s" % _floor_at(22))
	await _hold_until(["move_right"], func(): return _floor_at(26), 300)
	await _hold_until(["move_right"], func(): return _floor_at(29), 300)
	await _hold_until(["move_right"], func(): return _floor_at(34), 300)
	await _hold_until(["move_right"], func(): return _floor_at(37), 300)
	lines.append("wound down the hill to the road: %s (x %.0f)" % [_floor_at(37), kleo.global_position.x])
	# The pool's low path: seven jumps, by its six small islands.
	var hops := 0
	for hop in [[1242.0, 1304.0], [1346.0, 1407.0], [1449.0, 1510.0], [1552.0, 1613.0], [1655.0, 1716.0], [1758.0, 1819.0], [1861.0, 1920.0]]:
		await _hold_until(["move_right"], func(): return kleo.global_position.x > hop[0], 300)
		await _hold_until(["move_right", "jump"], func(): return kleo.is_on_floor() and kleo.global_position.x > hop[1], 120)
		if kleo.is_on_floor() and kleo.global_position.x > hop[1]:
			hops += 1
		await _wait(6)
	lines.append("crossed the pool by the low path: %d of 7 jumps landed (x %.0f, y %.0f)" % [hops, kleo.global_position.x, kleo.global_position.y])
	await _hold_until(["move_right"], func(): return room.name != "IronbarkGateRoad", 400)
	await _wait(50)
	lines.append("out the East door into: %s, standing at x %.0f, y %.0f, on the floor: %s" % [room.name, kleo.global_position.x, kleo.global_position.y, kleo.is_on_floor()])
	_release_all()
	_report(lines, "tour")


## IB-04's upper line: the islands over the terraces, a leap for the far island
## (it must fall short), then the way back up the hill from the road, and the water.
func _upper_ib04() -> void:
	var lines := []
	_place(15.0, 19, 1)
	await _frames(10)
	_start_tour()
	await _hold_until(["move_right"], func(): return kleo.global_position.x > 17.4 * TILE, 200)
	await _hold_until(["move_right", "jump"], func(): return _floor_at(17), 200)
	lines.append("terrace to the stepping island (3 across, 2 up): %s (x %.0f)" % [_floor_at(17), kleo.global_position.x])
	await _hold_until(["move_right"], func(): return kleo.global_position.x > 23.4 * TILE, 200)
	await _hold_until(["move_right", "jump"], func(): return _floor_at(16), 200)
	lines.append("stepping island to the great island: %s (x %.0f)" % [_floor_at(16), kleo.global_position.x])
	await _hold_until(["move_right"], func(): return kleo.global_position.x > 45.4 * TILE, 400)
	await _hold_until(["move_right", "jump"], func(): return _floor_at(20), 200)
	lines.append("great island down to the second island (4 across, 4 down): %s (x %.0f)" % [_floor_at(20), kleo.global_position.x])
	# The high path over the pool: down to the ruin, up to the great island, down
	# to the headstone chunk, then the far bank.
	var steps := []
	for hop in [[65.4, 70.0, 22], [78.4, 82.0, 19], [108.4, 114.0, 23]]:
		await _hold_until(["move_right"], func(): return kleo.global_position.x > hop[0] * TILE, 700)
		await _hold_until(["move_right", "jump"], func(): return _floor_at(hop[2]) and kleo.global_position.x > hop[1] * TILE, 300)
		steps.append(_floor_at(hop[2]) and kleo.global_position.x > hop[1] * TILE)
		await _wait(8)
	await _hold_until(["move_right"], func(): return _floor_at(37) and kleo.global_position.x > 1920, 400)
	lines.append("the high path over the pool (ruin -2, great island +3, headstone chunk -4): %s; on the far bank: %s (x %.0f)" % [str(steps), _floor_at(37), kleo.global_position.x])
	await _wait(30)
	_place(58.0, 37, -1)
	await _wait(10)
	# Back up the hill from the road.
	await _hold_until(["move_left"], func(): return _floor_at(34), 600)
	await _hold_until(["move_left"], func(): return kleo.global_position.x < 42.7 * TILE, 200)
	await _hold_until(["move_left", "jump"], func(): return _floor_at(29), 300)
	var a := _floor_at(29)
	await _hold_until(["move_left"], func(): return _floor_at(26), 300)
	await _hold_until(["move_left"], func(): return kleo.global_position.x < 26.7 * TILE, 200)
	await _hold_until(["move_left", "jump"], func(): return _floor_at(22), 300)
	var b := _floor_at(22)
	await _hold_until(["move_left"], func(): return _floor_at(16), 500)
	lines.append("back up the hill from the road (a 5-tile catch, a flight, a 4-tile catch, two flights): %s, %s, %s" % [a, b, _floor_at(16)])
	# The water.
	_place(76.0, 37, 1)
	await _wait(10)
	await _hold_until(["move_right"], func(): return kleo.global_position.y > GROUND_Y + 10, 200)
	await _wait(90)
	lines.append("walked into the water, returned to safe ground: %s (x %.0f, y %.0f)" % [kleo.is_on_floor(), kleo.global_position.x, kleo.global_position.y])
	_release_all()
	_report(lines, "upper")

const GROUND_Y := 592.0


## The Mossback: walk into it (a shove), then stand and swing until it is gone,
## counting the hits it takes. Run it in IB-03 (the garden's Mossback).
func _enemy() -> void:
	var lines := []
	var moss: Node2D = null
	for e in get_tree().get_nodes_in_group("enemy"):
		if moss == null or e.global_position.y > moss.global_position.y:
			moss = e
	lines.append("enemies in the room: %d" % get_tree().get_nodes_in_group("enemy").size())
	_place((moss.global_position.x - 60.0) / TILE, moss.global_position.y / TILE, 1)
	await _frames(10)
	_start_tour()
	await _wait(50)
	# Walk into it.
	var shoved := false
	_press("move_right")
	for i in 200:
		await _step()
		if kleo.state == Kleo.State.HURT:
			shoved = true
			break
	_release_all()
	lines.append("walking into it shoves her back: %s" % shoved)
	await _wait(80)
	# Face it and swing until it is gone.
	var swings := 0
	var hits := 0
	while is_instance_valid(moss) and not moss.dead and swings < 30:
		Game.heal(3)  # shoves cost flames now: this test counts the hits, not her health
		var want := 1 if moss.global_position.x > kleo.global_position.x else -1
		var gap := absf(moss.global_position.x - kleo.global_position.x)
		if gap > 26.0:
			await _hold_until(["move_right" if want > 0 else "move_left"], func(): return not is_instance_valid(moss) or absf(moss.global_position.x - kleo.global_position.x) < 24.0 or kleo.state == Kleo.State.HURT, 120)
		elif kleo.facing != want:
			await _tap("move_right" if want > 0 else "move_left")
		if kleo.state == Kleo.State.HURT:
			await _wait(50)
			continue
		await _tap("attack")
		swings += 1

		for i in 26:
			await _step()
			if is_instance_valid(moss):
				hits = moss.hits
	await _wait(40)
	lines.append("sword hits it took before it went down: %d (rule: 7), in %d swings; gone: %s" % [hits, swings, not is_instance_valid(moss)])
	lines.append("game speed after: %.2f; enemies left in the room: %d" % [Engine.time_scale, get_tree().get_nodes_in_group("enemy").size()])
	_release_all()
	_report(lines, "enemy")


## IB-01's terrace west into IB-04, west across... no: straight back east.
func _doors_surface() -> void:
	var lines := []
	await _swap_room(ROOMS["ib01"])
	await _frames(2)
	_place(6.0, 24, -1)
	await _frames(10)
	_start_tour()
	await _hold_until(["move_left"], func(): return room.name == "IronbarkGateRoad", 300)
	await _wait(40)
	lines.append("IB-01 terrace leads to: %s; she stands at x %.0f, y %.0f, facing %d, on the floor: %s" %
		[room.name, kleo.global_position.x, kleo.global_position.y, kleo.facing, kleo.is_on_floor()])
	await _hold_until(["move_right"], func(): return room.name == "IronbarkTestRoom", 300)
	await _wait(40)
	lines.append("and back to: %s; she stands at x %.0f, y %.0f, facing %d, on the floor: %s" %
		[room.name, kleo.global_position.x, kleo.global_position.y, kleo.facing, kleo.is_on_floor()])
	# IB-04's west door into IB-03 and back.
	await _swap_room(ROOMS["ib04"])
	await _frames(2)
	_place(5.0, 16, -1)
	await _wait(10)
	await _hold_until(["move_left"], func(): return room.name == "IronbarkRuinGardens", 300)
	await _wait(40)
	lines.append("IB-04 hilltop leads west to: %s; she stands at x %.0f, y %.0f, facing %d, on the floor: %s" %
		[room.name, kleo.global_position.x, kleo.global_position.y, kleo.facing, kleo.is_on_floor()])
	_release_all()
	_report(lines, "doors")


func _report(lines: Array, file: String) -> void:
	var text := "\n".join(lines)
	print(text)
	FileAccess.open(out_dir + "/" + file + ".txt", FileAccess.WRITE).store_string(text + "\n")


# --- The room's edge ---------------------------------------------------------------------------

func _edge() -> void:
	# This test is about the camera at the room's edge, so the doors stay shut.
	for e in room.get_node("Doors").get_children():
		if e is Area2D:
			e.monitoring = false
	# The terrace: from the shrine, run to the room's west edge and back.
	_place(20.0, 24, -1)
	await _frames(20)
	_start_tour()
	await _hold_until(["move_left"], func(): return kleo.global_position.x < 12.0, 240)
	await _wait(30)
	await _hold_until(["move_right"], func(): return kleo.global_position.x > 26.0 * TILE, 240)
	await _wait(20)
	# The hall: west to the lower door and back.
	_place(16.0, 37, -1)
	await _frames(10)
	await _hold_until(["move_left"], func(): return kleo.global_position.x < 12.0, 240)
	await _wait(30)
	await _hold_until(["move_right"], func(): return kleo.global_position.x > 17.0 * TILE, 240)
	await _wait(20)
	_release_all()


# --- Hit-stop -------------------------------------------------------------------------------------

func _hitstop_test() -> void:
	var lines := []
	var worst := 0.0
	var last_call := 0
	var calls := 0
	var t0 := Time.get_ticks_usec()
	while Time.get_ticks_usec() - t0 < 3000000:
		if randf() < 0.35:
			Game.hitstop(randf_range(0.01, 0.3))
			last_call = Time.get_ticks_usec()
			calls += 1
		await get_tree().process_frame
		if Engine.time_scale < 1.0 and last_call > 0:
			worst = maxf(worst, (Time.get_ticks_usec() - last_call) / 1000000.0)
	var end_wait := Time.get_ticks_usec()
	while Engine.time_scale < 1.0 and Time.get_ticks_usec() - end_wait < 1000000:
		await get_tree().process_frame
	lines.append("%d overlapping hit-stops in 3 s" % calls)
	lines.append("longest slow-down after the latest hit: %.3f s (cap %.2f s plus a frame)" % [worst, Game.HITSTOP_MAX])
	lines.append("game speed at the end: %.2f" % Engine.time_scale)
	var text := "\n".join(lines)
	print(text)
	FileAccess.open(out_dir + "/hitstop.txt", FileAccess.WRITE).store_string(text + "\n")


# --- Mouse ---------------------------------------------------------------------------------------

func _click() -> void:
	_place(40.0, 28)
	await _frames(10)
	var lines := []
	for button in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
		var ev := InputEventMouseButton.new()
		ev.button_index = button
		ev.position = Vector2(320, 180)
		ev.pressed = true
		Input.parse_input_event(ev)
		await get_tree().physics_frame
		var attack := Input.is_action_pressed("attack")
		var spell := Input.is_action_pressed("spell")
		await _frames(3)
		var state: String = Kleo.State.keys()[kleo.state]
		var anim := String(kleo.sprite.animation)
		ev = ev.duplicate()
		ev.pressed = false
		Input.parse_input_event(ev)
		await _frames(40)
		lines.append("%s click: attack action %s, spell action %s, Kleo %s (%s)" %
			["left" if button == MOUSE_BUTTON_LEFT else "right", attack, spell, state, anim])
	var text := "\n".join(lines)
	print(text)
	FileAccess.open(out_dir + "/click.txt", FileAccess.WRITE).store_string(text + "\n")


# --- Map ---------------------------------------------------------------------------------------

## Layers left out of the map: the parallax planes, the foreground silhouettes
## (they belong to the camera, not the room), the screen effects and Kleo.
const MAP_HIDDEN := ["Sky", "Far", "Aqueduct", "ForegroundFerns", "ForegroundStones", "FogFar", "MidFar", "Mid", "FogMid", "Ruins", "Mood", "Foreground", "ForegroundNear", "Screen", "Kleo"]


func _map_hide() -> void:
	for n in MAP_HIDDEN:
		var node := room.get_node_or_null(n)
		if node:
			node.visible = false


func _map() -> void:
	for c in Game.get_children():
		if c is CanvasLayer and (c as CanvasLayer).layer == 90:
			(c as CanvasLayer).visible = false  # the HUD
	_map_hide()
	cam.target = null
	cam.offset = Vector2.ZERO
	var rect: Rect2i = room.room_rect
	var size := Vector2(rect.size * 16)
	var xs := []
	var x := 320.0
	while x < size.x - 320.0:
		xs.append(x)
		x += 640.0
	xs.append(size.x - 320.0)
	var ys := [180.0, size.y - 180.0]
	var lines := []
	for view in ["art", "box"]:
		get_tree().call_group("box_view", "set_box_view", view == "box")
		_map_hide()  # switching views shows the art layers again
		for cx in xs:
			for cy in ys:
				cam.global_position = Vector2(cx, cy)
				await _frames(4)
				var name := "%s_%d_%d" % [view, int(cx - 320.0), int(cy - 180.0)]
				await _capture(name)
				lines.append(name)
	# The collision cells, for tools/check_room.py.
	var cells := []
	for layer in get_tree().get_nodes_in_group("solid_tiles"):
		for c in layer.get_used_cells():
			cells.append([c.x, c.y, layer.get_cell_atlas_coords(c).x])
	var cf := FileAccess.open(out_dir + "/cells.json", FileAccess.WRITE)
	cf.store_string(JSON.stringify({"room": [rect.position.x, rect.position.y, rect.size.x, rect.size.y], "cells": cells}))
	var f := FileAccess.open(out_dir + "/tiles.txt", FileAccess.WRITE)
	f.store_string("%d %d\n" % [int(size.x), int(size.y)] + "\n".join(lines) + "\n")


# --- Measure -------------------------------------------------------------------------------

func _measure() -> void:
	var lines := []
	# Standing jump, held.
	_place(40.0, 28)
	await _frames(10)
	var floor_y := kleo.global_position.y
	_press("jump")
	var top := floor_y
	for i in 90:
		await get_tree().physics_frame
		top = min(top, kleo.global_position.y)
	_release_all()
	var rise := floor_y - top
	lines.append("standing jump rise: %.1f px = %.2f tiles" % [rise, rise / TILE])
	# Tapped jump.
	_place(40.0, 28)
	await _frames(10)
	_press("jump")
	await get_tree().physics_frame
	_release_all()
	top = floor_y
	for i in 90:
		await get_tree().physics_frame
		top = min(top, kleo.global_position.y)
	lines.append("tapped jump rise: %.1f px = %.2f tiles" % [floor_y - top, (floor_y - top) / TILE])
	# Running jump: full speed, jump, hold right until she lands at the same height.
	_place(32.0, 28)
	await _frames(6)
	_press("move_right")
	for i in 40:
		await get_tree().physics_frame
	var x0 := kleo.global_position.x
	_press("jump")
	var airborne := false
	var x1 := x0
	for i in 120:
		await get_tree().physics_frame
		if not kleo.is_on_floor():
			airborne = true
		elif airborne:
			x1 = kleo.global_position.x
			break
	_release_all()
	lines.append("running jump distance: %.1f px = %.2f tiles (run speed %.0f px/s)" % [x1 - x0, (x1 - x0) / TILE, kleo.run_speed])
	lines.append("ledge reach: a ledge up to %.1f px = %.2f tiles above the floor can be caught" %
		[rise + kleo.ledge_reach_high, (rise + kleo.ledge_reach_high) / TILE])
	# The terrace step: 4 tiles, jump and hold toward it.
	_place(32.0, 28, -1)
	await _frames(6)
	_press("move_left")
	_press("jump")
	var grabbed := false
	var climbed := false
	for i in 200:
		await get_tree().physics_frame
		if kleo.state == Kleo.State.LEDGE_HANG or kleo.state == Kleo.State.LEDGE_CLIMB:
			grabbed = true
		if grabbed and kleo.state == Kleo.State.NORMAL and kleo.is_on_floor():
			climbed = absf(kleo.global_position.y - 24 * TILE) < 1.0
			break
	_release_all()
	lines.append("terrace step (4 tiles): grabbed %s, climbed onto it %s" % [grabbed, climbed])
	# Island -> root shelf: 4 across, 4 up.
	_place(46.5, 21, 1)
	await _frames(6)
	_press("move_right")
	await _frames(4)
	_press("jump")
	grabbed = false
	climbed = false
	for i in 220:
		await get_tree().physics_frame
		if kleo.state == Kleo.State.LEDGE_HANG or kleo.state == Kleo.State.LEDGE_CLIMB:
			grabbed = true
		if grabbed and kleo.state == Kleo.State.NORMAL and kleo.is_on_floor():
			climbed = absf(kleo.global_position.y - 17 * TILE) < 1.0
			break
	_release_all()
	lines.append("island to root shelf (4 across, 4 up): grabbed %s, on the shelf %s" % [grabbed, climbed])
	# Terrace -> island: 3 across, 3 up, running jump.
	_place(26.0, 24, 1)
	await _frames(6)
	_press("move_right")
	await _frames(16)
	_press("jump")
	var landed_y := 0.0
	for i in 120:
		await get_tree().physics_frame
		if kleo.is_on_floor() and kleo.global_position.x > 33 * TILE:
			landed_y = kleo.global_position.y
			break
		if kleo.state == Kleo.State.LEDGE_CLIMB or kleo.state == Kleo.State.LEDGE_HANG:
			landed_y = -1.0
	_release_all()
	lines.append("terrace to island: %s" % ("landed on it" if absf(landed_y - 21 * TILE) < 1.0 else ("caught the ledge" if landed_y < 0 else "missed (y %.0f)" % landed_y)))
	var text := "\n".join(lines)
	print(text)
	var f := FileAccess.open(out_dir + "/measure.txt", FileAccess.WRITE)
	f.store_string(text + "\n")



# --- The platformer's systems (room=sys mode=systems) ------------------------------------------

func _find(group: String) -> Array:
	var out := []
	for n in get_tree().get_nodes_in_group(group):
		if room.is_ancestor_of(n):
			out.append(n)
	return out


func _shot(name: String) -> void:
	await _capture(name)


func _hold_frames(actions: Array, n: int) -> void:
	for a in actions:
		_press(a)
	await _frames(n)
	_release_all()


func _tap_f(action: String) -> void:
	_press(action)
	await _frames(1)
	_release(action)


func _walk_to(x: float, limit := 600) -> void:
	var key := "move_right" if x > kleo.global_position.x else "move_left"
	var dir := 1.0 if key == "move_right" else -1.0
	_press(key)
	for i in limit:
		await _frames(1)
		if dir * (kleo.global_position.x - x) >= 0.0:
			break
	_release_all()


func _systems() -> void:
	var lines := []
	var ok_all := true
	var check := func(label: String, ok: bool, extra := "") -> void:
		lines.append("%s %s%s" % ["PASS" if ok else "FAIL", label, ("  (" + extra + ")") if extra != "" else ""])
		print(lines[-1])
	await _frames(20)
	check.call("starts with 3 flames", Game.health == 3 and Game.max_health == 3)

	# Thorns: a hit, a flame, and thrown back out the way she came.
	_press("move_right")
	for i in 200:
		await _frames(1)
		if kleo.state == Kleo.State.HURT:
			break
	_release_all()
	await _frames(20)
	await _shot("01_thorns")
	await _frames(70)
	check.call("thorns cost a flame", Game.health == 2, "health %d" % Game.health)
	check.call("thorns throw her back out of them", kleo.global_position.x < 8.0 * TILE - 4.0 and kleo.is_on_floor() and kleo.state == Kleo.State.NORMAL, "x %.0f" % kleo.global_position.x)
	_place(3.0, 20)
	await _frames(10)

	# The checkpoint: lit by walking past; it refills her flames.
	_place(14.0, 20)
	await _frames(10)
	await _walk_to(18.0 * TILE)
	await _frames(20)
	var cp: Node = _find("checkpoint")[0]
	await _shot("02_checkpoint_lit")
	check.call("checkpoint lights as she passes", cp.lit)
	check.call("checkpoint refills her flames", Game.health == 3, "health %d" % Game.health)

	# Resin at risk: take the beads, fall in the pit before the next checkpoint.
	await _walk_to(28.5 * TILE)
	await _frames(10)
	var got := Game.currency
	check.call("beads picked up", got == 4, "Resin %d" % got)
	await _walk_to(31.5 * TILE)
	await _frames(100)
	check.call("a pit costs a flame and returns her to the checkpoint", Game.health == 2 and absf(kleo.global_position.x - (16 * TILE + 14)) < 3.0,
		"health %d, x %.0f" % [Game.health, kleo.global_position.x])
	var back := 0
	for b in _find("resin"):
		if b.visible and not b.is_taken():
			back += 1
	check.call("the beads she carried go back where they hung", Game.currency == 0 and back == 4, "Resin %d, beads hanging %d" % [Game.currency, back])

	# The chest: a blow, and it spills its Resin.
	_place(35.0, 20)
	await _frames(10)
	var before := _find("resin").size()
	_tap_f("attack")
	await _frames(30)
	var chest: Node = _find("chest")[0]
	await _shot("03_chest_spill")
	var spilled := _find("resin").size() - before
	check.call("a struck chest opens and spills its beads", chest.opened and spilled == 6, "spilled %d" % spilled)
	await _frames(60)
	await _walk_to(41.0 * TILE)
	await _walk_to(34.0 * TILE)
	await _frames(30)
	check.call("the spilled beads can be gathered", Game.currency >= 4, "Resin %d" % Game.currency)

	# The lunging enemy (the rat): notice, wind-up, lunge; it fights back; struck, it flinches.
	Game.heal(3)
	var hound: Node = _find("enemy")[0]
	_place(44.5, 20)
	await _frames(4)
	var seen := {}
	var hp_before := Game.health
	var shots := {}
	for i in 240:
		await _frames(1)
		if not is_instance_valid(hound):
			break
		var st: String = Lunger.S.keys()[hound.state]
		seen[st] = true
		if not shots.has(st) and st in ["NOTICE", "WINDUP", "LUNGE"]:
			shots[st] = true
			await _shot("04_hound_" + st.to_lower())
		if seen.has("LAND"):
			break
	check.call("it notices her, winds up and lunges", seen.has("NOTICE") and seen.has("WINDUP") and seen.has("LUNGE"), ", ".join(seen.keys()))
	check.call("its lunge hurts her", Game.health < hp_before, "health %d -> %d" % [hp_before, Game.health])
	Game.heal(3)
	# Fight it: face it and swing; it must flinch, then go down.
	var flinched := false
	for i in 900:
		if not is_instance_valid(hound) or hound.is_dead():
			break
		kleo.facing = 1 if hound.global_position.x > kleo.global_position.x else -1
		if absf(hound.global_position.x - kleo.global_position.x) > 26.0:
			_press("move_right" if kleo.facing > 0 else "move_left")
		else:
			_release_all()
			if i % 9 == 0:
				_tap_f("attack")
		await _frames(1)
		if is_instance_valid(hound) and hound.state == Lunger.S.FLINCH:
			if not flinched:
				await _shot("05_hound_flinch")
			flinched = true
		if Game.health <= 1:
			Game.heal(3)
	_release_all()
	check.call("struck, it flinches", flinched)
	check.call("four hits put it down", not is_instance_valid(hound) or hound.is_dead())
	await _frames(60)

	# The crate: lift it, carry it, throw it at the cracked wall.
	_place(65.5, 20)
	await _frames(10)
	await _walk_to(67.6 * TILE)
	await _frames(4)
	_tap_f("interact")
	await _frames(20)
	check.call("she lifts the crate overhead", kleo.held != null)
	await _shot("06_crate_held")
	await _hold_frames(["move_right"], 14)
	await _frames(4)
	_tap_f("attack")
	var wall: Node = _find("cracked_wall")[0]
	for i in 60:
		await _frames(1)
		if wall.broken:
			break
	await _shot("07_crack_broken")
	check.call("a thrown crate breaks the cracked wall", wall.broken)

	# The hollow behind it: its hidden entrance takes her to the bonus area.
	var zone: BonusZone = _find("bonus_zone")[0]
	await _walk_to(86.0 * TILE, 200)
	for i in 90:
		await _frames(1)
		if zone.running():
			break
	check.call("the hidden entrance takes her to the bonus area", zone.running() and kleo.global_position.x > 154.0 * TILE,
		"x %.0f" % kleo.global_position.x)
	await _frames(30)
	await _shot("08_bonus_running")
	for b in zone.get_node("Beads").get_children():
		kleo.global_position = b.global_position + Vector2(0, 10)
		await _frames(3)
	await _frames(10)
	check.call("gathering every bead brings out the token", zone.token.visible, "left %d" % zone.remaining())
	kleo.global_position = zone.token.global_position + Vector2(0, 8)
	await _frames(10)
	await _shot("09_bonus_token")
	check.call("the token is won", Game.tokens_found() == 1, "%d of %d" % [Game.tokens_found(), Game.level_tokens.size()])
	for i in 200:
		await _frames(1)
		if Game.bonus == null and kleo.state == Kleo.State.NORMAL:
			break
	await _frames(30)
	check.call("then she is back out beside the entrance", absf(kleo.global_position.x - 82.0 * TILE) < 3.0 and kleo.is_on_floor(),
		"x %.0f" % kleo.global_position.x)
	await _walk_to(85.0 * TILE, 40)
	await _frames(20)
	check.call("won, the entrance stays shut", Game.bonus == null and kleo.global_position.x < 150.0 * TILE)

	# The moving platform: it waits for her, then carries her over the pit.
	_place(93.5, 20)
	await _frames(4)
	var mover: Node = _find("moving_platform")[0]
	var x0 := kleo.global_position.x
	await _frames(40)
	await _shot("10_platform")
	for i in 400:
		await _frames(1)
		if mover.position.x > 92 * TILE + 150:
			break
	check.call("the platform carries her across", kleo.global_position.x > x0 + 140.0 and kleo.is_on_floor(), "moved %.0f px" % (kleo.global_position.x - x0))
	await _walk_to(108.0 * TILE)
	await _frames(10)

	# Deep water: a flame, back to the checkpoint.
	var hp := Game.health
	await _walk_to(113.5 * TILE)
	await _frames(100)
	check.call("water costs a flame and returns her to the checkpoint", Game.health == hp - 1 and absf(kleo.global_position.x - (64 * TILE + 14)) < 3.0,
		"health %d, x %.0f" % [Game.health, kleo.global_position.x])

	# Defeat: the last flame lost; back at the checkpoint with her flames refilled.
	await _frames(70)  # past the invulnerability after coming back
	Game.health = 1
	kleo.hurt(1)
	await _frames(12)
	await _shot("11_defeat")
	check.call("losing the last flame is a defeat", kleo.state == Kleo.State.DOWN)
	await _frames(160)
	check.call("after a defeat she is back at the checkpoint, flames refilled", Game.health == 3 and absf(kleo.global_position.x - (64 * TILE + 14)) < 3.0,
		"health %d, x %.0f" % [Game.health, kleo.global_position.x])

	# A letter on the way.
	_place(119.0, 20)
	await _frames(10)
	await _walk_to(124.0 * TILE)
	await _frames(30)
	check.call("touching a letter takes it", Game.letters_found() == 1, "%d" % Game.letters_found())

	# The level's end.
	_place(136.0, 20)
	await _frames(10)
	await _walk_to(142.0 * TILE, 200)
	await _frames(60)
	await _shot("12_level_end")
	var end: Node = _find("level_end")[0]
	check.call("walking into the doorway ends the level", end.done)
	await _frames(200)
	check.call("the game is at full speed after it all", is_equal_approx(Engine.time_scale, 1.0))
	for l in lines:
		if l.begins_with("FAIL"):
			ok_all = false
	lines.append("ALL PASS" if ok_all else "SOME FAILED")
	_report(lines, "systems")


# --- Level 1-1 (room=l1_1) ------------------------------------------------------------------------

## The enemies stand still for the route tests (the systems test fights them).
func _calm_enemies() -> void:
	for e in _find("enemy"):
		e.process_mode = Node.PROCESS_MODE_DISABLED


## Straight up through a one-way branch above her, from where she stands.
func _hop_up(row: int, steer := 0) -> bool:
	_press("jump")
	for i in 90:
		await _step()
		if i == 6 and steer != 0:
			_press("move_right" if steer > 0 else "move_left")
		if i == 14:
			_release_all()
			_press("jump")
		if kleo.is_on_floor() and i > 6:
			break
	_release_all()
	await _wait(6)
	return _floor_at(row)


## The main line, start to the doorway: every jump the level asks of her.
func _tour_l1_1() -> void:
	_calm_enemies()
	var lines := []
	var res := []
	_start_tour()
	await _wait(20)
	# TEACH: the terraces, the stall, the water pit, the ledge catch.
	res.append(["terrace 1 (2 up)", await _jump_to(200, 228, 280, 28)])
	res.append(["terrace 2 (2 up)", await _jump_to(268, 292, 344, 26)])
	res.append(["onto the stall's floor (2 up)", await _jump_to(332, 356, 630, 24)])
	res.append(["off the stall's east end", await _step_off("move_right", 648, 30)])
	res.append(["to the mushroom island (4 across, 1 up)", await _jump_to(985, 1092, 1180, 29, 1012)])
	res.append(["to the far bank (4 across)", await _jump_to(1140, 1250, 1300, 30, 1176)])
	res.append(["ledge catch onto the chest block (5 up)", await _jump_to(1300, 1316, 1436, 25)])
	res.append(["off the block", await _step_off("move_right", 1448, 30)])
	# TEST: wall terraces, the plateau, the log, the gap, down past the false wall.
	res.append(["wall terrace (3 up)", await _jump_to(1575, 1604, 1690, 27)])
	res.append(["the plateau (3 up)", await _jump_to(1672, 1700, 2100, 24)])
	await _hold_until(["move_right"], func(): return kleo.global_position.x > 2400.0, 300)
	await _wait(6)
	res.append(["over the fallen log to the bank", _floor_at(25)])
	res.append(["the gap up to the ruin mass (4 across, 2 up)", await _jump_to(2520, 2632, 2800, 23, 2544)])
	res.append(["down the step", await _step_off("move_right", 2824, 26)])
	res.append(["down to the ground", await _step_off("move_right", 2920, 30)])
	# TWIST: past the crates, up onto the hill, over the islands.
	await _hold_until(["move_right"], func(): return kleo.global_position.x > 3600.0, 400)
	res.append(["up onto the hill (3 up)", await _jump_to(3740, 3780, 3820, 27)])
	res.append(["up the root bank (3 up)", await _jump_to(3800, 3828, 3870, 24)])
	res.append(["onto the crate (2 up)", await _jump_to(3858, 3886, 3910, 22)])
	res.append(["onto the stack of two (2 up)", await _jump_to(3900, 3924, 3948, 20)])
	res.append(["down off the stack to the hill", await _step_off("move_right", 3960, 27)])
	await _hold_until(["move_right"], func(): return kleo.global_position.x > 4600.0, 400)
	res.append(["off the hill", await _step_off("move_right", 4680, 30)])
	res.append(["island 1 (4 across, 2 up)", await _jump_to(4720, 4820, 4875, 28, 4744)])
	res.append(["island 2 (4 across, 2 up)", await _jump_to(4860, 4948, 5003, 26, 4872)])
	res.append(["island 3 (4 across, 3 down)", await _jump_to(4990, 5076, 5131, 29, 5000)])
	res.append(["island 4 (4 across, 2 up)", await _jump_to(5118, 5204, 5243, 27, 5128)])
	res.append(["the far bank (4 across, 3 down)", await _jump_to(5232, 5316, 5440, 30, 5240)])
	# FINISH: the pits, the thorns, the step, the terraces, the doorway.
	res.append(["over the pit (4 across)", await _jump_to(5720, 5864, 5910, 30, 5770)])
	res.append(["over the thorns", await _jump_to(5900, 5992, 6060, 30, 5916)])
	res.append(["over the pit, up the step (4 across, 2 up)", await _jump_to(6030, 6150, 6290, 28, 6062)])
	res.append(["down from the step", await _step_off("move_right", 6312, 30)])
	res.append(["the end terrace (3 up)", await _jump_to(6370, 6404, 6580, 27)])
	res.append(["the end ledge (3 up)", await _jump_to(6560, 6596, 6820, 24)])
	var end: Node = _find("level_end")[0]
	await _hold_until(["move_right"], func(): return end.done, 300)
	await _wait(10)
	res.append(["through the doorway: the level ends", end.done])
	var hp := Game.health
	var all := true
	for r in res:
		lines.append("%s %s" % ["PASS" if r[1] else "FAIL", r[0]])
		all = all and r[1]
	lines.append("the midway banner reached: %s; flames left %d; Resin on the main line %d" % [
		_find("checkpoint").filter(func(c): return c.lit).size() == 1, hp, Game.currency])
	lines.append("ALL PASS" if all else "SOME FAILED")
	_report(lines, "tour")


## The secrets: the letters (K and O on the main line's jumps, L behind the
## false wall, E on the treetops), the hill's false wall into its hidden cave
## and bonus 1 (gather), the treetops and bonus 2 (course), the chests.
func _secrets_l1_1() -> void:
	_calm_enemies()
	var res := []
	_start_tour()
	await _wait(20)
	# Letter K, over the mushroom island: the main line's jump takes it.
	_place(58.0, 30)
	await _wait(6)
	res.append(["to the mushroom island", await _jump_to(985, 1092, 1180, 29, 1012)])
	if not _letter_taken("K"):
		await _hop_up(29)
	res.append(["letter K (over the mushroom island)", _letter_taken("K")])
	# The chest on the high ledge.
	_place(84.0, 25)
	await _wait(10)
	_tap("attack")
	await _wait(40)
	res.append(["the chest on the high ledge opens", _find("chest")[0].opened])
	# The false wall: in, letter L, out; the wall closes behind her.
	_place(184.0, 30, -1)
	await _wait(10)
	var cover: Node = room.get_node("FalseWall")
	await _hold_until(["move_left"], func(): return kleo.global_position.x < 178.5 * TILE, 200)
	await _wait(40)
	res.append(["the false wall fades while she is inside", cover.modulate.a < 0.1])
	res.append(["letter L (behind the false wall)", _letter_taken("L")])
	await _hold_until(["move_right"], func(): return kleo.global_position.x > 186.0 * TILE, 200)
	await _wait(70)
	res.append(["the wall closes again once she leaves", cover.modulate.a > 0.95])
	# The hill's foot: a false wall, a tunnel, the hidden cave under the hill.
	_place(231.0, 30)
	await _wait(10)
	await _hold_until(["move_right"], func(): return kleo.global_position.x > 243.0 * TILE and kleo.is_on_floor() and kleo.global_position.y > 33.5 * TILE, 300)
	res.append(["through the hill's false wall into the hidden cave", _floor_at(34)])
	res.append(["onto the cave's first block", await _jump_to(3906.0, 3940.0, 3980.0, 31)])
	await _step_off("move_right", 3992.0, 34)
	res.append(["onto its second block", await _jump_to(4018.0, 4052.0, 4092.0, 31)])
	await _step_off("move_right", 4104.0, 34)
	var gather: BonusZone = _zone("gather")
	await _hold_until(["move_right"], func(): return gather.running(), 200)
	res.append(["the glowing hollow takes her to bonus 1", gather.running()])
	await _wait(10)
	# Bonus 1: gather every bead as a player would, block to block.
	var hops := await _jump_to(7290, 7316, 7370, 27)
	hops = hops and await _jump_to(7330, 7444, 7516, 25, 7368)
	hops = hops and await _jump_to(7470, 7588, 7644, 27, 7512)
	hops = hops and await _jump_to(7600, 7716, 7860, 25, 7640)
	await _hold_until(["move_right"], func(): return kleo.global_position.x >= 7848.0, 200)
	await _wait(10)
	res.append(["bonus 1: block to block", hops])
	res.append(["bonus 1: every bead gathered in time (%d left, %.1f s to spare)" % [gather.remaining(), maxf(gather._left, 0.0)], gather.remaining() == 0])
	for b in gather.get_node("Beads").get_children():
		if not b.get_meta("taken", false):
			print("  bead left at ", b.global_position)
	await _hold_until(["move_left"], func(): return kleo.global_position.x <= 7790.0, 100)
	await _hop_up(25)
	res.append(["bonus 1's token (a hop over the last block)", Game.flags.has("l11_token1")])
	for i in 240:
		await _step()
		if Game.bonus == null and kleo.state == Kleo.State.NORMAL:
			break
	await _wait(20)
	res.append(["back out in the cave beside the hollow (x %.0f, y %.0f)" % [kleo.global_position.x, kleo.global_position.y], absf(kleo.global_position.x - 256.0 * TILE) < 12.0 and _floor_at(34)])
	# The hollow, won, lets her by: the thorn knot sleeps in the dark behind it.
	await _hold_until(["move_right"], func(): return room.get_node("ThornKnot").is_awake(), 150)
	res.append(["past the won hollow: Morvath's knot wakes (the great secret)", Game.flags.has("l11_knot") and Game.bonus == null])
	# Out again: back west over the blocks, a ledge catch up into the tunnel.
	var over_blocks := await _jump_to(4080.0, 4052.0, 4092.0, 31)
	over_blocks = over_blocks and await _step_off("move_left", 4040.0, 34)
	over_blocks = over_blocks and await _jump_to(4000.0, 3940.0, 3980.0, 31)
	over_blocks = over_blocks and await _step_off("move_left", 3928.0, 34)
	res.append(["back west over the cave's blocks", over_blocks])
	res.append(["back up into the tunnel (a 4-tile ledge catch)", await _jump_to(242.6 * TILE, 236.5 * TILE, 241.5 * TILE, 30)])
	await _hold_until(["move_left"], func(): return kleo.global_position.x < 233.0 * TILE, 200)
	res.append(["out of the hill", kleo.global_position.x < 234.0 * TILE and _floor_at(30)])
	# The root bank and the crates on the hill, up to the treetop route.
	_place(240.0, 24)
	await _wait(10)
	res.append(["onto the crate (2 up)", await _jump_to(3858, 3886, 3910, 22)])
	res.append(["onto the stack of two (2 up)", await _jump_to(3900, 3924, 3948, 20)])
	res.append(["up into the first treetop (4 up from the stack)", await _hop_up(18, 0)])
	res.append(["treetop 2 (4 across, 1 up)", await _jump_to(3968, 4084, 4204, 17, 4008)])
	res.append(["treetop 3 (4 across, 2 down)", await _jump_to(4150, 4276, 4364, 19, 4200)])
	await _hold_until(["move_right"], func(): return kleo.global_position.x >= 4330.0, 100)
	res.append(["letter E (on the third treetop)", _letter_taken("E")])
	res.append(["treetop 4 (4 across, 2 up)", await _jump_to(4300, 4436, 4500, 17, 4360)])
	var course: BonusZone = _zone("course")
	await _hold_until(["move_right"], func(): return course.running(), 200)
	res.append(["the hollow at the treetops' end takes her to bonus 2", course.running()])
	await _wait(10)
	# Bonus 2: pillar to pillar over the drop, to the token.
	var run := await _jump_to(8000, 8084, 8124, 29, 8024)
	run = run and await _jump_to(8090, 8196, 8236, 27, 8120)
	run = run and await _jump_to(8200, 8308, 8348, 29, 8232)
	run = run and await _jump_to(8310, 8420, 8460, 27, 8344)
	run = run and await _jump_to(8430, 8516, 8570, 27, 8456)
	res.append(["bonus 2: across the pillars (%.1f s to spare)" % maxf(course._left, 0.0), run])
	await _wait(10)
	res.append(["bonus 2's token (at the course's end)", Game.flags.has("l11_token2")])
	for i in 240:
		await _step()
		if Game.bonus == null and kleo.state == Kleo.State.NORMAL:
			break
	await _wait(20)
	res.append(["back out on the last treetop", absf(kleo.global_position.x - 280.5 * TILE) < 3.0 and _floor_at(17)])
	res.append(["down off the last treetop onto the hill (the hollow, won, lets her by)", await _step_off("move_right", 4552.0, 27)])
	# The treetops can't be reached from the hill without the crates.
	_place(262.0, 27)
	await _wait(10)
	var hop_ok := await _hop_up(19, 0)
	res.append(["from the hill alone, the treetops are out of reach", not hop_ok and _floor_at(27)])
	# Letter O, over the pit before the step: the main line's jump takes it.
	_place(376.5, 30)
	await _wait(10)
	res.append(["over the pit, up the step", await _jump_to(6030, 6150, 6290, 28, 6062)])
	res.append(["letter O (over the pit)", _letter_taken("O")])
	res.append(["all four letters: K-L-E-O", Game.letters_found() == 4])
	# The last chest.
	_place(417.0, 24)
	await _wait(10)
	_tap("attack")
	await _wait(40)
	res.append(["the chest by the doorway opens", _find("chest")[1].opened])
	var lines := []
	var all := true
	for r in res:
		lines.append("%s %s" % ["PASS" if r[1] else "FAIL", r[0]])
		all = all and r[1]
	lines.append("letters found: %d of 4; bonus tokens: %d of %d" % [Game.letters_found(), Game.tokens_found(), Game.level_tokens.size()])
	lines.append("ALL PASS" if all else "SOME FAILED")
	_report(lines, "secrets")


func _letter_taken(l: String) -> bool:
	var n := room.get_node_or_null("Letter" + l)
	return n != null and n.is_taken()


func _zone(kind: String) -> BonusZone:
	for z in _find("bonus_zone"):
		if z.kind == kind:
			return z
	return null


# --- Level 1-2 (room=l1_2) ------------------------------------------------------------------------

const SHOTS_L12 := [
	["01_start_wall_stubs", 14.0, 30, 1],
	["02_first_water", 62.0, 30, 1],
	["03_first_floating_island", 96.0, 25, 1],
	["04_rampart_thorn_knot", 124.0, 24, 1],
	["05_long_pool_low_path", 160.0, 29, 1],
	["06_high_path", 150.0, 19, 1],
	["07_great_island_rat", 176.0, 18, 1],
	["08_high_path_end_bonus1", 204.0, 20, 1],
	["09_road_ends_midway_banner", 222.0, 30, 1],
	["10_old_landing_bonus2", 235.0, 31, 1],
	["11_floating_islands", 262.0, 22, 1],
	["12_islands_to_bank", 302.0, 22, 1],
	["13_thorns_last_water", 340.0, 30, 1],
	["14_last_islands", 368.0, 25, 1],
	["15_gatehouse", 420.0, 24, 1],
	["16_bonus_course", 470.0, 29, 1, Rect2i(452, 16, 40, 24)],
	["17_bonus_gather", 512.0, 26, 1, Rect2i(496, 16, 40, 24)],
]


## A step up beside her (2 or 3 tiles): the wall's x and the floor's far end, in tiles.
func _rise(wall: float, far: float, row: int) -> bool:
	if far > wall:
		return await _jump_to(wall * TILE - 24.0, wall * TILE + 4.0, far * TILE - 5.0, row)
	return await _jump_to(wall * TILE + 24.0, far * TILE + 5.0, wall * TILE - 4.0, row)


## A hop over a gap from the edge at `edge` to the floor [l0, l1] (tiles).
func _hop(edge: float, l0: float, l1: float, row: int) -> bool:
	if l0 > edge:
		return await _jump_to(edge * TILE - 32.0, l0 * TILE + 4.0, l1 * TILE - 5.0, row, edge * TILE - 8.0)
	return await _jump_to(edge * TILE + 32.0, l0 * TILE + 5.0, l1 * TILE - 4.0, row, edge * TILE + 8.0)


func _off(edge: float, row: int) -> bool:
	return await _step_off("move_right", edge * TILE + 8.0, row)


func _results(res: Array, tail: Array, file: String) -> void:
	var lines := []
	var all := true
	for r in res:
		lines.append("%s %s" % ["PASS" if r[1] else "FAIL", r[0]])
		all = all and r[1]
	lines.append_array(tail)
	lines.append("ALL PASS" if all else "SOME FAILED")
	_report(lines, file)


## The main line, start to the gateway: every jump the level asks of her.
func _tour_l1_2() -> void:
	_calm_enemies()
	var res := []
	_start_tour()
	await _wait(20)
	# TEACH: the wall stubs, the first water, the first floating island.
	res.append(["wall stub 1 (2 up)", await _rise(16, 19, 28)])
	res.append(["stub 2 (4 across)", await _hop(19, 23, 26, 28)])
	res.append(["stub 3 (4 across, 1 up)", await _hop(26, 30, 33, 27)])
	res.append(["down to the road", await _off(33, 30)])
	res.append(["the first water: island 1 (4 across, 1 up)", await _hop(60, 64, 69, 29)])
	res.append(["island 2 (4 across, 1 up)", await _hop(69, 73, 77, 28)])
	res.append(["the far bank (4 across, 2 down)", await _hop(77, 81, 86, 30)])
	res.append(["the bank (3 up)", await _rise(86, 90, 27)])
	res.append(["the higher bank (2 up)", await _rise(90, 94, 25)])
	res.append(["the first floating island (4 across, 2 up)", await _hop(94, 98, 110, 23)])
	res.append(["off its far end to the road (7 down)", await _off(110, 30)])
	# TEST: the rampart, then the long pool by its small islands.
	res.append(["rampart terrace (3 up)", await _rise(118, 122, 27)])
	res.append(["terrace (3 up)", await _rise(122, 126, 24)])
	res.append(["the tower's top (3 up)", await _rise(126, 132, 21)])
	res.append(["down the east step (4 down)", await _off(132, 25)])
	res.append(["down to the road (5 down)", await _off(136, 30)])
	var pool := [[140, 143, 148, 29], [148, 152, 156, 28], [156, 160, 163, 26], [163, 167, 171, 29],
		[171, 175, 181, 28], [181, 185, 188, 27], [188, 192, 196, 29], [196, 200, 210, 30]]
	for k in pool.size():
		var h: Array = pool[k]
		res.append(["the long pool: hop %d of 8 (to row %d)" % [k + 1, h[3]], await _hop(h[0], h[1], h[2], h[3])])
	res.append(["the far bank's block (3 up)", await _rise(210, 216, 27)])
	res.append(["down to the road", await _off(216, 30)])
	# TWIST: the road ends; the floating islands are the way.
	res.append(["terrace (3 up)", await _rise(224, 228, 27)])
	res.append(["terrace (3 up)", await _rise(228, 232, 24)])
	var isl := [[232, 236, 246, 22], [246, 250, 256, 24], [256, 260, 286, 22], [286, 290, 295, 24], [295, 299, 307, 22], [307, 311, 316, 25]]
	for k in isl.size():
		var h: Array = isl[k]
		res.append(["floating island %d of 6 (to row %d)" % [k + 1, h[3]], await _hop(h[0], h[1], h[2], h[3])])
	res.append(["down to the far bank (5 down)", await _off(316, 30)])
	# FINISH: thorns, stones, islands, the pillar, the gatehouse.
	res.append(["over the thorns", await _jump_to(5276, 5368, 5436, 30, 5292)])
	var fin := [[344, 348, 352, 29], [352, 356, 360, 27], [360, 364, 374, 25], [374, 378, 384, 23], [384, 388, 392, 26], [392, 396, 404, 30]]
	for k in fin.size():
		var h: Array = fin[k]
		res.append(["the last water: hop %d of 6 (to row %d)" % [k + 1, h[3]], await _hop(h[0], h[1], h[2], h[3])])
	res.append(["the end terrace (3 up)", await _rise(404, 414, 27)])
	res.append(["the gate's ledge (3 up)", await _rise(414, 426, 24)])
	var end: Node = _find("level_end")[0]
	await _hold_until(["move_right"], func(): return end.done, 300)
	await _wait(10)
	res.append(["through the gateway: the level ends", end.done])
	res.append(["the midway banner flies (the level's one checkpoint)", _find("checkpoint").size() == 1 and _find("checkpoint")[0].lit])
	_results(res, ["flames left %d; Resin on the main line %d" % [Game.health, Game.currency]], "tour")


func _bonus_over() -> void:
	for i in 240:
		await _step()
		if Game.bonus == null and kleo.state == Kleo.State.NORMAL:
			break
	await _wait(20)


## The secrets: the letters, the high path and bonus 1, the old landing and
## bonus 2, the false wall, the chests.
func _secrets_l1_2() -> void:
	_calm_enemies()
	var res := []
	_start_tour()
	await _wait(20)
	# Letter K, over the first water: the main line's jump takes it.
	_place(57.0, 30)
	await _wait(6)
	await _hop(60, 64, 69, 29)
	res.append(["to the second island", await _hop(69, 73, 77, 28)])
	if not _letter_taken("K"):
		await _hop_up(28)
	res.append(["letter K (over the first water)", _letter_taken("K")])
	# The chest on the first floating island.
	_place(103.0, 23)
	await _wait(10)
	_tap("attack")
	await _wait(40)
	res.append(["the chest on the first floating island opens", _find("chest")[0].opened])
	# The floating island can't be reached from the road under it.
	_place(104.0, 30)
	await _wait(10)
	await _hop_up(23)
	res.append(["from the road, the floating island is out of reach", _floor_at(30)])
	# The thorn knot: out of reach from the terrace under it, reached by
	# turning back west from the tower's top.
	_place(123.5, 24, -1)
	await _wait(10)
	await _hop_up(18, -1)
	await _wait(20)
	res.append(["from the terrace, the knot's island is out of reach", not room.get_node("ThornKnot").is_awake() and not _floor_at(18)])
	_place(128.0, 21, -1)
	await _wait(10)
	res.append(["west from the tower's top to the knot's island (3 across, 3 up)", await _hop(126, 119, 123, 18)])
	await _hold_until(["move_left"], func(): return room.get_node("ThornKnot").is_awake(), 120)
	res.append(["Morvath's knot wakes (the great secret)", Game.flags.has("l12_knot")])
	# The risky Resin on the long pool: a drop onto a small low stone, a step back up.
	_place(169.0, 29)
	await _wait(10)
	var before := Game.currency
	res.append(["off the stone's edge onto the low stone (2 down)", await _step_off("move_right", 171.0 * TILE + 2.0, 31)])
	await _hold_until(["move_right"], func(): return kleo.global_position.x >= 173.3 * TILE, 100)
	res.append(["its risky Resin (3 beads)", Game.currency - before >= 3])
	res.append(["back up onto the wide stone (1 across, 3 up)", await _hop(174, 175, 181, 28)])
	# The high path: from the tower's top over the big floating islands.
	_place(129.0, 21)
	await _wait(10)
	res.append(["high path: island 1 (4 across, 2 up)", await _hop(132, 136, 148, 19)])
	res.append(["island 2 (4 across, 2 up)", await _hop(148, 152, 160, 17)])
	await _hold_until(["move_right"], func(): return kleo.global_position.x >= 154.0 * TILE, 100)
	await _wait(8)
	_tap("attack")
	await _wait(40)
	res.append(["its chest opens", _find("chest")[1].opened])
	res.append(["the great island (4 across, 1 down)", await _hop(160, 164, 188, 18)])
	res.append(["island 4 (4 across, 2 up)", await _hop(188, 192, 198, 16)])
	await _hold_until(["move_right"], func(): return kleo.global_position.x >= 195.5 * TILE, 100)
	res.append(["letter L (on the high path)", _letter_taken("L")])
	res.append(["the last island (4 across, 4 down)", await _hop(198, 202, 208, 20)])
	var course: BonusZone = _find("bonus_zone").filter(func(z): return z.token.flag == "l12_token1")[0]
	await _hold_until(["move_right"], func(): return course.running(), 200)
	res.append(["the hollow at the high path's end takes her to bonus 1", course.running()])
	await _wait(10)
	var run := await _hop(458, 462, 465, 28)
	run = run and await _hop(465, 469, 472, 29)
	run = run and await _hop(472, 476, 479, 27)
	run = run and await _hop(479, 483, 486, 29)
	run = run and await _hop(486, 489, 492, 27)
	res.append(["bonus 1: across the pillars", run])
	res.append(["bonus 1: all %d Resin taken on the way (%d left, %.1f s to spare)" % [course.beads.get_child_count(), course.remaining(), maxf(course._left, 0.0)], course.remaining() == 0])
	_bead_report(course)
	await _hop_up(27)
	res.append(["bonus 1's token (a hop on the last pillar)", Game.flags.has("l12_token1")])
	await _bonus_over()
	res.append(["back out beside the hollow", absf(kleo.global_position.x - 205.5 * TILE) < 3.0 and _floor_at(20)])
	res.append(["off the island's end onto the bank's block (7 down; the hollow, won, lets her by)", await _off(210, 27)])
	# The old landing under the bank's edge: bonus 2.
	_place(230.0, 24)
	await _wait(10)
	res.append(["off the bank's edge onto the step in its face (3 down)", await _off(232, 27)])
	res.append(["down to the old landing (4 down)", await _off(234, 31)])
	var gather: BonusZone = _find("bonus_zone").filter(func(z): return z.token.flag == "l12_token2")[0]
	await _hold_until(["move_right"], func(): return gather.running(), 200)
	res.append(["the glowing hollow under the island takes her to bonus 2", gather.running()])
	await _wait(10)
	var hops := await _rise(502, 506, 28)
	await _hold_until(["move_right"], func(): return kleo.global_position.x >= 504.8 * TILE, 100)
	hops = hops and await _hop(506, 510, 515, 26)
	await _hold_until(["move_right"], func(): return kleo.global_position.x >= 514.2 * TILE, 100)
	await _hold_until(["move_left"], func(): return kleo.global_position.x <= 512.7 * TILE, 100)
	await _hop_up(26)
	hops = hops and await _hop(515, 519, 523, 28)
	await _hold_until(["move_right"], func(): return kleo.global_position.x >= 521.0 * TILE, 100)
	await _hop_up(28)
	await _hold_until(["move_right"], func(): return kleo.global_position.x >= 521.8 * TILE, 100)
	hops = hops and await _hop(523, 527, 536, 26)
	await _hold_until(["move_right"], func(): return kleo.global_position.x >= 533.0 * TILE, 200)
	await _hop_up(26)
	await _hold_until(["move_right"], func(): return kleo.global_position.x >= 534.6 * TILE, 200)
	await _wait(6)
	res.append(["bonus 2: block to block", hops])
	res.append(["bonus 2: all %d Resin gathered in time (%d left, %.1f s to spare)" % [gather.beads.get_child_count(), gather.remaining(), maxf(gather._left, 0.0)], gather.remaining() == 0])
	_bead_report(gather)
	await _hold_until(["move_left"], func(): return kleo.global_position.x <= 531.8 * TILE, 100)
	await _hop_up(26)
	res.append(["bonus 2's token (a hop at the last block)", Game.flags.has("l12_token2")])
	await _bonus_over()
	res.append(["back out on the landing beside the hollow", absf(kleo.global_position.x - 236.2 * TILE) < 3.0 and _floor_at(31)])
	res.append(["back up the step in the bank's face (a 4-tile ledge catch)", await _jump_to(234.6 * TILE, 232.0 * TILE + 3.0, 234.0 * TILE - 4.0, 27)])
	res.append(["back up onto the bank (3 up)", await _rise(232, 228, 24)])
	# The false wall in the end terrace: letter E.
	_place(400.0, 30)
	await _wait(10)
	var cover: Node = room.get_node("GateWall")
	await _hold_until(["move_right"], func(): return kleo.global_position.x > 406.5 * TILE, 200)
	await _wait(40)
	res.append(["the false wall fades while she is inside", cover.modulate.a < 0.1])
	res.append(["letter E (behind the false wall)", _letter_taken("E")])
	await _hold_until(["move_left"], func(): return kleo.global_position.x < 401.0 * TILE, 200)
	await _wait(70)
	res.append(["the wall closes again once she leaves", cover.modulate.a > 0.95])
	# Letter O, over the last water: the main line's jump takes it.
	_place(357.5, 27)
	await _wait(10)
	res.append(["up to the floating island (4 across, 2 up)", await _hop(360, 364, 374, 25)])
	res.append(["letter O (over the jump)", _letter_taken("O")])
	res.append(["all four letters: K-L-E-O", Game.letters_found() == 4])
	_place(419.0, 24)
	await _wait(10)
	_tap("attack")
	await _wait(40)
	res.append(["the chest by the gateway opens", _find("chest")[2].opened])
	_results(res, ["letters found: %d of 4; bonus tokens: %d of %d" % [Game.letters_found(), Game.tokens_found(), Game.level_tokens.size()]], "secrets")


func _bead_report(zone: BonusZone) -> void:
	for b in zone.beads.get_children():
		if not b.get_meta("taken", false):
			print("  bead left at ", b.global_position)


## Kleo's stride: how long it takes to find, how fast it is, how far it jumps.
func _stride_l1_2() -> void:
	_calm_enemies()
	for e in _find("enemy"):
		e.visible = false
	_start_tour()
	var lines := []
	# A plain running jump first, from a short run-up (no stride).
	_place(36.0, 30)
	await _wait(10)
	await _hold_until(["move_right"], func(): return kleo.global_position.x >= 38.5 * TILE, 200)
	_press("move_right")
	_press("jump")
	var x0 := kleo.global_position.x
	var plain_stride: bool = kleo.striding
	for i in 120:
		await _step()
		if kleo.is_on_floor() and i > 4:
			break
	var plain := kleo.global_position.x - x0
	_release_all()
	await _wait(30)
	# Then with the stride: a long run-up.
	_place(34.5, 30)
	await _wait(10)
	_press("move_right")
	var frames := 0
	for i in 200:
		await _step()
		frames += 1
		if kleo.striding:
			break
	var found_at := kleo.global_position.x - 34.5 * TILE
	await _wait(12)
	var speed := absf(kleo.velocity.x)
	_press("jump")
	x0 = kleo.global_position.x
	for i in 120:
		await _step()
		if kleo.is_on_floor() and i > 4:
			break
	var far := kleo.global_position.x - x0
	var kept: bool = kleo.striding
	_release_all()
	await _wait(20)
	var lost: bool = not kleo.striding
	lines.append("a plain running jump: %.0f px (%.2f tiles), stride %s" % [plain, plain / TILE, plain_stride])
	lines.append("the stride is found after %.2f s and %.0f px (%.1f tiles) of running" % [frames / 60.0, found_at, found_at / TILE])
	lines.append("stride speed %.0f px/s (run %.0f)" % [speed, kleo.run_speed])
	lines.append("a stride jump: %.0f px (%.2f tiles)" % [far, far / TILE])
	var res := [["no stride from a short run-up", not plain_stride], ["the stride is found on a long run", speed > kleo.run_speed + 20.0],
		["a stride jump is longer than a plain one", far > plain + 16.0], ["the stride lasts through the jump", kept],
		["stopping loses it", lost]]
	var all := true
	for r in res:
		lines.append("%s %s" % ["PASS" if r[1] else "FAIL", r[0]])
		all = all and r[1]
	lines.append("ALL PASS" if all else "SOME FAILED")
	_report(lines, "stride")


# --- The world map and the save file (room=map) --------------------------------------------------

var _entered := ""

func _note_entered(scene: String) -> void:
	_entered = scene


func _key(action: String) -> void:
	# Pressed at the start of a frame, so the map's _process sees it as new.
	await get_tree().process_frame
	Input.action_press(action)
	await _frames(2)
	Input.action_release(action)
	await _frames(20)


func _map_test() -> void:
	var res := []
	Game.save_path = "user://test_save.json"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Game.save_path))
	Game.save_enabled = true
	Game.new_game()
	var map: Node = load(Game.MAP_SCENE).instantiate()
	add_child(map)
	await _frames(10)
	await _capture("01_new_game")
	res.append(["a new game: 1-1 is open, 1-2 is shut", Game.stop_open(0) and not Game.stop_open(1)])
	await _key("move_right")
	res.append(["she can't travel to a shut stop", map._stop == 0])
	# 1-1 played: done, three letters, a token, the knot; and loose flags.
	for f in ["level_done_L1_1_OvergrownRuins", "l11_letter_k", "l11_letter_l", "l11_letter_o", "l11_token1", "l11_knot",
			"l12_letter_k", "l12_a_0", "l12_cp1"]:
		Game.flags[f] = true
	Game.currency = 57
	Game.save_game()
	await _frames(4)
	await _capture("02_after_1_1")
	var r: Dictionary = Game.record(0)
	res.append(["1-1's record: done, K L - O, 1 of 2 tokens, the knot awake",
		r["done"] and r["letters"] == [true, true, false, true] and r["tokens"] == 1 and r["knot"]])
	res.append(["1-2 opens once 1-1 is done", Game.stop_open(1) and not Game.stop_open(2)])
	# The save holds what the map keeps score of, and nothing else.
	Game.flags.clear()
	Game.currency = 0
	Game.load_game()
	res.append(["saved and loaded: the record and the Resin come back", Game.record(0) == r and Game.currency == 57])
	res.append(["beads and checkpoints are not saved", not Game.flags.has("l12_a_0") and not Game.flags.has("l12_cp1")])
	await _key("move_right")
	res.append(["she travels on to 1-2", map._stop == 1])
	await _frames(100)
	res.append(["along the map's path, to its pad", map._arrived() and map._pos.distance_to(map._pad(1)) < 1.0])
	await _capture("03_at_1_2")
	Game.flags["l12_a_0"] = true
	Game.room_host = _note_entered
	await _key("jump")
	await _frames(40)
	res.append(["jump enters the level she stands on", _entered == Game.LEVELS[1]["scene"]])
	res.append(["entering puts the level's beads back and keeps its letters", not Game.flags.has("l12_a_0") and Game.flags.has("l12_letter_k")])
	Game.save_enabled = false
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Game.save_path))
	_results(res, [], "map")
