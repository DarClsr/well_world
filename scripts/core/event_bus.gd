extends Node

signal world_flag_changed(key: StringName, value: Variant)
signal quest_started(quest_id: StringName)
signal quest_advanced(quest_id: StringName, step_index: int)
signal quest_completed(quest_id: StringName)
signal region_changed(region_id: StringName)

