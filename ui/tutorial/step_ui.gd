extends Control

signal completed
signal closed

@export var close: TextureButton
@export var complete_immediately: bool


func _ready() -> void:
	close.pressed.connect(on_close_pressed)
	if complete_immediately:
		completed.emit()


func on_close_pressed() -> void:
	completed.emit()
	closed.emit()
