extends SceneTree


func _initialize() -> void:
	call_deferred("_record")


func _record() -> void:
	var output_dir := "res://temp/herb-gather"
	DirAccess.make_dir_recursive_absolute(output_dir)
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
	player.set_physics_process(false)
	main.set_physics_process(false)
	var herb := main.get_node("HerbPlot/GatherableMistleaf") as Node3D
	var herb_target := herb.get_node("InteractionTarget") as InteractionTarget
	root.get_node("GameState").active.flags[&"mira_met"] = true
	player.global_position = herb_target.global_position + Vector3(1.2, 1.0, 0.0)
	player.camera_yaw = 0.0
	player.set("camera_target_height", 10.0)
	player.call("_update_camera_zoom", 1.0)
	main.call("_process", 0.0)
	await _capture(output_dir, "before")
	assert(main.call("_gather_herb", player))
	var player_animation := player.get("character_animation") as AnimationPlayer
	var pickup_length := player_animation.get_animation("PickUp").length
	player.call("_update_walk_visual", pickup_length * 0.45, 0.0)
	player_animation.seek(pickup_length * 0.45, true)
	await _capture(output_dir, "during")
	player.call("_update_walk_visual", pickup_length, 0.0)
	await create_timer(0.25).timeout
	await _capture(output_dir, "after")
	print("HERB GATHER CAPTURE PASSED collected=", &"mira_mistleaf" in root.get_node("GameState").active.collected_ids)
	quit()


func _capture(output_dir: String, shot_name: String) -> void:
	await process_frame
	await process_frame
	var image := root.get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path("%s/%s.png" % [output_dir, shot_name]))
	print("SAVED ", shot_name)
