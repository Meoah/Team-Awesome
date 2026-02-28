extends Node

const BUS_MASTER : String = "Master"
const BUS_BGM : String = "BGM"
const BUS_SFX : String = "SFX"
const BUS_DIALOGUE : String = "Dialogue"

## BGM Consts and Variables
const DEFAULT_FADE_TIME : float = 0.35
const MIN_FADE_DB : float = -80.0
const RESUME_END_CLOSE_ENOUGH : float = 0.06

var bgm_player_a : AudioStreamPlayer = null
var bgm_player_b : AudioStreamPlayer = null
var bgm_is_a_active : bool = true
var bgm_active_track_key : String = ""
var bgm_progress_by_track : Dictionary = {}
var bgm_fade_tween : Tween = null
var bgm_volume_linear : float = 1.0
var bgm_active_player : AudioStreamPlayer = null

## SFX Consts and Variables

func _ready() -> void:
	# Ensures sounds run while paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Setup systems.
	_setup_bgm()

# --- BGM Methods
## Initializes the BGM players and connects them to the correct bus.
func _setup_bgm() -> void:
	bgm_player_a = AudioStreamPlayer.new()
	bgm_player_b = AudioStreamPlayer.new()
	add_child(bgm_player_a)
	add_child(bgm_player_b)
	
	bgm_player_a.bus = BUS_BGM
	bgm_player_b.bus = BUS_BGM
	bgm_player_a.volume_db = 0.0
	bgm_player_b.volume_db = MIN_FADE_DB
	
	_apply_bgm_bus_volume()

## Attempts to play the requested audio as a BGM.
func play_bgm(incoming_stream_path : String, should_restart : bool = false, fade_time : float = DEFAULT_FADE_TIME) -> void:
	# Abort if either the path itself or the is empty or if the path does not point to a valid AudioStream.
	if incoming_stream_path.is_empty() : return
	var incoming_stream : AudioStream = load(incoming_stream_path) as AudioStream
	if incoming_stream == null : return
	
	# Caches the current BGM progress if there is any playing.
	_cache_active_bgm_progress()
	
	# Retrieves the start position.
	var start_position : float = _get_resume_position(incoming_stream_path, incoming_stream, should_restart)
	
	# If it's the same track, either restart/resume on the active bgm_player.
	if incoming_stream_path == bgm_active_track_key and bgm_active_track_key != "":
		# Ensures we're picking the right bgm_player.
		var active_bgm_player : AudioStreamPlayer = _get_active_bgm_player()
		if active_bgm_player:
			active_bgm_player.stream = incoming_stream
			active_bgm_player.bus = BUS_BGM
			active_bgm_player.volume_db = 0.0
			active_bgm_player.play(start_position)
			_bind_bgm_finished(active_bgm_player, incoming_stream_path, incoming_stream)
		return
	
	# If it's a new track, crossfade into it.
	# Finds the active and inactive bgm_players and preps them for crossfading.
	var outgoing_player : AudioStreamPlayer = _get_active_bgm_player()
	var incoming_player : AudioStreamPlayer = _get_inactive_bgm_player()
	
	# Preps the incoming_player's metadata.
	bgm_active_track_key = incoming_stream_path
	incoming_player.stream = incoming_stream
	incoming_player.bus = BUS_BGM
	incoming_player.volume_db = MIN_FADE_DB
	incoming_player.play(start_position)
	
	# Check if the outgoing_player is playing. If not, don't bother fading it out.
	var outgoing_for_fade : AudioStreamPlayer = outgoing_player if outgoing_player.playing else null
	_start_bgm_crossfade(outgoing_for_fade, incoming_player, fade_time)
	
	# Binds the finished signal of the newly active player to trigger _on_bgm_player_finished
	#	which will reset the cached progress on naturally finishing a nonlooping BGM.
	_bind_bgm_finished(incoming_player, incoming_stream_path, incoming_stream)

