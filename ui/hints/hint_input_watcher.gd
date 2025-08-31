extends Node

@export var events: HintEvents


var is_wasd_emitted: bool = false
var is_jump_emitted: bool = false


func _unhandled_input(event: InputEvent) -> void:
	if EditMode.is_enabled: return

	# Hide WASD hint on any movement input (only if currently showing)
	if event.is_action_pressed("move_left") or event.is_action_pressed("move_right") or event.is_action_pressed("move_up") or event.is_action_pressed("move_down"):
		if events.is_showing(&"wasd") and not is_wasd_emitted:
			events.hide_hint_emit(&"wasd")
			is_wasd_emitted = true
	
	# Hide jump hint on jump press (only if currently showing)
	if event.is_action_pressed("jump"):
		if events.is_showing(&"jump") and not is_jump_emitted:
			events.hide_hint_emit(&"jump")
			is_jump_emitted = true
