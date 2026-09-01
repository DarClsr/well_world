extends SceneTree


const SHOTS := [
	["06-dawn", 6.0, Vector3(0.0, 1.0, -4.0), 0.0, 12.0],
	["095-opening", 9.5, Vector3(0.0, 1.0, -4.0), 0.0, 12.0],
	["12-noon", 12.0, Vector3(0.0, 1.0, -4.0), 0.0, 12.0],
	["182-sunset", 18.2, Vector3(0.0, 1.0, -4.0), 0.0, 12.0],
	["205-night", 20.5, Vector3(0.0, 1.0, -4.0), 0.0, 12.0],
	["00-midnight", 0.0, Vector3(0.0, 1.0, -4.0), 0.0, 12.0],
	["205-night-portal", 20.5, Vector3(10.0, 1.0, 14.0), 0.0, 10.0],
	["205-night-mistcaps", 20.5, Vector3(-9.0, 1.0, 13.5), -35.0, 10.0],
]


func _initialize() -> void:
	call_deferred("_record")


func _record() -> void:
	var output_dir := "res://temp/time-sweep"
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
	for shot in SHOTS:
		main.set("time_hour", shot[1])
		player.position = shot[2]
		player.camera_yaw = deg_to_rad(shot[3])
		player.camera_target_height = shot[4]
		main.call("_process", 0.0)
		await create_timer(0.8).timeout
		await process_frame
		await process_frame
		var image := root.get_texture().get_image()
		var path := "%s/%s.png" % [output_dir, shot[0]]
		image.save_png(ProjectSettings.globalize_path(path))
		print("SAVED ", shot[0])
	quit()
