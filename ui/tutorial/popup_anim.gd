extends Control
class_name PopupAnim


func _ready():
	if visible:
		show_popup()


func show_popup() -> void:
	var tween = create_tween()
	modulate.a = 0.0
	scale = Vector2(0.9, 0.9)
	# Fade + scale the popup in parallel
	tween.parallel().tween_property(self, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.22).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func hide_popup() -> void:
	var tween = create_tween()
	# Fade + scale the popup out in parallel
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.2)
	tween.parallel().tween_property(self, "scale", Vector2(0.92, 0.92), 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	visible = false


func show_popup_with_delay() -> void:
	await get_tree().create_timer(0.2).timeout
	visible = true
	show_popup()
