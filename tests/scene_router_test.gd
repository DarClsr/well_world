extends SceneTree

const SceneRouterScript = preload("res://scripts/core/scene_router.gd")


func _initialize() -> void:
	var container := Node.new()
	root.add_child(container)
	var router = SceneRouterScript.new()
	root.add_child(router)
	await process_frame
	var game_state = root.get_node("GameState")
	var event_bus = root.get_node("EventBus")
	router.configure(container, game_state, event_bus)
	var first_scene := _make_region("FirstRegion", &"entry", Vector3(3.0, 0.0, 4.0))
	var second_scene := _make_region("SecondRegion", &"return", Vector3(-2.0, 0.0, 1.0))
	router.register_region(&"first", first_scene)
	router.register_region(&"second", second_scene)
	var changes: Array[StringName] = []
	router.region_changed.connect(func(region_id: StringName) -> void: changes.append(region_id))
	assert(router.travel_to(&"unknown", &"entry") == ERR_DOES_NOT_EXIST)
	assert(changes.is_empty())
	assert(router.travel_to(&"first", &"entry") == OK)
	var first = container.get_child(0)
	assert(first.name == "FirstRegion")
	assert((first.get_node("Player") as Node3D).global_position == Vector3(3.0, 0.0, 4.0))
	assert(game_state.active.current_region == &"first")
	assert(game_state.active.spawn_id == &"entry")
	assert(router.travel_to(&"second", &"return") == OK)
	await process_frame
	assert(container.get_child_count() == 1)
	assert(container.get_child(0).name == "SecondRegion")
	assert(changes == [&"first", &"second"])
	print("SCENE ROUTER TEST PASSED")
	quit(0)


func _make_region(region_name: String, spawn_id: StringName, spawn_position: Vector3) -> PackedScene:
	var region := Node3D.new()
	region.name = region_name
	var player := Node3D.new()
	player.name = "Player"
	region.add_child(player)
	player.owner = region
	var marker := Marker3D.new()
	marker.name = "Spawn_%s" % spawn_id
	marker.position = spawn_position
	marker.add_to_group("region_spawn:%s" % spawn_id, true)
	region.add_child(marker)
	marker.owner = region
	var packed := PackedScene.new()
	assert(packed.pack(region) == OK)
	region.free()
	return packed
