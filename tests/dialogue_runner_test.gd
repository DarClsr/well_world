extends SceneTree

const DialogueLineScript = preload("res://scripts/dialogue/dialogue_line_data.gd")
const DialogueDataScript = preload("res://scripts/dialogue/dialogue_data.gd")
const DialogueRunnerScript = preload("res://scripts/dialogue/dialogue_runner.gd")


func _initialize() -> void:
	var intro = DialogueLineScript.new()
	intro.id = &"intro"
	intro.speaker_id = &"toren"
	intro.text_key = &"dialogue.toren.intro"
	intro.next_line_id = &"hidden"
	var hidden = DialogueLineScript.new()
	hidden.id = &"hidden"
	hidden.text_key = &"dialogue.hidden"
	hidden.required_flags = {&"never_set": true}
	hidden.next_line_id = &"choice"
	var choice = DialogueLineScript.new()
	choice.id = &"choice"
	choice.text_key = &"dialogue.choice"
	choice.choice_ids.assign([&"stay", &"leave"])
	choice.choice_next_line_ids = {&"stay": &"end", &"leave": &"end"}
	var ending = DialogueLineScript.new()
	ending.id = &"end"
	ending.text_key = &"dialogue.end"
	ending.set_flags = {&"toren_met": true}
	var data = DialogueDataScript.new()
	data.id = &"toren_intro"
	data.start_line_id = &"intro"
	data.lines = {&"intro": intro, &"hidden": hidden, &"choice": choice, &"end": ending}
	var state := WorldState.new()
	var runner = DialogueRunnerScript.new()
	root.add_child(runner)
	var shown: Array[StringName] = []
	var choices: Array = []
	var finished := [0]
	runner.line_started.connect(func(_speaker: StringName, text_key: StringName) -> void: shown.append(text_key))
	runner.choice_requested.connect(func(ids: Array[StringName]) -> void: choices.append(ids.duplicate()))
	runner.dialogue_finished.connect(func(_id: StringName) -> void: finished[0] += 1)
	assert(runner.start(data, state))
	assert(runner.advance())
	assert(shown == [&"dialogue.toren.intro", &"dialogue.choice"])
	assert(choices == [[&"stay", &"leave"]])
	assert(not runner.advance())
	assert(not runner.choose(&"unknown"))
	assert(runner.choose(&"stay"))
	assert(shown.back() == &"dialogue.end")
	assert(runner.advance())
	assert(state.flags[&"toren_met"] == true)
	assert(finished[0] == 1)
	assert(not runner.advance())
	print("DIALOGUE RUNNER TEST PASSED")
	quit(0)
