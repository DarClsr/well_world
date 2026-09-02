extends SceneTree


const FRAME_RATE := 60.0
const DURATION_SECONDS := 8.0


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
	(main.get_node("Opening") as CanvasLayer).visible = false
	var player := main.get_node("Player") as CharacterBody3D
	var camera_rig := player.get_node("CameraRig") as Node3D
	player.set_physics_process(false)
	player.camera_yaw = PI
	player.camera_target_height = 10.0
	camera_rig.rotation.y = PI
	player.call("_update_camera_zoom", 1.0)
	player.position = Vector3(-9.0, 1.0, -3.5)
	player.call("_update_camera_lead", 1.0, Vector3.ZERO)
	await create_timer(0.5).timeout

	var previous_position := player.position
	var previous_faded: bool = (main.get("house_roofs_faded") as Array)[0]
	var transitions := 0
	var total_frames := int(DURATION_SECONDS * FRAME_RATE)
	for frame_index in total_frames:
		var time := float(frame_index) / FRAME_RATE
		var next_position := _position_at(time)
		var real_velocity := (next_position - previous_position) * FRAME_RATE
		player.position = next_position
		player.call("_update_camera_lead", 1.0 / FRAME_RATE, real_velocity)
		player.call("_update_walk_visual", 1.0 / FRAME_RATE, minf(real_velocity.length() / 7.0, 1.0))
		previous_position = next_position
		await process_frame
		var is_faded: bool = (main.get("house_roofs_faded") as Array)[0]
		if is_faded != previous_faded:
			transitions += 1
			previous_faded = is_faded

	assert(transitions == 2, "Roof motion path must enter and exit exactly once, got %d transitions" % transitions)
	print("ROOF MOTION TEST PASSED transitions=", transitions)
	quit()


func _position_at(time: float) -> Vector3:
	var z := -3.5
	if time < 1.0:
		z = -3.5
	elif time < 2.0:
		z = lerpf(-3.5, -4.05, smoothstep(0.0, 1.0, time - 1.0))
	elif time < 3.5:
		z = -4.05 - pow(sin((time - 2.0) * PI / 1.5), 2.0) * 0.12
	elif time < 4.2:
		z = lerpf(-4.05, -4.35, smoothstep(0.0, 1.0, (time - 3.5) / 0.7))
	elif time < 6.2:
		z = -4.35 + pow(sin((time - 4.2) * PI / 2.0), 2.0) * 0.40
	elif time < 7.2:
		z = lerpf(-4.35, -3.5, smoothstep(0.0, 1.0, time - 6.2))
	return Vector3(-9.0, 1.0, z)
