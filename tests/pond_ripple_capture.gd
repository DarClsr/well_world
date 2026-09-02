extends SceneTree


const SHOTS := [
	# [name, portal_time, player_position, yaw_degrees, camera_height, camera_rig_offset]
	["before-wrap", 4.95, Vector3(-9.0, 1.0, 13.5), -35.0, 10.0, Vector3.ZERO],
	["after-wrap", 5.05, Vector3(-9.0, 1.0, 13.5), -35.0, 10.0, Vector3.ZERO],
	["fork-peak", 2.5, Vector3(-3.5, 1.0, 11.0), 0.0, 12.0, Vector3.ZERO],
	["fork-large", 4.0, Vector3(-3.5, 1.0, 11.0), 0.0, 12.0, Vector3.ZERO],
	["close-peak", 2.5, Vector3(-9.0, 1.0, 13.5), -35.0, 10.0, Vector3.ZERO],
	["detail-peak", 2.5, Vector3(-6.2, 1.0, 12.0), 0.0, 7.0, Vector3(-2.4, 0.0, 0.0)],
	["detail-large", 4.0, Vector3(-6.2, 1.0, 12.0), 0.0, 7.0, Vector3(-2.4, 0.0, 0.0)],
]


func _initialize() -> void:
	call_deferred("_record")


func _record() -> void:
	var output_dir := "res://temp/pond-ripple"
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
	await create_timer(1.5).timeout
	main.set_process(false)
	var player := main.get_node("Player") as CharacterBody3D
	player.set_physics_process(false)
	var camera_rig := player.get_node("CameraRig") as Node3D
	for shot in SHOTS:
		player.position = shot[2]
		player.camera_yaw = deg_to_rad(shot[3])
		player.camera_target_height = shot[4]
		camera_rig.position = shot[5]
		camera_rig.rotation.y = deg_to_rad(shot[3])
		player.call("_update_camera_zoom", 1.0)
		main.set("portal_time", shot[1])
		main.call("_process", 0.0)
		await process_frame
		await process_frame
		var image := root.get_texture().get_image()
		image.save_png(ProjectSettings.globalize_path("%s/%s.png" % [output_dir, shot[0]]))
		print("SAVED ", shot[0])
	quit()
