extends SceneTree


func _initialize() -> void:
	var scene := load("res://scenes/main.tscn") as PackedScene
	assert(scene != null)
	var main := scene.instantiate()
	main.set("time_running", false)
	main.set("weather_running", false)
	main.set("weather_override", "clear")
	root.add_child(main)
	await process_frame
	await process_frame
	assert(main.get_node_or_null("Player") is CharacterBody3D)
	assert(main.get_node_or_null("Player/CameraRig/Camera3D") is Camera3D)
	assert(main.get_node_or_null("WorldEnvironment") is WorldEnvironment)
	assert(main.get_node_or_null("Sun") is DirectionalLight3D)
	assert(main.get_node_or_null("PortalRuin") is Node3D)
	assert(main.get_node_or_null("VillageHearth") is Node3D)
	assert(main.get_node_or_null("MistPass") is Node3D)
	assert(main.get_node_or_null("HerbalistMira") is CharacterBody3D)
	assert(main.get_node_or_null("GatekeeperToren") is CharacterBody3D)
	assert(main.get_node_or_null("WeaverNia") is CharacterBody3D)
	assert(main.get("rain_field") is Node3D)
	assert(main.get("meadow_grass") is MultiMeshInstance3D)
	assert((main.get("tree_canopies") as Array).size() == 16)
	var falling_leaves := main.get("falling_leaves") as Node3D
	assert(falling_leaves != null and falling_leaves.get_child_count() == 12)
	root.remove_child(main)
	main.free()
	print("FOG VALLEY BASELINE PASSED")
	quit(0)
