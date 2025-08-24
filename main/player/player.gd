extends CharacterBody3D
class_name Player

## Character maximum run speed on the ground.
@export var move_speed := 8.0
## Forward impulse after a melee attack.
@export var attack_impulse := 10.0
## Movement acceleration (how fast character achieve maximum speed)
@export var acceleration := 6.0
## Jump impulse
@export var jump_initial_impulse := 12.0
## Jump impulse when player keeps pressing jump
@export var jump_additional_force := 4.5
## Player model rotation speed
@export var rotation_speed := 12.0
## Minimum horizontal speed on the ground. This controls when the character's animation tree changes
## between the idle and running states.
@export var stopping_speed := 1.0
## Clamp sync delta for faster interpolation
@export var sync_delta_max := 0.2

@onready var _rotation_root: Node3D = $CharacterRotationRoot
@onready var _camera_controller: CameraController = $CameraController
@onready var _ground_shapecast: ShapeCast3D = $GroundShapeCast
@onready var _character_skin: CharacterSkin = $CharacterRotationRoot/CharacterSkin

@onready var _move_direction := Vector3.ZERO
@onready var _last_strong_direction := Vector3.FORWARD
@onready var _gravity: float = -30.0
@onready var _ground_height: float = 0.0

var _pending_spawn_facing_direction: Vector3 = Vector3.ZERO


func _ready() -> void:
	_camera_controller.setup(self)
	if _pending_spawn_facing_direction != Vector3.ZERO:
		var direction := _pending_spawn_facing_direction
		direction.y = 0.0
		if direction.length() < 0.001:
			direction = Vector3.FORWARD
		_last_strong_direction = direction.normalized()
		_orient_character_to_direction(_last_strong_direction, 0.0, true)
		_camera_controller.set_yaw_from_forward(_last_strong_direction)
	else:
		call_deferred("_align_orientation_to_camera")


func set_pending_spawn_facing_direction(direction: Vector3) -> void:
	_pending_spawn_facing_direction = direction


func _physics_process(delta: float) -> void:
	# Calculate ground height for camera controller
	if _ground_shapecast.get_collision_count() > 0:
		for collision_result in _ground_shapecast.collision_result:
			_ground_height = max(_ground_height, collision_result.point.y)
	else:
		_ground_height = global_position.y + _ground_shapecast.target_position.y
	if global_position.y < _ground_height:
		_ground_height = global_position.y
	
	# Get input and movement state
	var is_just_jumping := Input.is_action_just_pressed("jump") and is_on_floor()
	var is_air_boosting := Input.is_action_pressed("jump") and not is_on_floor() and velocity.y > 0.0
	
	_move_direction = _get_camera_oriented_input()
	
	if EditMode.is_enabled:
		is_just_jumping = false
		is_air_boosting = false
		_move_direction = Vector3.ZERO
	
	# To not orient quickly to the last input, we save a last strong direction,
	# this also ensures a good normalized value for the rotation basis.
	if _move_direction.length() > 0.2:
		_last_strong_direction = _move_direction.normalized()
	
	_orient_character_to_direction(_last_strong_direction, delta)
	
	# We separate out the y velocity to not interpolate on the gravity
	var y_velocity := velocity.y
	velocity.y = 0.0
	velocity = velocity.lerp(_move_direction * move_speed, acceleration * delta)
	if _move_direction.length() == 0 and velocity.length() < stopping_speed:
		velocity = Vector3.ZERO
	velocity.y = y_velocity
	
	# Update position
	
	velocity.y += _gravity * delta
	
	if is_just_jumping:
		velocity.y += jump_initial_impulse
	elif is_air_boosting:
		velocity.y += jump_additional_force * delta
	
	# Set character animation
	if is_just_jumping:
		_character_skin.jump()
	elif not is_on_floor() and velocity.y < 0:
		_character_skin.fall()
	elif is_on_floor():
		var xz_velocity := Vector3(velocity.x, 0, velocity.z)
		if xz_velocity.length() > stopping_speed:
			var speed = inverse_lerp(0.0, move_speed, xz_velocity.length())
			_character_skin.set_moving(true)
			_character_skin.set_moving_speed(speed)
		else:
			_character_skin.set_moving(false)
	
	var position_before := global_position
	move_and_slide()
	var position_after := global_position
	
	# If velocity is not 0 but the difference of positions after move_and_slide is,
	# character might be stuck somewhere!
	var delta_position := position_after - position_before
	var epsilon := 0.001
	if delta_position.length() < epsilon and velocity.length() > epsilon:
		global_position += get_wall_normal() * 0.1


func _get_camera_oriented_input() -> Vector3:
	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	var input := Vector3.ZERO
	# This is to ensure that diagonal input isn't stronger than axis aligned input
	input.x = -raw_input.x * sqrt(1.0 - raw_input.y * raw_input.y / 2.0)
	input.z = -raw_input.y * sqrt(1.0 - raw_input.x * raw_input.x / 2.0)
	
	input = _camera_controller.global_transform.basis * input
	input.y = 0.0
	return input


func _orient_character_to_direction(direction: Vector3, delta: float, force = false) -> void:
	var left_axis := Vector3.UP.cross(direction)
	var rotation_basis := Basis(left_axis, Vector3.UP, direction).get_rotation_quaternion()
	var model_scale := _rotation_root.transform.basis.get_scale()
	_rotation_root.transform.basis = Basis(
		_rotation_root.transform.basis.get_rotation_quaternion().slerp(rotation_basis, delta * rotation_speed)
	).scaled(model_scale)
	if force: _rotation_root.transform.basis = Basis(rotation_basis).scaled(model_scale)


func respawn(spawn_position: Vector3, facing_direction: Vector3 = Vector3.ZERO) -> void:
	global_position = spawn_position
	velocity = Vector3.ZERO
	if facing_direction != Vector3.ZERO:
		facing_direction.y = 0.0
		if facing_direction.length() < 0.001:
			facing_direction = Vector3.FORWARD
		_last_strong_direction = facing_direction.normalized()
		_orient_character_to_direction(_last_strong_direction, 0.0, true)
		_camera_controller.set_yaw_from_forward(_last_strong_direction)
	else:
		call_deferred("_align_orientation_to_camera")


func _align_orientation_to_camera() -> void:
	var direction := _camera_controller.global_transform.basis.z
	direction.y = 0.0
	if direction.length() < 0.001:
		direction = Vector3.FORWARD
	_last_strong_direction = direction.normalized()
	_orient_character_to_direction(_last_strong_direction, 0.0, true)
