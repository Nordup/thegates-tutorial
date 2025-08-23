extends Node3D
class_name Portal

@export var url: String
@export var hint_id: StringName
@export var hint_events: HintEvents

@onready var network_timeout: float = ProjectSettings.get("network/limits/tcp/connect_timeout_seconds")


func _on_portal_entered(body: Node3D):
	if not body is Player: return
	play_enter_audio()

	if hint_id != &"" and hint_events.is_showing(hint_id):
		hint_events.hide_hint_emit(hint_id)
	
	print("Portal_entered: " + url)
	await get_tree().create_timer(0.3).timeout
	
	if get_tree().has_method("send_command"):
		get_tree().send_command("open_gate", [url])
	else:
		push_warning("Tree doesn't have method send_command. Do nothing")


func play_enter_audio():
	$AudioStreamPlayer3D.play()
