class_name DialogueLineData
extends Resource

@export var id: StringName
@export var speaker_id: StringName
@export var text_key: StringName
@export var next_line_id: StringName
@export var choice_ids: Array[StringName] = []
@export var choice_next_line_ids: Dictionary = {}
@export var required_flags: Dictionary = {}
@export var blocked_flags: Dictionary = {}
@export var set_flags: Dictionary = {}
@export var emit_event_ids: Array[StringName] = []


func conditions_match(state: WorldState) -> bool:
	for key: Variant in required_flags:
		if not state.flags.has(key) or state.flags[key] != required_flags[key]:
			return false
	for key: Variant in blocked_flags:
		if state.flags.has(key) and state.flags[key] == blocked_flags[key]:
			return false
	return true

