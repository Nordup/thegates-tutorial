extends Node3D
class_name HintVisibility

@export var events: HintEvents
@export var hint_show_id: StringName
@export var hint_hide_id: StringName

@export var hide_tween_time: float = 0.35


@onready var marker: Node3D = $marker
@onready var gem_mesh: MeshInstance3D = $"marker/Marker"
@onready var omni_light: OmniLight3D = $"marker/OmniLight3D"

var hideTween: Tween
var originalScale: Vector3
var originalAlpha: float
var originalEmission: float
var originalLightEnergy: float

func _ready() -> void:
	visible = false
	events.show_hint.connect(on_show_hint)

	originalScale = marker.scale

	if gem_mesh.material_override is StandardMaterial3D:
		var mat := gem_mesh.material_override as StandardMaterial3D
		if not mat.resource_local_to_scene:
			mat = mat.duplicate() as StandardMaterial3D
			mat.resource_local_to_scene = true
			gem_mesh.material_override = mat
		originalAlpha = mat.albedo_color.a
	originalEmission = (gem_mesh.material_override as StandardMaterial3D).emission_energy_multiplier
	originalLightEnergy = omni_light.light_energy

	on_show_hint(events.current_hint_id)


func on_show_hint(id: StringName) -> void:
	if id == hint_show_id:
		if hideTween and hideTween.is_running():
			hideTween.kill()
		marker.scale = originalScale
		if gem_mesh.material_override is StandardMaterial3D:
			var mat := gem_mesh.material_override as StandardMaterial3D
			var c := mat.albedo_color
			c.a = originalAlpha
			mat.albedo_color = c
			mat.emission_energy_multiplier = originalEmission
		omni_light.light_energy = originalLightEnergy
		visible = true

	if id == hint_hide_id:
		animate_hide()


func animate_hide() -> void:
	if hideTween and hideTween.is_running():
		hideTween.kill()

	hideTween = create_tween()
	hideTween.set_parallel(true)

	# Scale down
	hideTween.tween_property(marker, "scale", originalScale * 0.6, hide_tween_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Fade material alpha and emission
	if gem_mesh.material_override is StandardMaterial3D:
		var _mat := gem_mesh.material_override as StandardMaterial3D
		hideTween.tween_property(gem_mesh, "material_override:albedo_color:a", 0.0, hide_tween_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		hideTween.tween_property(gem_mesh, "material_override:emission_energy_multiplier", 0.0, hide_tween_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Dim light
	hideTween.tween_property(omni_light, "light_energy", 0.0, hide_tween_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Then hide and restore values for the next show
	hideTween.set_parallel(false)
	hideTween.tween_callback(func():
		visible = false
		marker.scale = originalScale
		if gem_mesh.material_override is StandardMaterial3D:
			var m := gem_mesh.material_override as StandardMaterial3D
			var col := m.albedo_color
			col.a = originalAlpha
			m.albedo_color = col
			m.emission_energy_multiplier = originalEmission
		omni_light.light_energy = originalLightEnergy
	)
