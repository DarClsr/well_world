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
	await create_timer(1.6).timeout
	var player := main.get_node("Player") as CharacterBody3D
	player.position = Vector3(-9.0, 1.0, -13.5)
	player.set("camera_target_height", 10.0)
	player.call("_update_camera_zoom", 1.0)
	await create_timer(1.2).timeout
	var house_material := main.get("house_fade_materials")[0] as StandardMaterial3D
	print("Nearby house alpha: ", house_material.albedo_color.a)
	await create_timer(0.8).timeout
	quit()
