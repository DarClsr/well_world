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
	await create_timer(1.4).timeout
	var player := main.get_node("Player") as CharacterBody3D
	player.position = Vector3(0.0, 1.0, -6.5)
	player.set("camera_target_height", 10.0)
	player.call("_update_camera_zoom", 1.0)
	await create_timer(1.8).timeout
	for wear_name in ["VillageWearHearth", "VillageWearHerbs", "VillageWearWagon", "VillageWearEastDoor"]:
		var wear := main.get_node(wear_name) as MeshInstance3D
		print(wear_name, " elevation: ", wear.position.y)
	quit()
