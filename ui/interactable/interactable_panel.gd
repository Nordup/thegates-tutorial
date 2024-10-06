extends Node

const SHOW = "show"
const HIDE = "hide"

@export var events: InteractableEvents
@export var label: Label
@export var animation: AnimationPlayer

var current: InteractableBase
var current_text: String
var blocked: InteractableBase


func _ready() -> void:
	events.on_entered.connect(on_interactable_entered)
	events.on_exited.connect(on_interactable_exited)
	events.on_blocked.connect(on_interactable_blocked)
	events.on_unblocked.connect(on_interactable_unblocked)
	animation.play(HIDE, -1, 1, true)


func on_interactable_entered(text: String, interactable: InteractableBase) -> void:
	current = interactable
	
	label.text = text
	animation.play(SHOW)


func on_interactable_exited(interactable: InteractableBase) -> void:
	if interactable != current: return
	current = null
	
	animation.play(HIDE)


func on_interactable_blocked(interactable: InteractableBase) -> void:
	if current == interactable: animation.play(HIDE)


func on_interactable_unblocked(interactable: InteractableBase) -> void:
	if current == interactable: animation.play(SHOW)
