extends SceneTree


const SHOTS := [
	["day-west-a", 12.0, Vector3(-4.2, 1.0, -14.2), 10.0, 0.0],
	["day-west-b", 12.0, Vector3(-4.2, 1.0, -14.2), 10.0, 1.0],
	["day-east", 12.0, Vector3(4.8, 1.0, -12.8), 10.0, 0.0],
	["night-west-a", 22.0, Vector3(-14.0, 1.0, -2.0), 10.0, 0.0],
	["night-west-b", 22.0, Vector3(-14.0, 1.0, -2.0), 10.0, 1.0],
	["night-east", 22.0, Vector3(14.0, 1.0, 2.5), 10.0, 0.0],
]


func _initialize() -> void:
	call_deferred("_record")


func _record() -> void:
	var output_dir := "res://temp/ecosystem"
	DirAccess.make_dir_recursive_absolute(output_dir)
	var scene := load("res://scenes/main.tscn") as PackedScene
	var main := scene.instantiate()
	main.set("time_hour", 12.0)
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
		player.position = shot[2]
		player.camera_yaw = PI if (shot[0] as String).begins_with("night") else 0.0
		player.camera_target_height = shot[3]
		camera_rig.rotation.y = player.camera_yaw
		player.call("_update_camera_zoom", 1.0)
		main.call("_process", 0.0)
		if (shot[4] as float) > 0.0:
			await create_timer(shot[4]).timeout
		else:
			await create_timer(0.8).timeout
		await process_frame
		await process_frame
		var image := root.get_texture().get_image()
		var path := "%s/%s.png" % [output_dir, shot[0]]
		image.save_png(ProjectSettings.globalize_path(path))
		print("SAVED ", shot[0])
	quit()
