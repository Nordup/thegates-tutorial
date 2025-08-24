extends Node3D
class_name HintVisibility

@export var events: HintEvents
@export var hint_show_id: StringName
@export var hint_hide_id: StringName


func _ready() -> void:
	visible = false
	events.show_hint.connect(on_show_hint)
	on_show_hint(events.current_hint_id)


func on_show_hint(id: StringName) -> void:
	if id == hint_show_id:
		visible = true

	if id == hint_hide_id:
		visible = false
