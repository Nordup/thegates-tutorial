extends Control
class_name HintManager

@export var events: HintEvents
@export var hints: Array[HintDefinition] = []

@export var show_delay_sec: float = 0.0
@export var hide_delay_sec: float = 1

var _id_to_scene: Dictionary = {}
var _consumed_ids: Dictionary = {}
var _current_id: StringName = &""
var _current_instance: Control = null

var show_request_seq: int = 0
var hide_request_seq: int = 0


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

	show_request_seq += 1
	var seq := show_request_seq
	await get_tree().create_timer(show_delay_sec).timeout
	if seq != show_request_seq:
		return
	if _consumed_ids.get(hint_id, false):
		return
	if _current_id == hint_id:
		return

	# Cancel any pending hide because a new show has arrived
	hide_request_seq += 1
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

	hide_request_seq += 1
	var seq := hide_request_seq
	await get_tree().create_timer(hide_delay_sec).timeout
	if seq != hide_request_seq:
		return
	if _current_id == hint_id:
		_clear_current()
		_consumed_ids[hint_id] = true
		events.current_hint_id = &""
		return
	# If a different hint is currently showing, hide it as well
	if _current_instance:
		var shown_id := _current_id
		_clear_current()
		if shown_id != &"":
			_consumed_ids[shown_id] = true
		events.current_hint_id = &""


func _clear_current() -> void:
	if _current_instance:
		_current_instance.queue_free()
	_current_instance = null
	_current_id = &""
	events.current_hint_id = &""


func is_showing(hint_id: StringName) -> bool:
	return _current_id == hint_id