## Requests to stop the currently playing BGM. If a fade_time is set, it will fade out within that time.
##	Otherwise, hard cuts.
func stop_bgm(fade_time : float = 0.0) -> void:
	# Caches the current BGM progress if there is any playing.
	_cache_active_bgm_progress()
	
	# Finds both bgm_players.
	var active_player : AudioStreamPlayer = _get_active_bgm_player()
	var inactive_player : AudioStreamPlayer = _get_inactive_bgm_player()
	
	# If no fade time, hard cuts all players to stop and resets bgm_active_track_key.
	if fade_time <= 0.0:
		if active_player : active_player.stop()
		if inactive_player : inactive_player.stop()
		bgm_active_track_key = ""
		return
	
	# If there is a fade time, set up the fade.
	# Ensure the bgm_fade_tween is killed.
	_kill_bgm_fade_tween()
	
	# If the active_player is playing, fade it out to MIN_FADE_DB. When fade is done,
	#	stops the player and resets bgm_active_track_key.
	if active_player && active_player.playing:
		bgm_fade_tween = create_tween()
		bgm_fade_tween.tween_property(active_player, "volume_db", MIN_FADE_DB, fade_time)
		bgm_fade_tween.tween_callback(func() -> void:
			active_player.stop()
			bgm_active_track_key = ""
		)
	# Stops the active_player if it's paused and also stops the inactive_player.
	# No fade required as it shouldn't be audible.
	if active_player && active_player.stream_paused: active_player.stop()
	if inactive_player : inactive_player.stop()

## Requests to pause the current BGM.
func pause_bgm() -> void:
	# Caches the current BGM progress if there is any playing.
	_cache_active_bgm_progress()
	
	# Checks to see if there is an active_player, if so, pause it.
	var active_player : AudioStreamPlayer = _get_active_bgm_player()
	if active_player : active_player.stream_paused = true

## Requests to resume the current BGM.
func resume_bgm() -> void:
	# Checks to see if there is an active_player, if so, unpause it.
	var active_player : AudioStreamPlayer = _get_active_bgm_player()
	if active_player : active_player.stream_paused = false

## Sets the BGM volume from a linear value between (0..1).
func set_bgm_volume(incoming_linear : float) -> void:
	bgm_volume_linear = clamp(incoming_linear, 0.0, 1.0)
	_apply_bgm_bus_volume()

## Gets the current BGM volume as a linear value between (0..1).
func get_bgm_volume() -> float:
	return bgm_volume_linear

## Clears the current BGM progress cache. If a path is input, clears only that specific track if it exists.
func clear_bgm_progress(incoming_stream_path : String = "") -> void:
	if incoming_stream_path.is_empty():
		bgm_progress_by_track.clear()
		return
	if bgm_progress_by_track.has(incoming_stream_path):
		bgm_progress_by_track.erase(incoming_stream_path)

## Outputs BGM data.
func get_bgm_progress_save_data() -> Dictionary:
	# Outputs a copy to not accidently mutate the variables here.
	var copy : Dictionary = {}
	for key in bgm_progress_by_track.keys():
		copy[key] = bgm_progress_by_track[key]
	return copy

## Loads BGM data.
func set_bgm_progress_save_data(incoming_data : Dictionary) -> void:
	bgm_progress_by_track.clear()
	for key in incoming_data.keys():
		bgm_progress_by_track[str(key)] = float(incoming_data[key])

# 
func _apply_bgm_bus_volume() -> void:
	# Attempts to locate the correct bus. Do nothing if cannot locate.
	var bus_index : int = AudioServer.get_bus_index(BUS_BGM)
	if bus_index == -1 : return
	
	# Engine gets weird when we work with 0, as linear_to_db() sets it to -INF.
	#	We use safe_linear to prevent this, do not change this.
	var safe_linear : float = max(0.0001, bgm_volume_linear)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(safe_linear))

## Crossfades from outgoing_player into the incoming_player.
func _start_bgm_crossfade(outgoing_player : AudioStreamPlayer, incoming_player : AudioStreamPlayer, fade_time : float) -> void:
	# Ensure the bgm_fade_tween is killed.
	_kill_bgm_fade_tween()
	
	# Sets the active_bgm to bgm_player_a if it's about to be crossfaded into.
	bgm_is_a_active = (incoming_player == bgm_player_a)
	
	# If requested fade_time is 0.0 or less, don't bother setting up a tween, just smash cut with no crossfade.
	if fade_time <= 0.0:
		if outgoing_player : outgoing_player.stop()
		incoming_player.volume_db = 0.0
		return
	
	# Sets up the bgm_fade_tween to fade in.
	bgm_fade_tween = create_tween()
	bgm_fade_tween.tween_property(incoming_player, "volume_db", 0.0, fade_time)
	
	# If we have an outgoing_player, fade that out parallel to the incoming_player, causing the crossfade.
	#	Stops the outgoing_player once the fade out is complete.
	if outgoing_player:
		bgm_fade_tween.parallel().tween_property(outgoing_player, "volume_db", MIN_FADE_DB, fade_time)
		bgm_fade_tween.tween_callback(func() -> void : outgoing_player.stop())

