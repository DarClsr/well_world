extends SceneTree

const QuestStepScript = preload("res://scripts/quests/quest_step_data.gd")
const QuestDataScript = preload("res://scripts/quests/quest_data.gd")
const QuestRuntimeScript = preload("res://scripts/quests/quest_runtime.gd")


func _initialize() -> void:
	var quest = QuestDataScript.new()
	quest.id = &"arrival"
	quest.title_key = &"quest.arrival.title"
	for values: Array in [
		[&"inspect_portal", &"quest.arrival.portal", &"portal_inspected"],
		[&"meet_toren", &"quest.arrival.toren", &"toren_met"],
		[&"reach_hearth", &"quest.arrival.hearth", &"hearth_reached"],
	]:
		var step = QuestStepScript.new()
		step.id = values[0]
		step.description_key = values[1]
		step.required_event = values[2]
		quest.steps.append(step)
	var state := WorldState.new()
	var runtime = QuestRuntimeScript.new()
	runtime.configure(state)
	assert(runtime.start_quest(quest))
	assert(not runtime.start_quest(quest))
	assert(runtime.get_status(&"arrival") == &"active")
	assert(not runtime.advance(&"arrival", &"wrong_event"))
	assert(runtime.advance(&"arrival", &"portal_inspected"))
	assert(state.quests[&"arrival"]["step_index"] == 1)
	assert(runtime.advance(&"arrival", &"toren_met"))
	var restored := WorldState.from_dictionary(state.to_dictionary())
	var resumed = QuestRuntimeScript.new()
	resumed.configure(restored)
	resumed.register_quest(quest)
	assert(resumed.advance(&"arrival", &"hearth_reached"))
	assert(resumed.get_status(&"arrival") == &"completed")
	assert(not resumed.advance(&"arrival", &"hearth_reached"))
	print("QUEST RUNTIME TEST PASSED")
	quit(0)
