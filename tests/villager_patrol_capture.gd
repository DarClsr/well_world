extends SceneTree


func _initialize() -> void:
	call_deferred("_record")


func _record() -> void:
	var scene := load("res://scenes/main.tscn") as PackedScene
	var main := scene.instantiate()
	main.set("time_hour", 9.5)
	main.set("time_running", false)
	main.set("weather_seed", 20260902)
	main.set("weather_running", false)
	main.set("weather_override", "clear")
	root.add_child(main)
	await create_timer(1.2).timeout
	var player := main.get_node("Player") as CharacterBody3D
	var toren_capture := "--toren" in OS.get_cmdline_user_args()
	var villager_index := 1 if toren_capture else 0
	var villager_name := "GatekeeperToren" if toren_capture else "HerbalistMira"
	var villager := main.get_node(villager_name) as CharacterBody3D
	player.position = villager.position + Vector3(0.0, 1.0, 4.5)
	player.set("camera_target_height", 10.0)
	player.call("_update_camera_zoom", 1.0)
	if toren_capture:
		villager.position = main.get("villager_patrol_origins")[villager_index]
		main.get("villager_patrol_directions")[villager_index] = 1.0
		main.get("villager_patrol_pauses")[villager_index] = 1.0
		await create_timer(1.05).timeout
	while main.get("villager_patrol_pauses")[villager_index] <= 0.0:
		await process_frame
	var pause_position := villager.position
	await create_timer(0.8).timeout
	print(villager_name, " pause drift: ", villager.position.distance_to(pause_position))
	quit()
