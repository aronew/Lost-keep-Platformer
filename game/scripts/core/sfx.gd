extends Node
## Sound effects, autoloaded as `Sfx`: `Sfx.play("jump")`.
##
## The files are the creative lead's, from their MetroidVania project
## (`assets/audio/sfx`, `assets/audio/voice`; only the sound files came over).
## Each cue below names one of that set's sounds, used here for the nearest
## thing this game has. They are stand-ins chosen by name, not by ear: judge
## them in the game and change the table. There is no music or ambience yet.
##
## Kleo's voice (`shout`, `shout_heavy`, `shout_climb`, `shout_throw`): the
## wordless shouts from the same set (a "hut" as she swings; `vo_*` files in
## `assets/audio/voice`), played by `Sfx.voice`. Like her, it has one throat:
## a new shout cuts off the last, and the light ones come only some of the
## time, so a combo never chatters.
##
## A cue has several takes (`jump_01.ogg`, `jump_02.ogg`, ...): one is picked
## at random, never the same twice running, with a little pitch drift, so a
## repeated sound (footsteps, swings) never machine-guns.

const DIR := "res://assets/audio/sfx/"
const VOICE_DIR := "res://assets/audio/voice/"
const BUS := "SFX"
const VOICE_BUS := "Voice"
const VOICES := 12

## cue -> [file stem, volume (dB), pitch drift (+/-), shortest gap between two (s)]
const CUES := {
	# Kleo moving
	"step": ["step_stone", -14.0, 0.08, 0.08],
	"jump": ["jump", -6.0, 0.05, 0.05],
	"land": ["land_light", -8.0, 0.06, 0.08],
	"land_hard": ["land_heavy", -3.0, 0.04, 0.1],
	"ledge_grab": ["ledge_grab", -6.0, 0.04, 0.1],
	"ledge_climb": ["ledge_pull", -7.0, 0.04, 0.1],
	"stride": ["thread_dash", -12.0, 0.04, 0.3],
	# Her sword
	"swing_1": ["swing_strike1", -5.0, 0.05, 0.04],
	"swing_2": ["swing_strike2", -5.0, 0.05, 0.04],
	"swing_3": ["swing_strike3", -4.0, 0.05, 0.04],
	"swing_spin": ["swing_rising", -4.0, 0.04, 0.04],
	"swing_up": ["swing_up", -5.0, 0.05, 0.04],
	"swing_air": ["swing_air", -5.0, 0.05, 0.04],
	"pogo": ["pogo_bounce", -5.0, 0.05, 0.04],
	"finisher": ["hit_finisher_layer", -4.0, 0.03, 0.05],
	# What a blow lands on
	"hit_flesh": ["hit_thread_light", -4.0, 0.06, 0.03],
	"hit_flesh_heavy": ["hit_thread_heavy", -3.0, 0.05, 0.03],
	"hit_stone": ["hit_stone", -5.0, 0.06, 0.03],
	"hit_metal": ["hit_iron_light", -6.0, 0.06, 0.03],
	"hit_pot": ["hit_porcelain_light", -5.0, 0.06, 0.03],
	"ring_off": ["parry_graze", -7.0, 0.05, 0.08],
	"smash": ["plate_break", -4.0, 0.08, 0.05],
	"smash_pot": ["hit_porcelain_heavy", -4.0, 0.06, 0.05],
	"smash_stone": ["hit_iron_heavy", -3.0, 0.05, 0.05],
	# Being hurt
	"hurt": ["hurt", -3.0, 0.04, 0.1],
	"death": ["death_unravel", -3.0, 0.0, 0.5],
	"respawn": ["respawn", -6.0, 0.0, 0.5],
	# Carrying
	"throw": ["dodge", -6.0, 0.05, 0.08],
	# Creatures
	"enemy_tell": ["tell_parryable", -6.0, 0.03, 0.2],
	"enemy_lunge": ["resonant_lunge", -7.0, 0.05, 0.1],
	# Things found
	"resin": ["resonance_gain", -10.0, 0.0, 0.02],
	"letter": ["soul_ready", -5.0, 0.0, 0.1],
	"letters_all": ["parry_perfect", -4.0, 0.0, 0.3],
	"checkpoint": ["mend", -4.0, 0.0, 0.5],
	"token_appears": ["resonant_coil", -6.0, 0.03, 0.2],
	"token": ["perfect_dodge", -4.0, 0.0, 0.3],
	"knot": ["unravel_cast", -4.0, 0.0, 0.5],
}

