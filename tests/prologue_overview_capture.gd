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
	await create_timer(1.2).timeout
	var player := main.get_node("Player") as CharacterBody3D
	if "--wagon" in OS.get_cmdline_user_args():
		player.position = Vector3(-9.5, 1.0, -0.5)
		player.set("camera_target_height", 10.0)
		player.call("_update_camera_zoom", 1.0)
		await physics_frame
		player.set_physics_process(false)
		(player.get_node("CameraRig") as Node3D).position = Vector3(5.5, 0.0, -2.2)
		await create_timer(2.0).timeout
		quit()
		return
	if "--phase45-characters" in OS.get_cmdline_user_args():
		player.set("camera_target_height", 12.0)
		player.call("_update_camera_zoom", 1.0)
		for position in [
			Vector3(0.3, 1.0, 7.0),
			Vector3(-9.0, 1.0, -6.0),
			Vector3(0.5, 1.0, -14.0),
			Vector3(-0.2, 1.0, 2.0),
		]:
			player.position = position
			await create_timer(1.0).timeout
		quit()
		return
	if "--phase42-route" in OS.get_cmdline_user_args():
		player.set("camera_target_height", 12.0)
		player.call("_update_camera_zoom", 1.0)
		for position in [
			Vector3(0.2, 1.0, 11.5),
			Vector3(0.3, 1.0, 7.0),
			Vector3(-0.2, 1.0, 2.0),
		]:
			player.position = position
			await create_timer(1.0).timeout
		quit()
		return
	if "--phase43-pond" in OS.get_cmdline_user_args():
		player.set("camera_target_height", 10.0)
		player.call("_update_camera_zoom", 1.0)
		for position in [
			Vector3(-2.6, 1.0, 12.2),
			Vector3(-4.0, 1.0, 12.6),
			Vector3(-5.1, 1.0, 14.8),
		]:
			player.position = position
			await create_timer(1.0).timeout
		quit()
		return
	player.set("camera_target_height", 12.0)
	player.call("_update_camera_zoom", 1.0)
	for position in [
		Vector3(10.0, 1.0, 14.0),
		Vector3(-2.0, 1.0, 11.5),
		Vector3(-12.2, 1.0, -7.0),
		Vector3(3.0, 1.0, -4.0),
		Vector3(-6.7, 1.0, 5.0),
		Vector3(0.0, 1.0, -22.0),
	]:
		player.position = position
		await create_timer(1.0).timeout
	quit()
