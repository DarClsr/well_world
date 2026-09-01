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
	var mira := main.get_node("HerbalistMira") as CharacterBody3D
	var animation_player := main.get("villager_animations")[0] as AnimationPlayer
	player.position = Vector3(-3.7, 1.0, -5.2)
	player.set("camera_target_height", 10.0)
	player.call("_update_camera_zoom", 1.0)
	main.call("_process", 1.0)

	mira.position = (main.get("villager_patrol_origins")[0] as Vector3) + (main.get("villager_patrol_axes")[0] as Vector3) * 1.21
	main.get("villager_patrol_directions")[0] = 1.0
	main.get("villager_patrol_pauses")[0] = 0.0
	await physics_frame
	var pickup_length := animation_player.get_animation("PickUp").length
	var gather_position := mira.position
	print("PickUp length: ", pickup_length)
	await create_timer(pickup_length * 0.55).timeout
	var herb_plot := main.get_node("HerbPlot") as Node3D
	var plot_direction := herb_plot.global_position - mira.global_position
	print("Gather animation: ", animation_player.assigned_animation)
	print("Gather drift: ", mira.position.distance_to(gather_position))
	print("Gather facing error: ", absf(angle_difference((mira.get_node("Visual") as Node3D).rotation.y, atan2(plot_direction.x, plot_direction.z))))
	await create_timer(pickup_length * 0.55 + 0.4).timeout
	print("Resume animation: ", animation_player.assigned_animation)
	quit()
