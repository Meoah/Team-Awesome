extends Control

@export_category("Audio")
@export var default_bgm : AudioStream

@export_category("Children Nodes")
@export var hold_skip_control : Control
@export var hold_skip_bar : ProgressBar
@export var hud : HUD

@export_category("PackedScenes")
@export var next_scene : PackedScene

const SKIP_FADE_DURATION : float = 0.12
const HOLD_TO_SKIP_SECONDS : float = 1.0
const SKIP_SEEK_TIME : float = 16.99
const SHOW_SKIP_DELAY : float = 0.12

var skip_tween: Tween
var is_holding_skip: bool = false
var hold_elapsed: float = 0.0
var has_skipped: bool = false
var skip_visible: bool = false

func _ready() -> void:
	PlayManager.request_idle_day_state()
	SignalBus.run_intro.connect(play_animation)
	
	hold_skip_bar.value = 0.0
	hold_skip_bar.max_value = HOLD_TO_SKIP_SECONDS
	hold_skip_bar.visible = true
	hold_skip_control.modulate.a = 0.0
	
	var popup_parameters = {
		"dialogue_id" = 0001,
		#"flags" = BasePopup.POPUP_FLAG.DISMISS_ON_ESCAPE
	}
	if PlayManager.request_dialogue_day_state():
		GameManager.popup_queue.show_popup(BasePopup.POPUP_TYPE.DIALOGUE, popup_parameters)
	
	for child in hud.get_children():
		if child is TouchScreenControls:
			child.ignore_input = true
			break

func play_animation():
	AudioEngine.play_bgm(default_bgm, "", false, 5.0)
	$AnimationPlayer.play("intro_sequence")

func _process(delta: float) -> void:
	if not is_holding_skip : return
	if has_skipped : return
	
	hold_elapsed += delta
	if hold_elapsed >= SHOW_SKIP_DELAY && !skip_visible:
		skip_visible = true
		_fade_bar_to(1.0)
	
	var progress: float = clampf(hold_elapsed / HOLD_TO_SKIP_SECONDS, 0.0, 1.0)
	
	hold_skip_bar.value = progress
	if progress >= 1.0:_skip_intro()


func _input(event: InputEvent) -> void:
	if PlayManager.get_current_state() is DialogueDayState : return
	
	if event.is_action_pressed("mouse_click") || event.is_action_pressed("action"):
		if !is_holding_skip:
			_start_hold_skip()

	if event.is_action_released("mouse_click") || event.is_action_released("action"):
		if !Input.is_action_pressed("mouse_click") && !Input.is_action_pressed("action"):
			_cancel_hold_skip()

func _start_hold_skip() -> void:
	is_holding_skip = true
	has_skipped = false
	skip_visible = false
	hold_elapsed = 0.0
	hold_skip_bar.value = 0.0


func _cancel_hold_skip() -> void:
	is_holding_skip = false
	hold_elapsed = 0.0
	has_skipped = false
	skip_visible = false
	hold_skip_bar.value = 0.0
	_fade_bar_to(0.0)

func _fade_bar_to(target_alpha: float) -> void:
	if skip_tween: skip_tween.kill()

	skip_tween = create_tween()
	skip_tween.set_trans(Tween.TRANS_SINE)
	skip_tween.set_ease(Tween.EASE_IN_OUT)
	skip_tween.tween_property(hold_skip_control, "modulate:a", target_alpha, SKIP_FADE_DURATION)

func _skip_intro() -> void:
	has_skipped = true
	is_holding_skip = false
	hold_skip_bar.value = 1.0
	_fade_bar_to(0.0)
	$AnimationPlayer.seek(SKIP_SEEK_TIME, true)
	set_process_input(false)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "intro_sequence":
		GameManager.change_scene_deferred(next_scene)
