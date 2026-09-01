extends SceneTree


const SHOTS := [
	["day-clear", 9.5, "clear", Vector3(0.0, 1.0, -4.0), 12.0, 0.0, 0.0],
	["day-cloudy", 9.5, "cloudy", Vector3(0.0, 1.0, -4.0), 12.0, 0.0, 0.0],
	["day-mist", 9.5, "mist", Vector3(0.0, 1.0, -4.0), 12.0, 0.0, 0.0],
	["day-rain-a", 9.5, "light_rain", Vector3(0.0, 1.0, -4.0), 12.0, 0.0, 0.0],
	["day-rain-b", 9.5, "light_rain", Vector3(0.0, 1.0, -4.0), 12.0, 1.0, 0.0],
	["day-rain-herb-yard", 9.5, "light_rain", Vector3(-14.8, 1.0, -5.0), 10.0, 0.0, 0.0],
	["night-rain", 22.0, "light_rain", Vector3(0.0, 1.0, -4.0), 12.0, 0.0, 0.0],
]


func _initialize() -> void:
	call_deferred("_record")


func _record() -> void:
	var output_dir := "res://temp/weather"
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
	var camera_rig := player.get_node("CameraRig") as Node3D
	for shot in SHOTS:
		main.set("time_hour", shot[1])
		main.set("weather_override", shot[2])
		player.position = shot[3]
		player.camera_yaw = deg_to_rad(shot[6])
		player.camera_target_height = shot[4]
		camera_rig.rotation.y = deg_to_rad(shot[6])
		player.call("_update_camera_zoom", 1.0)
		main.call("_process", 0.0)
		if (shot[5] as float) > 0.0:
			await create_timer(shot[5]).timeout
		else:
			await create_timer(0.8).timeout
		await process_frame
		await process_frame
		var image := root.get_texture().get_image()
		var path := "%s/%s.png" % [output_dir, shot[0]]
		image.save_png(ProjectSettings.globalize_path(path))
		print("SAVED ", shot[0])
	quit()
