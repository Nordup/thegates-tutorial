extends Control

signal completed
signal closed

@export var close: TextureButton
@export var popup: PopupAnim
@export var panel: Panel
@export var panel_alpha: float = 0.0
@export var complete_immediately: bool

var shader_mat: ShaderMaterial
var color: Color


func _ready() -> void:
	close.pressed.connect(on_close_pressed)
	if complete_immediately:
		completed.emit()


func on_close_pressed() -> void:
	hide_with_tween()

	await get_tree().create_timer(0.15).timeout
	completed.emit()
	closed.emit()

	queue_free()


func hide_with_tween() -> void:
	popup.hide_popup()

	shader_mat = panel.material as ShaderMaterial
	color = shader_mat.get_shader_parameter("tint_color")

	var tween := create_tween()
	tween.tween_method(set_shader_panel_tint_alpha, 1, panel_alpha, 0.3)


func set_shader_panel_tint_alpha(target_alpha: float) -> void:
	var to_color := color * target_alpha
	shader_mat.set_shader_parameter("tint_color", to_color)
