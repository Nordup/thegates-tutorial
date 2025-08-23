extends Control
# class_name HintManager

@export var events: HintEvents
@export var hints: Array[HintDefinition] = []

var _id_to_scene: Dictionary = {}
var _consumed_ids: Dictionary = {}
var _current_id: StringName = &""
var _current_instance: Control = null


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


func hide_hint(hint_id: StringName) -> void:
	print("try hide hint: ", hint_id)
	if _current_id == hint_id:
		_clear_current()
	_consumed_ids[hint_id] = true


func _clear_current() -> void:
	if _current_instance:
		_current_instance.queue_free()
	_current_instance = null
	_current_id = &""


func is_showing(hint_id: StringName) -> bool:
	return _current_id == hint_id
