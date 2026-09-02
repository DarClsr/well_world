extends SceneTree


const SHOTS := [
	["day-clear-a", 9.5, "clear", 0.0],
	["day-clear-b", 9.5, "clear", 1.0],
	["sunset-clear", 18.2, "clear", 0.0],
	["night-rain", 22.0, "light_rain", 0.0],
]


func _initialize() -> void:
	call_deferred("_record")


func _record() -> void:
	var output_dir := "res://temp/seasonal-foliage"
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
	player.set_physics_process(false)
	player.position = Vector3(0.0, 1.0, -4.0)
	player.camera_yaw = 0.0
	player.camera_target_height = 12.0
	(player.get_node("CameraRig") as Node3D).rotation.y = 0.0
	player.call("_update_camera_zoom", 1.0)
	for shot in SHOTS:
		main.set("time_hour", shot[1])
		main.set("weather_override", shot[2])
		main.call("_process", 0.0)
		if (shot[3] as float) > 0.0:
			await create_timer(shot[3]).timeout
		else:
			await create_timer(0.8).timeout
		await process_frame
		await process_frame
		var image := root.get_texture().get_image()
		image.save_png(ProjectSettings.globalize_path("%s/%s.png" % [output_dir, shot[0]]))
		print("SAVED ", shot[0])
	quit()
