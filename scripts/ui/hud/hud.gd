extends CanvasLayer
class_name HUD

@export var blocker : ColorRect

## Fades to black within input fade_duration.
## Returns a tween for awaiting .finished signal.
func fade_to_black(fade_duration : float = 0.5) -> Tween:
	blocker.modulate.a = 0.0
	var tween : Tween = create_tween()
	tween.tween_property(blocker, "modulate:a", 1.0, fade_duration)
	return tween

## Fades back in from black within input fade_duration.
## Returns a tween for awaiting .finished signal.
func fade_in(fade_duration : float = 0.5) -> Tween:
	blocker.modulate.a = 1.0
	var tween : Tween = create_tween()
	tween.tween_property(blocker, "modulate:a", 0.0, fade_duration)
	return tween
