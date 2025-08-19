@tool
extends Node3D
class_name StandBase

@export var viewport: SubViewport
@export var mesh: MeshInstance3D
@export var print_log: bool

var mesh_copy: MeshInstance3D


func _enter_tree() -> void:
	render()


func _exit_tree() -> void:
	clear()


func render() -> void:
	if not is_instance_valid(viewport): return
	if viewport == null: return
	
	clear()
	mesh.visible = false
	
	mesh_copy = mesh.duplicate() as MeshInstance3D
	mesh_copy.visible = true
	mesh_copy.material_override = mesh_copy.material_override.duplicate(true)
	(mesh_copy.material_override as StandardMaterial3D).albedo_texture = viewport.get_texture()
	add_child(mesh_copy)
	
	# Force to update
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	
	# Wait viewport to draw
	var scene_tree = get_tree()
	await scene_tree.process_frame
	await scene_tree.process_frame
	if not is_inside_tree(): return # fix editor errors
	
	# Generate mipmaps and replace texture
	var image = viewport.get_texture().get_image()
	image.generate_mipmaps()
	var texture = ImageTexture.create_from_image(image)
	(mesh_copy.material_override as StandardMaterial3D).albedo_texture = texture
	
	try_print(name + " mesh copy displayed")


func clear() -> void:
	mesh.visible = true
	
	if is_instance_valid(mesh_copy):
		remove_child(mesh_copy)
		mesh_copy.queue_free()
		try_print(name + " mesh copy removed")


func try_print(text: Variant) -> void:
	if print_log: print(text)
