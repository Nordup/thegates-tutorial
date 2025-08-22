extends Area3D
class_name HintArea3D

@export var hint_id: StringName

var _has_fired: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if _has_fired:
		return
	if body is Player:
		HintManager.request_show(hint_id)
		_has_fired = true


func _on_body_exited(body: Node) -> void:
	if not _has_fired:
		return
	if body is Player:
		HintManager.request_hide_and_consume(hint_id)
