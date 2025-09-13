extends Control
class_name MouseMode

@export var tutorial_ui_manager: TutorialUIManager


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("show_mouse"): set_captured(false)
	if Input.is_action_just_released("show_mouse"): set_captured(true)


func set_captured(captured: bool) -> void:
	if tutorial_ui_manager._current_step in [2, 3]:
		return

	if captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
