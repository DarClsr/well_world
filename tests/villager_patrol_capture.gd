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
	player.position = Vector3(3.5, 1.0, -10.5) if toren_capture else villager.position + Vector3(0.0, 1.0, 4.5)
	player.velocity = Vector3.ZERO
	player.set_process(false)
	player.set_physics_process(false)
	player.set("camera_target_height", 11.0 if toren_capture else 10.0)
	player.call("_update_camera_zoom", 1.0)
	if toren_capture:
		var constants := (main.get_script() as Script).get_script_constant_map()
		var route: Array = constants["TOREN_WATCH_ROUTE"]
		villager.position = route[0]
		main.set("toren_watch_index", 0)
		main.get("villager_patrol_pauses")[villager_index] = 0.8
		var transitions := 0
		var last_index := 0
		var physics_steps := 0
		while transitions < route.size() and physics_steps < 2700:
			await physics_frame
			physics_steps += 1
			var watch_index: int = main.get("toren_watch_index")
			if watch_index != last_index:
				transitions += 1
				last_index = watch_index
		if transitions != route.size():
			push_error("Toren watch route timed out after %d transitions" % transitions)
			quit(1)
			return
		await create_timer(1.0).timeout
		print("TOREN WATCH TEST PASSED transitions=", transitions)
		quit()
		return
	while main.get("villager_patrol_pauses")[villager_index] <= 0.0:
		await process_frame
	var pause_position := villager.position
	await create_timer(0.8).timeout
	print(villager_name, " pause drift: ", villager.position.distance_to(pause_position))
	quit()
