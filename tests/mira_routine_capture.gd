extends SceneTree


func _initialize() -> void:
	call_deferred("_record")


func _record() -> void:
	var output_dir := "res://temp/mira-routine"
	DirAccess.make_dir_recursive_absolute(output_dir)
	var scene := load("res://scenes/main.tscn") as PackedScene
	var main := scene.instantiate()
	main.set("time_hour", 18.8)
	main.set("time_running", false)
	main.set("weather_seed", 20260902)
	main.set("weather_running", false)
	main.set("weather_override", "clear")
	root.add_child(main)
	await create_timer(1.5).timeout
	main.set_physics_process(false)
	var player := main.get_node("Player") as CharacterBody3D
	var mira := main.get_node("HerbalistMira") as CharacterBody3D
	var animation_player := main.get("villager_animations")[0] as AnimationPlayer
	var constants: Dictionary = main.get_script().get_script_constant_map()
	var herb_route: Array = constants["MIRA_HERB_ROUTE"]
	var approach: Vector3 = constants["MIRA_RAIN_SHELTER_APPROACH"]
	var shelter: Vector3 = constants["MIRA_RAIN_SHELTER"]
	player.set_physics_process(false)

	main.set("mira_routine", "homeward")
	main.set("mira_route_index", 1)
	main.set("mira_rain_shelter_leg", 0)
	main.set("mira_rain_shelter_active", true)
	main.get("villager_patrol_pauses")[0] = 0.0
	mira.position = (herb_route[2] as Vector3).lerp(herb_route[1] as Vector3, 0.38)
	mira.visible = true
	mira.collision_layer = 1
	mira.collision_mask = 1
	main.call("_physics_process", 1.0 / 60.0)
	await _capture(main, player, output_dir, "dusk-homeward")

	main.set("time_hour", 23.0)
	main.set("mira_routine", "evening_shelter")
	main.set("mira_rain_shelter_leg", 2)
	mira.position = shelter
	mira.visible = true
	mira.collision_layer = 1
	mira.collision_mask = 1
	main.call("_physics_process", 1.0 / 60.0)
	await _capture(main, player, output_dir, "night-home")

	main.set("time_hour", 6.8)
	main.set("mira_routine", "returning")
	main.set("mira_rain_shelter_leg", 1)
	mira.position = shelter.lerp(approach, 0.42)
	mira.visible = true
	mira.collision_layer = 1
	mira.collision_mask = 1
	main.call("_physics_process", 1.0 / 60.0)
	await _capture(main, player, output_dir, "dawn-return")

	main.set("time_hour", 9.5)
	main.set("mira_routine", "work")
	main.set("mira_route_index", 2)
	main.set("mira_rain_shelter_leg", 0)
	main.set("mira_rain_shelter_active", false)
	main.get("villager_patrol_pauses")[0] = animation_player.get_animation("PickUp").length + 0.1
	mira.position = herb_route[2]
	mira.visible = true
	mira.collision_layer = 1
	mira.collision_mask = 1
	animation_player.play("PickUp")
	await _capture(main, player, output_dir, "morning-work")
	quit()


func _capture(main: Node3D, player: CharacterBody3D, output_dir: String, shot_name: String) -> void:
	player.position = Vector3(-7.0, 1.0, -5.2)
	player.camera_yaw = 0.0
	player.camera_target_height = 10.0
	(player.get_node("CameraRig") as Node3D).rotation.y = player.camera_yaw
	player.call("_update_camera_zoom", 1.0)
	main.call("_process", 1.0)
	await process_frame
	await process_frame
	var mira := main.get_node("HerbalistMira") as CharacterBody3D
	var animation_player := main.get("villager_animations")[0] as AnimationPlayer
	print("MIRA_STATE ", shot_name, " routine=", main.get("mira_routine"), " animation=", animation_player.assigned_animation, " visible=", mira.visible, " position=", mira.position)
	var image := root.get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path("%s/%s.png" % [output_dir, shot_name]))
	print("SAVED ", shot_name)
