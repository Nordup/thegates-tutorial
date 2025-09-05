extends Panel


@export var clip_by: Panel


func _ready() -> void:
	if clip_by:
		if clip_by.has_signal("item_rect_changed"):
			clip_by.item_rect_changed.connect(update_clip)
		elif clip_by.has_signal("resized"):
			clip_by.resized.connect(update_clip)
	if has_signal("item_rect_changed"):
		item_rect_changed.connect(update_clip)
	elif has_signal("resized"):
		resized.connect(update_clip)
	ensure_material()
	update_clip()


func ensure_material() -> void:
	if material == null or not (material is ShaderMaterial):
		var shader := load("res://ui/hints/dark_background.gdshader")
		var sm := ShaderMaterial.new()
		sm.shader = shader
		material = sm
	(material as ShaderMaterial).set_shader_parameter("panel_size", size)


func update_clip() -> void:
	var sm: ShaderMaterial = material as ShaderMaterial
	if sm == null:
		return
	sm.set_shader_parameter("panel_size", size)
	if clip_by == null:
		sm.set_shader_parameter("clip_enabled", false)
		return
	var self_rect := Rect2(global_position, size)
	var clip_rect_global := Rect2(clip_by.global_position, clip_by.size)
	var intersection := self_rect.intersection(clip_rect_global)
	var enable := intersection.size.x > 0.0 and intersection.size.y > 0.0
	sm.set_shader_parameter("clip_enabled", enable)
	if not enable:
		return
	var local_pos := intersection.position - self_rect.position
	var normalized_pos := Vector2(
		local_pos.x / size.x if size.x != 0.0 else 0.0,
		local_pos.y / size.y if size.y != 0.0 else 0.0
	)
	var normalized_size := Vector2(
		intersection.size.x / size.x if size.x != 0.0 else 0.0,
		intersection.size.y / size.y if size.y != 0.0 else 0.0
	)
	var clip_vec4 := Vector4(normalized_pos.x, normalized_pos.y, normalized_size.x, normalized_size.y)
	sm.set_shader_parameter("clip_rect", clip_vec4)

