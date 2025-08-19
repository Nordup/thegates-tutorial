extends Node
class_name PlayerSpawner

@export var player_scene: PackedScene
@export var spawn_path: NodePath
@export var spawn_points: SpawnPoints

var player: Player


func _ready() -> void:
	create_local_player()


func create_local_player() -> void:
	var spawn_position = spawn_points.get_spawn_position()
	player = player_scene.instantiate()
	
	player.name = "LocalPlayer"
	player.call_deferred("set_position", spawn_position)
	
	get_node(spawn_path).add_child(player)


func respawn_local_player() -> void:
	var spawn_position = spawn_points.get_spawn_position()
	player.respawn(spawn_position)
	print("Respawn player at " + str(spawn_position))
