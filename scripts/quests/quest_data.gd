class_name QuestData
extends Resource

@export var id: StringName
@export var title_key: StringName
@export var steps: Array[QuestStepData] = []


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if id.is_empty():
		warnings.append("Quest id must not be empty.")
	var seen: Dictionary = {}
	for step: QuestStepData in steps:
		if step == null or step.id.is_empty():
			warnings.append("Quest steps must have non-empty ids.")
		elif seen.has(step.id):
			warnings.append("Duplicate quest step id: %s" % step.id)
		else:
			seen[step.id] = true
	return warnings

