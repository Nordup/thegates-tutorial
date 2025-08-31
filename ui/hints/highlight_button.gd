extends Node

@export var button_id: String


func _ready() -> void:
	print("sending command to highlight button: ", button_id)
	if get_tree().has_method("send_command"):
		get_tree().send_command("highlight_button", [button_id])
	else:
		push_warning("Tree doesn't have method send_command. Do nothing")
