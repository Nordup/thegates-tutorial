extends Node3D
class_name Portal

@export var url: String
@onready var network_timeout: float = ProjectSettings.get("network/limits/tcp/connect_timeout_seconds")


func _on_portal_entered(body: Node3D):
	if not body is Player: return
	play_enter_audio()
	
	if body.get_multiplayer_authority() != multiplayer.get_unique_id() and Connection.is_peer_connected:
		hide_client_body(body)
		return
	
	print("Portal_entered: " + url)
	await get_tree().create_timer(0.3).timeout
	
	if get_tree().has_method("send_command"):
		get_tree().send_command("open_gate", [url])
	else:
		push_warning("Tree doesn't have method send_command. Do nothing")


func play_enter_audio():
	$AudioStreamPlayer3D.play()


func hide_client_body(body: Node3D):
	await get_tree().create_timer(0.05).timeout
	body.visible = false
	
	# In case of interpolation error, show body if server hasn't kicked out the client
	await get_tree().create_timer(network_timeout + 1.0).timeout
	if is_instance_valid(body):
		body.visible = true
