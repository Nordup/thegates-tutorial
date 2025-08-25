extends Control

signal closed

@export var close: TextureButton


func _ready() -> void:
	close.pressed.connect(on_close_pressed)


func on_close_pressed() -> void:
	closed.emit()