## Kills the bgm_fade_tween if it's active.
func _kill_bgm_fade_tween() -> void:
	if bgm_fade_tween && bgm_fade_tween.is_running() : bgm_fade_tween.kill()
	bgm_fade_tween = null

## Caches the current BGM's progress to bgm_progress_by_track.
func _cache_active_bgm_progress() -> void:
	# Aborts if there's no active BGM playing.
	if bgm_active_track_key == "" : return
	var active_player : AudioStreamPlayer = _get_active_bgm_player()
	if active_player == null : return
	
	# Saves wherever the current bgm_player is at into the progress tracker.
	if active_player.playing or active_player.stream_paused:
		bgm_progress_by_track[bgm_active_track_key] = active_player.get_playback_position()

## Returns with the saved progress position if requested, otherwise 0.0.
func _get_resume_position(incoming_track_key : String, incoming_stream : AudioStream, should_restart : bool) -> float:
	# If restart requested or this is a newly requested track, return 0.0.
	if should_restart : return 0.0
	if !bgm_progress_by_track.has(incoming_track_key) : return 0.0
	
	# Grabs the metadata from the requested track.
	var cached : float = float(bgm_progress_by_track[incoming_track_key])
	var length : float = incoming_stream.get_length()
	var loops : bool = _check_if_loops(incoming_stream)
	
	# If the length is <= 0.0, ensure the return is at least 0.0 and trust the cached value.
	if length <= 0.0 : return max(0.0, cached)
	# If the length is close enough to the end of the track and doesn't need to loop,
	#	just assume it has ended and restart to the beginning anyways.
	if !loops and cached >= max(0.0, length - RESUME_END_CLOSE_ENOUGH) : return 0.0
	# Defense if cached > length and is supposed to loop.
	if loops : return fposmod(cached, length)
	
	# If all defenses passed, just return the cached value.
	return cached

## Attempts to check if the track loops or not. Has to be done like this because Godot
##	does not have this check natively for some reason.
func _check_if_loops(incoming_stream : AudioStream) -> bool:
	if incoming_stream is AudioStreamWAV:
		return (incoming_stream as AudioStreamWAV).loop_mode != AudioStreamWAV.LOOP_DISABLED
	if incoming_stream is AudioStreamOggVorbis:
		return (incoming_stream as AudioStreamOggVorbis).loop
	if incoming_stream is AudioStreamMP3:
		return (incoming_stream as AudioStreamMP3).loop
	return false

## Updates which bgm_player is bound to the signal
func _bind_bgm_finished(incoming_player : AudioStreamPlayer, incoming_track_key : String, incoming_stream : AudioStream) -> void:
	# Disconnect the previous signal if it exists.
	if bgm_active_player:
		if bgm_active_player.finished.is_connected(_on_bgm_player_finished):
			bgm_active_player.finished.disconnect(_on_bgm_player_finished)
	
	# Sets the bgm_active_player to the incoming_player. Ensures the signal is bound correctly.
	bgm_active_player = incoming_player
	if incoming_player && !incoming_player.finished.is_connected(_on_bgm_player_finished):
		incoming_player.finished.connect(_on_bgm_player_finished.bind(incoming_track_key, incoming_stream))

## Reacts on the bgm_active_player.finished signal to reset a non-looping track back to 0.0
##	when it's finished naturally. It then resets bgm_active_track_key back to empty.
func _on_bgm_player_finished(incoming_track_key : String, _incoming_stream : AudioStream) -> void:
	bgm_progress_by_track[incoming_track_key] = 0.0
	if incoming_track_key == bgm_active_track_key : bgm_active_track_key = ""

## Returns with whichever is the active bgm_player.
func _get_active_bgm_player() -> AudioStreamPlayer:
	return (bgm_player_a if bgm_is_a_active else bgm_player_b)

## Returns with whichever isn't the active bgm_player.
func _get_inactive_bgm_player() -> AudioStreamPlayer:
	return (bgm_player_b if bgm_is_a_active else bgm_player_a)
