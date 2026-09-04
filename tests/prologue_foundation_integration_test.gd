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
	var objective_row := game_root.get_node("PersistentUI/ObjectiveRow") as HBoxContainer
	var objective_label := objective_row.get_node("ObjectiveText") as Label
	assert(objective_row != null and objective_label != null)
	assert(objective_label.mouse_filter == Control.MOUSE_FILTER_IGNORE)
	assert(quest_runtime.get_status(&"arrival") == &"active")
	assert(objective_label.text == "调查苏醒的异界石环")
	main.call("_show_portal_lore")
	assert((main.get("portal_lore") as Label).text == "异界气息仍在石环深处回响。")
	assert(game_state.active.quests[&"arrival"]["step_index"] == 1)
	assert(objective_label.text == "沿石路寻找守门人托伦")
	main.set("nearby_villager", main.get_node("GatekeeperToren"))
	main.call("_show_villager_dialogue")
	assert((main.get("portal_lore") as Label).text == "托伦：北边山口雾重。先沿石路去西侧药圃找米拉吧。")
	assert(game_state.active.quests[&"arrival"]["step_index"] == 2)
	assert(objective_label.text == "去西侧药圃找药草师米拉")
	var player := main.get_node("Player") as CharacterBody3D
	player.global_position = (main.get_node("VillageHearth") as Node3D).global_position
	var toren_text := (main.get("portal_lore") as Label).text
	main.call("_update_hearth_event")
	assert(quest_runtime.get_status(&"arrival") == &"active")
	assert(game_state.active.quests[&"arrival"]["step_index"] == 2)
	assert(not main.get("hearth_event_emitted"))
	assert((main.get("portal_lore") as Label).text == toren_text)
	main.set("nearby_villager", main.get_node("HerbalistMira"))
	main.call("_show_villager_dialogue")
	assert((main.get("portal_lore") as Label).text == "米拉：雾起前采下的雾叶草效力最好。能替我采一株吗？")
	assert(game_state.active.flags.get(&"mira_met") == true)
	assert(objective_label.text == "替米拉采一株雾叶草")
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
	assert(objective_label.text == "前往村庄炉火")
	assert((main.get("portal_lore") as Label).text == "雾叶草的叶脉亮起，正回应着村庄炉火的暖光。")
	main.set("nearby_villager", main.get_node("HerbalistMira"))
	main.call("_show_villager_dialogue")
	assert((main.get("portal_lore") as Label).text == "米拉：谢谢你。先把它带到炉火旁吧，暖光会让叶脉说出它的来处。")
	assert(game_state.active.quests[&"arrival"]["step_index"] == 3)
	assert(save_service.save_state(game_state.active, SAVE_PATH) == OK)
	var restored: WorldState = save_service.load_state(SAVE_PATH)
	assert(restored != null and restored.quests[&"arrival"]["step_index"] == 3)
	assert(&"mira_mistleaf" in restored.collected_ids)
	game_state.replace_state(restored)
	assert(quest_runtime.state == restored)
	assert(objective_label.text == "前往村庄炉火")
	main.call("_update_villager_interaction")
	assert(not herb.visible and not herb_target.enabled)
	assert(not main.call("_gather_herb", player))
	player.global_position = (main.get_node("VillageHearth") as Node3D).global_position
	main.call("_update_hearth_event")
	assert(quest_runtime.get_status(&"arrival") == &"completed")
	assert((main.get("portal_lore") as Label).text == "雾叶草在炉火旁泛起青光，北方山口传来遥远的回响。")
	await create_timer(0.25).timeout
	assert(not objective_row.visible)
	main.set("nearby_villager", main.get_node("HerbalistMira"))
	main.call("_show_villager_dialogue")
	assert((main.get("portal_lore") as Label).text == "米拉：原来那道青光不属于雾谷。北方山口或许记得你从哪里来。")
	main.call("_update_hearth_event")
	assert((main.get("portal_lore") as Label).text == "米拉：原来那道青光不属于雾谷。北方山口或许记得你从哪里来。")
	game_state.start_new_game()
	assert(quest_runtime.get_status(&"arrival") == &"active")
	assert(objective_row.visible and objective_label.text == "调查苏醒的异界石环")
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
