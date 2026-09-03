extends SceneTree


func _initialize() -> void:
	call_deferred("_record")


func _record() -> void:
	var output_dir := "res://temp/mira-shelter"
	DirAccess.make_dir_recursive_absolute(output_dir)
	var scene := load("res://scenes/main.tscn") as PackedScene
	var main := scene.instantiate()
	main.set("time_hour", 9.5)
	main.set("time_running", false)
	main.set("weather_seed", 20260902)
	main.set("weather_running", false)
	main.set("weather_override", "light_rain")
	root.add_child(main)
	await create_timer(1.2).timeout
	var player := main.get_node("Player") as CharacterBody3D
	var mira := main.get_node("HerbalistMira") as CharacterBody3D
	var route: Array = (main.get_script() as Script).get_script_constant_map()["MIRA_HERB_ROUTE"]
	player.set_physics_process(false)
	player.position = Vector3(-3.7, 1.0, -5.2)
	player.set("camera_target_height", 10.0)
	player.call("_update_camera_zoom", 1.0)
	mira.position = route[0]
	main.set("mira_route_index", 0)
	main.set("mira_rain_shelter_active", false)
	main.get("villager_patrol_pauses")[0] = 0.0
	main.call("_process", 0.0)
	await create_timer(10.0).timeout
	main.call("_process", 0.0)
	await process_frame
	await process_frame
	var target: Vector3 = main.get_script().get_script_constant_map()["MIRA_RAIN_SHELTER"]
	print("MIRA_SHELTER_CAPTURE position=", mira.position, " distance=", mira.position.distance_to(target), " leg=", main.get("mira_rain_shelter_leg"), " active=", main.get("mira_rain_shelter_active"), " animation=", (main.get("villager_animations")[0] as AnimationPlayer).assigned_animation)
	var image := root.get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path("%s/mira-under-canopy.png" % output_dir))
	quit()
