extends SceneTree


func _initialize() -> void:
	call_deferred("_record")


func _record() -> void:
	var scene := load("res://scenes/main.tscn") as PackedScene
	var main := scene.instantiate()
	root.add_child(main)
	await create_timer(1.2).timeout
	var player := main.get_node("Player") as CharacterBody3D
	var camera_rig := player.get_node("CameraRig") as Node3D
	player.set("camera_target_height", 12.0)
	player.call("_update_camera_zoom", 1.0)

	Input.action_press("move_forward")
	await create_timer(1.0).timeout
	Input.action_release("move_forward")
	print("Forward camera lead: ", camera_rig.position)
	await create_timer(0.9).timeout
	print("Stopped camera lead: ", camera_rig.position)

	Input.action_press("move_right")
	await create_timer(1.0).timeout
	Input.action_release("move_right")
	print("Right camera lead: ", camera_rig.position)
	await create_timer(0.9).timeout
	print("Final camera lead: ", camera_rig.position)
	quit()
