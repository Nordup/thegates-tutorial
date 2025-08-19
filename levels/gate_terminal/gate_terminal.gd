extends Node3D

@export var start_url: String
@export var interactable: InteractableTerminal
@export var terminal_info: TerminalInfo
@export var stand: StandBase
@export var portal: Portal

## Sync property
@export var synced_url: String

var current_url: String


func _ready() -> void:
	interactable.on_load_gate.connect(on_load_gate)
	on_load_gate(current_url)


func on_load_gate(url: String) -> void:
	if url.is_empty(): return
	if current_url == url: return
	
	print("Loading gate: " + url)
	var success = await terminal_info.set_info(url)
	if not success: return
	
	current_url = url
	portal.url = url
	
	stand.render()
