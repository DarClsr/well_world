extends SceneTree


func _initialize() -> void:
	call_deferred("_record")


func _record() -> void:
	var scene := load("res://scenes/main.tscn") as PackedScene
	var main := scene.instantiate()
	root.add_child(main)
	await create_timer(1.2).timeout
	var player := main.get_node("Player") as CharacterBody3D
	var villager := main.get_node("HerbalistMira") as CharacterBody3D
	player.position = villager.position + Vector3(0.0, 1.0, 4.5)
	player.set("camera_target_height", 10.0)
	player.call("_update_camera_zoom", 1.0)
	while main.get("villager_patrol_pauses")[0] <= 0.0:
		await process_frame
	var pause_position := villager.position
	await create_timer(0.8).timeout
	print("Villager pause drift: ", villager.position.distance_to(pause_position))
	quit()
