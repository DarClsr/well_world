extends SceneTree


const SHOTS := [
	["hearth-activity-intact", Vector3(4.2, 1.0, -5.8), 15.0, 10.0],
	["hearth-cutaway", Vector3(9.0, 1.0, -4.0), 180.0, 10.0],
	["herb-front-intact", Vector3(-9.0, 1.0, -6.0), 0.0, 10.0],
	["herb-cutaway", Vector3(-9.0, 1.0, -6.0), 180.0, 10.0],
	["west-front-intact", Vector3(-10.0, 1.0, 9.0), 0.0, 10.0],
	["west-cutaway", Vector3(-10.0, 1.0, 9.0), 180.0, 10.0],
	["village-restored", Vector3(0.0, 1.0, -4.0), 0.0, 20.0],
]


func _initialize() -> void:
	call_deferred("_record")


func _record() -> void:
	var output_dir := "res://temp/roof-fade"
	DirAccess.make_dir_recursive_absolute(output_dir)
	var scene := load("res://scenes/main.tscn") as PackedScene
	var main := scene.instantiate()
	main.set("time_hour", 9.5)
	main.set("time_running", false)
	main.set("weather_seed", 20260902)
	main.set("weather_running", false)
	main.set("weather_override", "clear")
	root.add_child(main)
	(main.get_node("Opening") as CanvasLayer).visible = false
	await create_timer(1.6).timeout
	var player := main.get_node("Player") as CharacterBody3D
	player.set_physics_process(false)
	var camera_rig := player.get_node("CameraRig") as Node3D
	for shot in SHOTS:
		player.position = shot[1]
		player.camera_yaw = deg_to_rad(shot[2])
		player.camera_target_height = shot[3]
		camera_rig.rotation.y = deg_to_rad(shot[2])
		player.call("_update_camera_zoom", 1.0)
		await create_timer(1.2).timeout
		await process_frame
		await process_frame
		var image := root.get_texture().get_image()
		image.save_png(ProjectSettings.globalize_path("%s/%s.png" % [output_dir, shot[0]]))
		print("SAVED ", shot[0])
	quit()
