extends Node

@export var player_spawner: PlayerSpawner
@export var level_root: Node3D
@export var tutorial_ui_manager: TutorialUIManager

@export var world_1_step_1: PackedScene
@export var world_1_step_4: PackedScene
@export var world_2_step_2: PackedScene
@export var world_2_step_3: PackedScene


func _ready() -> void:
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	print(args)
	var url := ""
	for i in range(args.size()):
		if args[i] == "--url" and i + 1 < args.size():
			url = args[i + 1]
			break
	
	var scene := _get_scene_for_url(url)
	print("scene: ", scene.get_path())

	var level = scene.instantiate()
	level_root.add_child(level)

	player_spawner.create_local_player(level)


func _get_scene_for_url(url: String) -> PackedScene:
	print("get scene for url: ", url)
	var scene: PackedScene = get_world_1()
	if url == "":
		return scene
	
	var query := ""
	var qmark := url.find("?")
	if qmark != -1:
		var end := url.find("#", qmark + 1)
		if end == -1:
			query = url.substr(qmark + 1)
		else:
			query = url.substr(qmark + 1, end - (qmark + 1))

	print("query: ", query)

	if query == "":
		return scene

	var params := {}
	for pair in query.split("&", false):
		if pair == "":
			continue
		var kv := pair.split("=", false, 1)
		var key := kv[0].uri_decode()
		var value := kv[1].uri_decode() if kv.size() > 1 else ""
		params[key] = value

	print("params: ", params)

	if params.has("world") and str(params["world"]) == "2":
		scene = get_world_2()

	return scene


func get_world_1() -> PackedScene:
	if ProgressSaver.is_step_completed(3):
		tutorial_ui_manager.show_step_scene(4)
		return world_1_step_4
	
	tutorial_ui_manager.show_step_scene(1)
	return world_1_step_1


func get_world_2() -> PackedScene:
	if ProgressSaver.is_step_completed(2):
		tutorial_ui_manager.show_step_scene(3)
		return world_2_step_3
	
	tutorial_ui_manager.show_step_scene(2)
	return world_2_step_2
