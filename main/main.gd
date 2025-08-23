extends Node

@export var player_spawner: PlayerSpawner
@export var level_root: Node3D
@export var default_scene: PackedScene
@export var second_scene: PackedScene


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

	var level = scene.instantiate()
	level_root.add_child(level)

	player_spawner.create_local_player(level)


func _get_scene_for_url(url: String) -> PackedScene:
	print("get scene for url: ", url)
	var scene: PackedScene = default_scene
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
		scene = second_scene

	return scene
