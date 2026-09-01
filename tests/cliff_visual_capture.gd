extends SceneTree


func _initialize() -> void:
	call_deferred("_record")


func _record() -> void:
	var scene := load("res://scenes/main.tscn") as PackedScene
	var main := scene.instantiate()
	main.set("time_hour", 9.5)
	main.set("time_running", false)
	main.set("weather_seed", 20260902)
	main.set("weather_running", false)
	main.set("weather_override", "clear")
	root.add_child(main)
	await create_timer(1.1).timeout
	var player := main.get_node("Player") as CharacterBody3D
	var camera_rig := player.get_node("CameraRig") as Node3D
	player.position = Vector3(0.0, 1.0, 0.0)
	player.set_physics_process(false)
	player.set("camera_target_height", 20.0)
	player.call("_update_camera_zoom", 1.0)
	for yaw in [0.0, PI * 0.5, PI, PI * 1.5]:
		camera_rig.rotation.y = yaw
		await create_timer(0.75).timeout
	print("Cliff visual count: ", main.get_node("CliffVisuals").get_child_count())
	quit()
