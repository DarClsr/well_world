extends SceneTree

const SAVE_PATH := "user://tests/prologue-foundation.json"


func _initialize() -> void:
	var game_state = root.get_node("GameState")
	var save_service = root.get_node("SaveService")
	game_state.start_new_game()
	var root_scene := load("res://scenes/game/game_root.tscn") as PackedScene
	var game_root := root_scene.instantiate()
	root.add_child(game_root)
	await process_frame
	await process_frame
	var quest_runtime := game_root.get_node("QuestRuntime") as QuestRuntime
	var router := game_root.get_node("SceneRouter") as SceneRouter
	var main := game_root.get_node("RegionContainer/FogValley/Main")
	assert(quest_runtime.get_status(&"arrival") == &"active")
	main.call("_show_portal_lore")
	assert(game_state.active.quests[&"arrival"]["step_index"] == 1)
	main.set("nearby_villager", main.get_node("GatekeeperToren"))
	main.call("_show_villager_dialogue")
	assert(game_state.active.quests[&"arrival"]["step_index"] == 2)
	var player := main.get_node("Player") as CharacterBody3D
	player.global_position = (main.get_node("VillageHearth") as Node3D).global_position
	main.call("_update_hearth_event")
	assert(quest_runtime.get_status(&"arrival") == &"completed")
	assert(save_service.save_state(game_state.active, SAVE_PATH) == OK)
	var restored: WorldState = save_service.load_state(SAVE_PATH)
	assert(restored != null and restored.quests[&"arrival"]["status"] == "completed")
	game_state.replace_state(restored)
	assert(quest_runtime.state == restored)
	assert(router.travel_to(&"fog_valley", &"portal_arrival") == OK)
	await process_frame
	var reloaded := router.current_region.get_node("Main")
	assert(reloaded.find_children("*", "InteractionTarget", true, false).size() == 4)
	for suffix: String in ["", ".tmp", ".bak"]:
		var path := SAVE_PATH + suffix
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	print("PROLOGUE FOUNDATION INTEGRATION TEST PASSED")
	quit(0)
