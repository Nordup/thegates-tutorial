extends Control
class_name HintManager

@export var events: HintEvents
@export var hints: Array[HintDefinition] = []

var _id_to_scene: Dictionary = {}
var _consumed_ids: Dictionary = {}
var _current_id: StringName = &""
var _current_instance: Control = null

var _is_paused_by_tutorial: bool = false
var _last_requested_hint_id: StringName = &""


func _ready() -> void:
	add_to_group("hint_manager")
	for def in hints:
		if def == null:
			continue
		if def.id == &"" or def.scene == null:
			continue
		_id_to_scene[def.id] = def.scene
	
	events.show_hint.connect(show_hint)
	events.hide_hint.connect(hide_hint)


func show_hint(hint_id: StringName) -> void:
	print("try show hint: ", hint_id)
	_last_requested_hint_id = hint_id
	if _is_paused_by_tutorial:
		return
	if _consumed_ids.get(hint_id, false):
		return
	if _current_id == hint_id:
		return
	_clear_current()
	var scene: PackedScene = _id_to_scene.get(hint_id)
	if scene == null:
		return
	var ui := scene.instantiate()
	if ui is Control == false:
		ui.queue_free()
		return
	_current_id = hint_id
	_current_instance = ui
	add_child(ui)
	ui.visible = true
	events.current_hint_id = hint_id


func hide_hint(hint_id: StringName) -> void:
	print("try hide hint: ", hint_id)
	if _current_id == hint_id:
		_clear_current()
	_consumed_ids[hint_id] = true
	events.current_hint_id = &""


func _clear_current() -> void:
	if _current_instance:
		_current_instance.queue_free()
	_current_instance = null
	_current_id = &""
	events.current_hint_id = &""


func pause_by_tutorial() -> void:
	_is_paused_by_tutorial = true
	print("hint manager paused by tutorial")


func resume_after_tutorial_closed() -> void:
	_is_paused_by_tutorial = false
	if _last_requested_hint_id != &"":
		# Attempt to show the last requested hint now that tutorial is closed
		show_hint(_last_requested_hint_id)
	print("hint manager resumed after tutorial closed")


func is_showing(hint_id: StringName) -> bool:
	return _current_id == hint_id
