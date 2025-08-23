extends Node

@export var events: HintEvents


func _unhandled_input(event: InputEvent) -> void:
	if EditMode.is_enabled: return

	# Hide WASD hint on any movement input
	if event.is_action_pressed("move_left") or event.is_action_pressed("move_right") or event.is_action_pressed("move_up") or event.is_action_pressed("move_down"):
		events.hide_hint_emit(&"wasd")

	# Hide jump hint on jump press
	if event.is_action_pressed("jump"):
		events.hide_hint_emit(&"jump")
