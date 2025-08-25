extends Resource
class_name HintEvents

signal show_hint(hint_id: StringName)
signal hide_hint(hint_id: StringName)

var current_hint_id: StringName = &""

var is_paused_by_tutorial: bool = false
var last_requested_hint_id: StringName = &""


func show_hint_emit(hint_id: StringName) -> void:
	# if ProgressSaver.is_hint_shown(hint_id): return
	if is_paused_by_tutorial:
		last_requested_hint_id = hint_id
		return
	show_hint.emit(hint_id)


func hide_hint_emit(hint_id: StringName) -> void:
	hide_hint.emit(hint_id)
	# ProgressSaver.mark_hint_shown(hint_id)


func is_showing(hint_id: StringName) -> bool:
	return current_hint_id == hint_id


func pause_by_tutorial() -> void:
	is_paused_by_tutorial = true
	print("hint events paused by tutorial")


func resume_after_tutorial_closed() -> void:
	is_paused_by_tutorial = false
	if last_requested_hint_id != &"":
		show_hint_emit(last_requested_hint_id)
	last_requested_hint_id = &""
	print("hint events resumed after tutorial closed")
