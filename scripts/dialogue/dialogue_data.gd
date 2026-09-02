class_name DialogueData
extends Resource

@export var id: StringName
@export var start_line_id: StringName
@export var lines: Dictionary = {}


func get_line(line_id: StringName) -> DialogueLineData:
	return lines.get(line_id) as DialogueLineData


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if id.is_empty():
		warnings.append("Dialogue id must not be empty.")
	if start_line_id.is_empty() or get_line(start_line_id) == null:
		warnings.append("Dialogue start line must exist.")
	return warnings

