class_name QuestRuntime
extends Node

signal quest_started(quest_id: StringName)
signal quest_advanced(quest_id: StringName, step_index: int)
signal quest_completed(quest_id: StringName)

var state: WorldState
var event_bus: Node
var _registry: Dictionary = {}


func configure(world_state: WorldState, bus: Node = null) -> void:
	assert(world_state != null)
	state = world_state
	event_bus = bus


func register_quest(quest: QuestData) -> void:
	assert(quest != null and not quest.id.is_empty())
	_registry[quest.id] = quest


func start_quest(quest: QuestData) -> bool:
	assert(state != null)
	register_quest(quest)
	if state.quests.has(quest.id):
		return false
	state.quests[quest.id] = {"status": "active", "step_index": 0}
	quest_started.emit(quest.id)
	_emit_bus("quest_started", [quest.id])
	return true


func advance(quest_id: StringName, event_id: StringName) -> bool:
	if state == null or not state.quests.has(quest_id) or not _registry.has(quest_id):
		return false
	var progress: Dictionary = state.quests[quest_id]
	if StringName(str(progress.get("status", ""))) != &"active":
		return false
	var quest: QuestData = _registry[quest_id]
	var step_index := int(progress.get("step_index", 0))
	if step_index < 0 or step_index >= quest.steps.size():
		return false
	if quest.steps[step_index].required_event != event_id:
		return false
	step_index += 1
	progress["step_index"] = step_index
	if step_index >= quest.steps.size():
		progress["status"] = "completed"
		quest_completed.emit(quest_id)
		_emit_bus("quest_completed", [quest_id])
	else:
		quest_advanced.emit(quest_id, step_index)
		_emit_bus("quest_advanced", [quest_id, step_index])
	return true


func get_status(quest_id: StringName) -> StringName:
	if state == null or not state.quests.has(quest_id):
		return &"not_started"
	return StringName(str((state.quests[quest_id] as Dictionary).get("status", "not_started")))


func _emit_bus(signal_name: StringName, arguments: Array) -> void:
	if event_bus != null and event_bus.has_signal(signal_name):
		if arguments.size() == 1:
			event_bus.emit_signal(signal_name, arguments[0])
		elif arguments.size() == 2:
			event_bus.emit_signal(signal_name, arguments[0], arguments[1])
