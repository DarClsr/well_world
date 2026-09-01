extends SceneTree


const SHOTS := [
	["day-clear-cutaway", 9.5, "clear"],
	["day-rain-cutaway", 9.5, "light_rain"],
	["night-rain-cutaway", 22.0, "light_rain"],
]


func _initialize() -> void:
	call_deferred("_record")


func _record() -> void:
	var output_dir := "res://temp/house-weather"
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
	player.position = Vector3(-9.0, 1.0, -6.5)
	player.camera_yaw = 0.0
	player.camera_target_height = 9.0
	var camera_rig := player.get_node("CameraRig") as Node3D
	camera_rig.rotation.y = 0.0
	player.call("_update_camera_zoom", 1.0)
	for shot in SHOTS:
		main.set("time_hour", shot[1])
		main.set("weather_override", shot[2])
		main.call("_process", 1.0)
		await create_timer(0.8).timeout
		await process_frame
		await process_frame
		var hidden := 0
		var partial := 0
		var visible := 0
		for streak in main.get("rain_streaks"):
			var alpha := (streak as MeshInstance3D).transparency
			if alpha > 0.99:
				hidden += 1
			elif alpha > 0.01:
				partial += 1
			else:
				visible += 1
		print("RAIN_MASK ", shot[0], " hidden=", hidden, " partial=", partial, " visible=", visible)
		var image := root.get_texture().get_image()
		var path := "%s/%s.png" % [output_dir, shot[0]]
		image.save_png(ProjectSettings.globalize_path(path))
		print("SAVED ", shot[0])
	quit()