## Kleo's voice: cue -> [file stem, volume (dB), pitch drift, shortest gap (s),
## chance it sounds at all]. Measured pitch of the takes: about 300 to 470 Hz.
const VOICE := {
	"shout": ["vo_swing_rise", -4.0, 0.04, 0.04, 0.5],
	"shout_heavy": ["vo_swing_heavy", -3.0, 0.03, 0.04, 1.0],
	"shout_climb": ["vo_ledge_pull", -6.0, 0.04, 0.3, 0.5],
	"shout_throw": ["vo_dodge", -5.0, 0.04, 0.1, 0.5],
}

var _takes := {}      # cue -> Array[AudioStream]
var _last_take := {}  # cue -> index of the take played last
var _last_time := {}  # cue -> when it last played (ms)
var _players: Array[AudioStreamPlayer] = []
var _voice: AudioStreamPlayer
var _next := 0
## Resin taken in a run climbs in pitch, bead after bead.
var _resin_run := 0
var _resin_ms := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if AudioServer.get_bus_index(BUS) < 0:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, BUS)
	if AudioServer.get_bus_index(VOICE_BUS) < 0:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, VOICE_BUS)
	_voice = AudioStreamPlayer.new()
	_voice.bus = VOICE_BUS
	add_child(_voice)
	for i in VOICES:
		var p := AudioStreamPlayer.new()
		p.bus = BUS
		add_child(p)
		_players.append(p)
	for cue in CUES.keys() + VOICE.keys():
		var stem: String = CUES[cue][0] if CUES.has(cue) else VOICE[cue][0]
		var takes: Array = []
		for n in range(1, 9):
			var path := "%s%s_%02d.ogg" % [DIR if CUES.has(cue) else VOICE_DIR, stem, n]
			if not ResourceLoader.exists(path):
				break
			takes.append(load(path))
		_takes[cue] = takes


## Play a cue. `volume` (dB) and `pitch` (a factor) adjust this one playing.
func play(cue: String, volume := 0.0, pitch := 1.0) -> void:
	var takes: Array = _takes.get(cue, [])
	if takes.is_empty():
		return
	var spec: Array = CUES[cue]
	var now := Time.get_ticks_msec()
	if now - int(_last_time.get(cue, -100000)) < int(float(spec[3]) * 1000.0):
		return
	_last_time[cue] = now
	var i := randi() % takes.size()
	if takes.size() > 1 and i == int(_last_take.get(cue, -1)):
		i = (i + 1) % takes.size()
	_last_take[cue] = i
	var p := _free_player()
	p.stream = takes[i]
	p.volume_db = float(spec[1]) + volume
	p.pitch_scale = maxf(pitch + randf_range(-float(spec[2]), float(spec[2])), 0.1)
	p.play()


## A shout from Kleo (VOICE). It cuts off the one before.
func voice(cue: String) -> void:
	var takes: Array = _takes.get(cue, [])
	if takes.is_empty():
		return
	var spec: Array = VOICE[cue]
	var now := Time.get_ticks_msec()
	if now - int(_last_time.get(cue, -100000)) < int(float(spec[3]) * 1000.0) or randf() >= float(spec[4]):
		return
	_last_time[cue] = now
	var i := randi() % takes.size()
	if takes.size() > 1 and i == int(_last_take.get(cue, -1)):
		i = (i + 1) % takes.size()
	_last_take[cue] = i
	_voice.stream = takes[i]
	_voice.volume_db = float(spec[1])
	_voice.pitch_scale = 1.0 + randf_range(-float(spec[2]), float(spec[2]))
	_voice.play()


## A bead of Resin: each one soon after the last sounds a step higher.
func resin() -> void:
	var now := Time.get_ticks_msec()
	_resin_run = _resin_run + 1 if now - _resin_ms < 600 else 0
	_resin_ms = now
	play("resin", 0.0, 1.0 + 0.05 * float(mini(_resin_run, 12)))


func _free_player() -> AudioStreamPlayer:
	for i in VOICES:
		var p := _players[(_next + i) % VOICES]
		if not p.playing:
			_next = (_next + i + 1) % VOICES
			return p
	var q := _players[_next]
	_next = (_next + 1) % VOICES
	return q
