extends SceneTree


func _initialize() -> void:
	call_deferred("_record")


func _record() -> void:
	var output_dir := "res://temp/nia-routine"
	DirAccess.make_dir_recursive_absolute(output_dir)
	var scene := load("res://scenes/main.tscn") as PackedScene
	var main := scene.instantiate()
	main.set("time_hour", 9.5)
	main.set("time_running", false)
	main.set("weather_seed", 20260902)
	main.set("weather_running", false)
	main.set("weather_override", "clear")
	root.add_child(main)
	await create_timer(1.5).timeout
	main.set_physics_process(false)
	var player := main.get_node("Player") as CharacterBody3D
	player.set_physics_process(false)
	var nia := main.get_node("WeaverNia") as CharacterBody3D
	var nia_animation := main.get("villager_animations")[2] as AnimationPlayer
	var main_constants: Dictionary = main.get_script().get_script_constant_map()
	var nia_work_route: Array = main_constants["NIA_WORK_ROUTE"]
	main.set("time_hour", 9.0)
	main.set("nia_routine", "work")
	main.set("nia_work_index", 1)
	main.set("nia_work_action_done", false)
	nia.position = nia_work_route[2]
	nia.velocity = Vector3.ZERO
	main.get("villager_patrol_pauses")[2] = 0.0
	main.call("_physics_process", 1.0 / 60.0)
	main.set_physics_process(false)
	await _capture(main, player, output_dir, "day-work", Vector3(-3.0, 1.0, 2.5))

	var nia_pond_route: Array = main_constants["NIA_POND_ROUTE"]
	main.set("time_hour", 14.5)
	main.set("weather_override", "clear")
	main.call("_process", 0.0)
	main.set("nia_routine", "work")
	main.set("nia_route_index", 0)
	main.set("nia_errand_action_done", false)
	nia.position = nia_pond_route[0]
	nia.velocity = Vector3.ZERO
	main.get("villager_patrol_pauses")[2] = 0.0
	main.set_physics_process(true)
	await create_timer(3.0).timeout
	main.set_physics_process(false)
	await _capture(main, player, output_dir, "day-pond-walk", Vector3(-2.5, 1.0, 8.0), -20.0)
	nia.position = nia_pond_route[-1]
	nia.velocity = Vector3.ZERO
	main.set("nia_routine", "pond")
	main.set("nia_route_index", nia_pond_route.size() - 1)
	main.set("nia_errand_action_done", false)
	main.get("villager_patrol_pauses")[2] = 0.0
	main.call("_physics_process", 1.0 / 60.0)
	await _capture(main, player, output_dir, "day-pond-wash", Vector3(-2.5, 1.0, 8.0), -30.0)
	main.set("time_hour", 15.5)
	main.set_physics_process(true)
	await create_timer(1.2).timeout
	main.set_physics_process(false)
	await _capture(main, player, output_dir, "day-pond-return", Vector3(-2.5, 1.0, 8.0), -20.0)
	if "--pond-only" in OS.get_cmdline_user_args():
		quit()
		return

	var nia_day_rain_route: Array = main_constants["NIA_DAY_RAIN_ROUTE"]
	main.set("time_hour", 9.5)
	main.set("weather_override", "light_rain")
	main.call("_process", 0.0)
	main.set("nia_routine", "work")
	nia.position = nia_work_route[2]
	nia.velocity = Vector3.ZERO
	main.get("villager_patrol_pauses")[2] = 0.0
	main.set_physics_process(true)
	await create_timer(0.55).timeout
	main.set_physics_process(false)
	await _capture(main, player, output_dir, "day-rain-depart", Vector3(-3.0, 1.0, 2.5))
	nia.position = nia_day_rain_route[-1]
	main.set("nia_routine", "day_rain_shelter")
	main.set("nia_route_index", nia_day_rain_route.size() - 1)
	main.call("_physics_process", 1.0 / 60.0)
	await _capture(main, player, output_dir, "day-rain-shelter", Vector3(-3.0, 1.0, 5.0), 90.0)

	main.set("weather_override", "clear")
	main.call("_process", 0.0)
	nia.position = nia_day_rain_route[-1]
	main.set("nia_routine", "day_rain_shelter")
	main.set("nia_route_index", nia_day_rain_route.size() - 1)
	main.set_physics_process(true)
	await create_timer(0.55).timeout
	main.set_physics_process(false)
	await _capture(main, player, output_dir, "day-rain-return", Vector3(-3.0, 1.0, 2.5))

	main.set("time_hour", 11.0)
	main.set("nia_routine", "home")
	main.call("_update_nia_routine", nia, nia_animation)
	await _capture(main, player, output_dir, "day-errand", Vector3(-4.5, 1.0, 4.5))

	main.set("time_hour", 12.0)
	main.set("nia_routine", "errand")
	nia.position = Vector3(-7.25, 0.0, -0.75)
	main.set("nia_route_index", 8)
	main.set("nia_errand_action_done", false)
	main.get("villager_patrol_pauses")[2] = 0.0
	main.call("_physics_process", 1.0 / 60.0)
	main.set_physics_process(false)
	await _capture(main, player, output_dir, "day-unload", Vector3(-5.0, 1.0, -0.75), 90.0)

	main.set("time_hour", 12.3)
	main.set("nia_routine", "errand")
	nia.position = Vector3(-7.25, 0.0, -0.75)
	main.set("nia_route_index", 8)
	main.get("villager_patrol_pauses")[2] = 0.0
	main.set_physics_process(true)
	await create_timer(2.0).timeout
	await _capture(main, player, output_dir, "day-return", Vector3(-3.5, 1.0, 3.5))
	main.set_physics_process(false)

	main.set("time_hour", 18.8)
	main.set("nia_routine", "work")
	nia.position = main.get("villager_patrol_origins")[2]
	main.set_physics_process(true)
	await create_timer(7.0).timeout
	await _capture(main, player, output_dir, "dusk-walk", Vector3(-1.0, 1.0, 6.0))
	await create_timer(18.0).timeout
	main.set("time_hour", 20.5)
	await _capture(main, player, output_dir, "night-hearth", Vector3(2.5, 1.0, -0.8))

	main.set("weather_override", "light_rain")
	main.call("_process", 0.0)
	await create_timer(5.0).timeout
	await _capture(main, player, output_dir, "rain-shelter", Vector3(4.2, 1.0, -0.8))
	quit()


func _capture(main: Node3D, player: CharacterBody3D, output_dir: String, shot_name: String, player_position: Vector3, yaw_degrees: float = 0.0) -> void:
	player.position = player_position
	player.camera_yaw = deg_to_rad(yaw_degrees)
	player.camera_target_height = 10.0
	(player.get_node("CameraRig") as Node3D).rotation.y = player.camera_yaw
	player.call("_update_camera_zoom", 1.0)
	main.call("_process", 1.0)
	await create_timer(0.8).timeout
	await process_frame
	await process_frame
	var nia := main.get_node("WeaverNia") as CharacterBody3D
	var nia_animation := main.get("villager_animations")[2] as AnimationPlayer
	print("NIA_STATE ", shot_name, " routine=", main.get("nia_routine"), " animation=", nia_animation.assigned_animation, " position=", nia.position)
	RenderingServer.force_draw(false)
	var image := root.get_texture().get_image()
	var path := "%s/%s.png" % [output_dir, shot_name]
	image.save_png(ProjectSettings.globalize_path(path))
	print("SAVED ", shot_name)
	player.position = Vector3(0.0, 1.0, 30.0)
	main.call("_process", 0.0)
