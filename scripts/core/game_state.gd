extends Node

signal state_replaced(state: WorldState)

var active: WorldState = WorldState.new()
var event_bus: Node


func _ready() -> void:
	if event_bus == null:
		event_bus = get_node_or_null("/root/EventBus")


func start_new_game() -> void:
	active = WorldState.new()
	state_replaced.emit(active)


func replace_state(state: WorldState) -> void:
	assert(state != null)
	active = state
	state_replaced.emit(active)


func set_flag(key: StringName, value: Variant) -> bool:
	if active.flags.get(key) == value and active.flags.has(key):
		return false
	active.flags[key] = value
	if event_bus != null:
		event_bus.emit_signal("world_flag_changed", key, value)
	return true
