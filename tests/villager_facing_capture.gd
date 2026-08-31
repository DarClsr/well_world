extends SceneTree


func _initialize() -> void:
	call_deferred("_record")


func _record() -> void:
	var scene := load("res://scenes/main.tscn") as PackedScene
	var main := scene.instantiate()
	root.add_child(main)
	await create_timer(1.8).timeout
	var player := main.get_node("Player") as CharacterBody3D
	var npc := main.get_node("WeaverNia") as CharacterBody3D
	player.position = npc.position + Vector3(2.0, 1.0, 0.0)
	player.get_node("Visual").rotation.y = -PI * 0.5
	player.set("camera_target_height", 10.0)
	player.call("_update_camera_zoom", 1.0)
	await create_timer(0.9).timeout
	main.call("_show_villager_dialogue")
	await create_timer(1.2).timeout
	var visual := npc.get_node("Visual") as Node3D
	print("Villager facing error: ", absf(angle_difference(visual.rotation.y, PI * 0.5)))
	quit()
