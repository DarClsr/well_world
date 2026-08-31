extends SceneTree


func _initialize() -> void:
	call_deferred("_record")


func _record() -> void:
	var scene := load("res://scenes/main.tscn") as PackedScene
	var main := scene.instantiate()
	root.add_child(main)
	if "--isolated" in OS.get_cmdline_user_args():
		(main.get_node("MistValleyAmbience") as AudioStreamPlayer).volume_db = -80.0
		(main.get_node("PortalHum") as AudioStreamPlayer3D).volume_db = -80.0
	print("Footstep capture volume: ", (main.get_node("Player/Footsteps") as AudioStreamPlayer3D).volume_db, " dB")
	await create_timer(1.5).timeout
	Input.action_press("move_forward")
	await create_timer(3.0).timeout
	Input.action_release("move_forward")
	await create_timer(0.8).timeout
	quit()
