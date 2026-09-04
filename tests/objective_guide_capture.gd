extends SceneTree


func _initialize() -> void:
	call_deferred("_record")


func _record() -> void:
	var output_dir := "res://temp/objective-guide"
	DirAccess.make_dir_recursive_absolute(output_dir)
	root.get_node("GameState").start_new_game()
	var scene := load("res://scenes/game/game_root.tscn") as PackedScene
	var game_root := scene.instantiate()
	root.add_child(game_root)
	await process_frame
	await process_frame
	var main := game_root.get_node("RegionContainer/FogValley/Main")
	main.set("time_hour", 9.5)
	main.set("time_running", false)
	main.set("weather_seed", 20260902)
	main.set("weather_running", false)
	main.set("weather_override", "clear")
	main.set_physics_process(false)
	var player := main.get_node("Player") as CharacterBody3D
	player.set_physics_process(false)
	player.set("camera_target_height", 12.0)
	player.call("_update_camera_zoom", 1.0)
	var objective_label := game_root.get_node("PersistentUI/ObjectiveRow/ObjectiveText") as Label

	await create_timer(3.2).timeout
	await _capture(output_dir, "01-portal", objective_label)
	main.call("_show_portal_lore")
	player.position = Vector3(2.8, 1.0, -14.2)
	await create_timer(0.25).timeout
	await _capture(output_dir, "02-find-toren", objective_label)

	main.set("nearby_villager", main.get_node("GatekeeperToren"))
	main.call("_show_villager_dialogue")
	await create_timer(0.25).timeout
	await _capture(output_dir, "03-find-mira", objective_label)
	player.position = Vector3(-12.1, 1.0, -7.2)
	main.set("nearby_villager", main.get_node("HerbalistMira"))
	main.call("_show_villager_dialogue")
	await create_timer(0.25).timeout
	await _capture(output_dir, "04-gather-herb", objective_label)

	var herb := main.get_node("HerbPlot/GatherableMistleaf") as Node3D
	var herb_target := herb.get_node("InteractionTarget") as InteractionTarget
	player.global_position = herb_target.global_position + Vector3(1.2, 1.0, 0.0)
	assert(main.call("_gather_herb", player))
	await create_timer(0.25).timeout
	await _capture(output_dir, "05-reach-hearth", objective_label)
	player.global_position = (main.get_node("VillageHearth") as Node3D).global_position
	main.call("_update_hearth_event")
	await create_timer(0.25).timeout
	await _capture(output_dir, "06-hearth-clue", objective_label)
	print("OBJECTIVE GUIDE CAPTURE PASSED completed=", game_root.get_node("QuestRuntime").get_status(&"arrival"))
	quit()


func _capture(output_dir: String, shot_name: String, objective_label: Label) -> void:
	await process_frame
	await process_frame
	var image := root.get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path("%s/%s.png" % [output_dir, shot_name]))
	print("SAVED ", shot_name, " objective=", objective_label.text)
