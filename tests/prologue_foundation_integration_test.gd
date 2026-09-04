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
	assert((main.get("portal_lore") as Label).text == "异界气息仍在石环深处回响。")
	assert(game_state.active.quests[&"arrival"]["step_index"] == 1)
	main.set("nearby_villager", main.get_node("GatekeeperToren"))
	main.call("_show_villager_dialogue")
	assert((main.get("portal_lore") as Label).text == "托伦：沿石路走，别踏进谷边的浓雾。")
	assert(game_state.active.quests[&"arrival"]["step_index"] == 2)
	var player := main.get_node("Player") as CharacterBody3D
	player.global_position = (main.get_node("VillageHearth") as Node3D).global_position
	main.call("_update_hearth_event")
	assert(quest_runtime.get_status(&"arrival") == &"active")
	assert(game_state.active.quests[&"arrival"]["step_index"] == 2)
	assert(not main.get("hearth_event_emitted"))
	main.set("nearby_villager", main.get_node("HerbalistMira"))
	main.call("_show_villager_dialogue")
	assert((main.get("portal_lore") as Label).text == "米拉：雾起前采下的雾叶草效力最好。能替我采一株吗？")
	assert(game_state.active.flags.get(&"mira_met") == true)
	var herb := main.get_node("HerbPlot/GatherableMistleaf") as Node3D
	var herb_target := herb.get_node("InteractionTarget") as InteractionTarget
	player.global_position = herb_target.global_position + Vector3(1.0, 1.0, 0.0)
	main.call("_update_villager_interaction")
	assert(herb_target.enabled and main.get("nearby_herb") == herb_target)
	var interaction := InputEventAction.new()
	interaction.action = &"interact"
	interaction.pressed = true
	main.call("_unhandled_input", interaction)
	assert(game_state.active.quests[&"arrival"]["step_index"] == 3)
	assert(&"mira_mistleaf" in game_state.active.collected_ids)
	assert(not herb.visible and not herb_target.enabled)
	assert(save_service.save_state(game_state.active, SAVE_PATH) == OK)
	var restored: WorldState = save_service.load_state(SAVE_PATH)
	assert(restored != null and restored.quests[&"arrival"]["step_index"] == 3)
	assert(&"mira_mistleaf" in restored.collected_ids)
	game_state.replace_state(restored)
	assert(quest_runtime.state == restored)
	main.call("_update_villager_interaction")
	assert(not herb.visible and not herb_target.enabled)
	assert(not main.call("_gather_herb", player))
	player.global_position = (main.get_node("VillageHearth") as Node3D).global_position
	main.call("_update_hearth_event")
	assert(quest_runtime.get_status(&"arrival") == &"completed")
	game_state.start_new_game()
	assert(quest_runtime.get_status(&"arrival") == &"active")
	assert(router.travel_to(&"fog_valley", &"portal_arrival") == OK)
	await process_frame
	var reloaded := router.current_region.get_node("Main")
	assert(reloaded.find_children("*", "InteractionTarget", true, false).size() == 5)
	for suffix: String in ["", ".tmp", ".bak"]:
		var path := SAVE_PATH + suffix
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	print("PROLOGUE FOUNDATION INTEGRATION TEST PASSED")
	quit(0)
