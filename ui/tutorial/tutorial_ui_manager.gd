extends Control

class_name TutorialUIManager

@export var mouse_mode: MouseMode
@export var tutorial_scenes: Array[PackedScene] = []
@export_range(1, 4) var tutorial_step: int = 1

var _current_instance: Node = null


func _ready() -> void:
	_show_step_scene()


func _show_step_scene() -> void:
	if _current_instance and is_instance_valid(_current_instance):
		_current_instance.queue_free()

	if tutorial_scenes.is_empty():
		push_warning("No tutorial scenes assigned.")
		return

	var index := tutorial_step - 1
	if index < 0 or index >= tutorial_scenes.size():
		push_warning("Tutorial step %d has no corresponding scene." % tutorial_step)
		return

	var scene := tutorial_scenes[index]
	if scene == null:
		push_warning("Scene at index %d is null." % index)
		return

	_current_instance = scene.instantiate()
	add_child(_current_instance)

	mouse_mode.set_captured(false)
	EditMode.is_enabled = true

	_current_instance.closed.connect(on_closed)


func on_closed() -> void:
	if _current_instance and is_instance_valid(_current_instance):
		_current_instance.queue_free()
	_current_instance = null

	mouse_mode.set_captured(true)
	EditMode.is_enabled = false
