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
	player.set("camera_target_height", 12.0)
	player.call("_update_camera_zoom", 1.0)
	print("Route portal spawn: ", player.position)
	await create_timer(0.8).timeout

	player.position = Vector3(0.0, 1.0, 12.0)
	await create_timer(1.0).timeout
	print("Route pond fork: ", player.position)

	player.position = Vector3(0.0, 1.0, -22.0)
	await create_timer(1.2).timeout
	var mist_pass := main.get_node("MistPass") as Node3D
	print("Route mist pass: ", player.position, " nodes=", mist_pass.get_child_count())
	quit()
