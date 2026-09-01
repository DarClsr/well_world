extends SceneTree


func _initialize() -> void:
	call_deferred("_record")


func _record() -> void:
	var output_dir := "res://temp/grass-motion"
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
	var player := main.get_node("Player") as CharacterBody3D
	player.position = Vector3(1.5, 1.0, 4.0)
	player.camera_yaw = 0.0
	player.camera_target_height = 10.0
	await create_timer(1.5).timeout
	await _save_frame(output_dir, "near-a")
	await create_timer(1.1).timeout
	await _save_frame(output_dir, "near-b")
	player.camera_target_height = 20.0
	await create_timer(2.5).timeout
	await _save_frame(output_dir, "far-a")
	await create_timer(1.1).timeout
	await _save_frame(output_dir, "far-b")
	quit()


func _save_frame(output_dir: String, frame_name: String) -> void:
	await process_frame
	await process_frame
	var image := root.get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path("%s/%s.png" % [output_dir, frame_name]))
	print("SAVED ", frame_name)
