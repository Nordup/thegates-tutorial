extends Control
class_name MouseMode


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("show_mouse"): set_captured(false)
	if Input.is_action_just_released("show_mouse"): set_captured(true)


func set_captured(captured: bool) -> void:
	if captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
