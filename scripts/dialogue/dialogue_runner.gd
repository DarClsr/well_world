class_name DialogueRunner
extends Node

signal line_started(speaker_id: StringName, text_key: StringName)
signal choice_requested(choice_ids: Array[StringName])
signal event_requested(event_id: StringName)
signal dialogue_finished(dialogue_id: StringName)

var active_data: DialogueData
var state: WorldState
var current_line_id: StringName
var visible_choice_ids: Array[StringName] = []


func start(data: DialogueData, world_state: WorldState) -> bool:
	if data == null or world_state == null or data.get_line(data.start_line_id) == null:
		return false
	active_data = data
	state = world_state
	current_line_id = data.start_line_id
	visible_choice_ids.clear()
	return _show_current()


func advance() -> bool:
	if active_data == null or not visible_choice_ids.is_empty():
		return false
	var line := active_data.get_line(current_line_id)
	if line == null or line.next_line_id.is_empty():
		_finish()
		return true
	current_line_id = line.next_line_id
	return _show_current()


func choose(choice_id: StringName) -> bool:
	if active_data == null or choice_id not in visible_choice_ids:
		return false
	var line := active_data.get_line(current_line_id)
	if line == null or not line.choice_next_line_ids.has(choice_id):
		return false
	visible_choice_ids.clear()
	current_line_id = StringName(str(line.choice_next_line_ids[choice_id]))
	return _show_current()


func _show_current() -> bool:
	while active_data != null:
		var line := active_data.get_line(current_line_id)
		if line == null:
			_finish()
			return false
		if not line.conditions_match(state):
			if line.next_line_id.is_empty():
				_finish()
				return true
			current_line_id = line.next_line_id
			continue
		for key: Variant in line.set_flags:
			state.flags[key] = line.set_flags[key]
		for event_id: StringName in line.emit_event_ids:
			event_requested.emit(event_id)
		line_started.emit(line.speaker_id, line.text_key)
		visible_choice_ids = line.choice_ids.duplicate()
		if not visible_choice_ids.is_empty():
			choice_requested.emit(visible_choice_ids)
		return true
	return false


func _finish() -> void:
	if active_data == null:
		return
	var dialogue_id := active_data.id
	active_data = null
	current_line_id = &""
	visible_choice_ids.clear()
	dialogue_finished.emit(dialogue_id)

