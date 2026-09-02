extends SceneTree


const TREE_POSITION := Vector3(-21.0, 0.0, -24.8)
const PLAYER_POSITION := Vector3(-17.0, 1.0, -17.0)
const SHOTS := [
	["yaw-000", 0.0],
	["yaw-090", 90.0],
	["yaw-180", 180.0],
	["yaw-270", 270.0],
]


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var output_dir := "res://temp/tree-occlusion"
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
	var player := main.get_node("Player") as CharacterBody3D
	var camera_rig := player.get_node("CameraRig") as Node3D
	player.set_physics_process(false)
	assert(Vector2(PLAYER_POSITION.x, PLAYER_POSITION.z).distance_to(Vector2(TREE_POSITION.x, TREE_POSITION.z)) > 2.33)
	for shot in SHOTS:
		player.position = PLAYER_POSITION
		player.camera_yaw = deg_to_rad(shot[1])
		player.camera_target_height = 10.0
		camera_rig.rotation.y = player.camera_yaw
		player.call("_update_camera_zoom", 1.0)
		await create_timer(0.8).timeout
		await process_frame
		await process_frame
		if DisplayServer.get_name() != "headless":
			var image := root.get_texture().get_image()
			image.save_png(ProjectSettings.globalize_path("%s/%s.png" % [output_dir, shot[0]]))
			print("SAVED ", shot[0])
	print("TREE OCCLUSION CAPTURE PASSED shots=", SHOTS.size())
	quit()
