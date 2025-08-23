extends Resource
class_name HintEvents

signal show_hint(hint_id: StringName)
signal hide_hint(hint_id: StringName)

var current_hint_id: StringName = &""


func show_hint_emit(hint_id: StringName) -> void:
	show_hint.emit(hint_id)


func hide_hint_emit(hint_id: StringName) -> void:
	hide_hint.emit(hint_id)


func is_showing(hint_id: StringName) -> bool:
	return current_hint_id == hint_id
