extends Control
class_name TutorialUIManager

@export var hint_events: HintEvents
@export var mouse_mode: MouseMode
@export var tutorial_scenes: Array[PackedScene] = []
@export var dont_hide_mouse_steps: Array[int] = []

var _current_instance: Node = null
var _current_step: int = 1


func show_step_scene(tutorial_step: int) -> void:
	print("tutorial_step: ", tutorial_step)
	_current_step = tutorial_step

	if ProgressSaver.is_step_completed(tutorial_step):
		print("step %d is already completed" % tutorial_step)
		capture_mouse()
		return

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
	_current_instance.completed.connect(on_completed)
	_current_instance.closed.connect(on_closed)

	add_child(_current_instance)

	hint_events.pause_by_tutorial()
	release_mouse()


func on_completed() -> void:
	ProgressSaver.mark_step_completed(_current_step)


func on_closed() -> void:
	_current_instance = null

	hint_events.resume_after_tutorial_closed()
	capture_mouse()


func release_mouse() -> void:
	EditMode.is_enabled = true
	mouse_mode.set_captured(false)


func capture_mouse() -> void:
	if dont_hide_mouse_steps.has(_current_step):
		return
	
	mouse_mode.set_captured(true)

	# Player camera thinks mouse moved when setting mouse mode to captured
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	EditMode.is_enabled = false
