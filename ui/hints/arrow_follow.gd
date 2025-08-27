extends Sprite2D

@export var target_position: Vector2 = Vector2.ZERO
@export var hide_distance: float = 64.0
@export var offset_distance: float = 48.0
@export var rotation_offset_degrees: float = 0.0


func _process(delta: float) -> void:
	if not visible:
		return

	# Get mouse in viewport space and convert to global canvas space.
	var viewport := get_viewport()
	var mouse_vp: Vector2 = viewport.get_mouse_position()
	var mouse_position: Vector2 = viewport.get_canvas_transform().affine_inverse() * mouse_vp

	var to_target_from_mouse: Vector2 = target_position - mouse_position
	var offset_direction: Vector2 = Vector2.ZERO
	if to_target_from_mouse.length() > 0.001:
		offset_direction = to_target_from_mouse.normalized()

	global_position = mouse_position + offset_direction * offset_distance

	var distance_to_target: float = mouse_position.distance_to(target_position) + delta * 0.0
	visible = distance_to_target > hide_distance

	var to_target: Vector2 = target_position - global_position
	if to_target.length() > 0.001:
		rotation = to_target.angle() + deg_to_rad(rotation_offset_degrees)
