extends SceneTree

const WorldStateScript = preload("res://scripts/state/world_state.gd")
const GameStateScript = preload("res://scripts/core/game_state.gd")
const EventBusScript = preload("res://scripts/core/event_bus.gd")


func _initialize() -> void:
	var state = WorldStateScript.new()
	state.current_region = &"fog_valley"
	state.spawn_id = &"portal_arrival"
	state.flags[&"portal_seen"] = true
	state.relationships[&"mira"] = 2
	state.quests[&"arrival"] = {"status": "active", "step_index": 1}
	state.collected_ids.append(&"first_echo")
	var restored = WorldStateScript.from_dictionary(state.to_dictionary())
	assert(restored != null)
	assert(restored.current_region == &"fog_valley")
	assert(restored.spawn_id == &"portal_arrival")
	assert(restored.flags[&"portal_seen"] == true)
	assert(restored.relationships[&"mira"] == 2)
	assert(restored.quests[&"arrival"]["step_index"] == 1)
	assert(restored.collected_ids == [&"first_echo"])
	restored.flags[&"portal_seen"] = false
	assert(state.flags[&"portal_seen"] == true)
	assert(WorldStateScript.from_dictionary({}) == null)
	assert(WorldStateScript.from_dictionary({"version": 1, "flags": null}) == null)
	assert(WorldStateScript.from_dictionary({"version": 1, "quests": "invalid"}) == null)
	assert(WorldStateScript.from_dictionary({"version": 1, "relationships": 12}) == null)
	assert(WorldStateScript.from_dictionary({"version": 1, "collected_ids": {}}) == null)
	var bus = EventBusScript.new()
	root.add_child(bus)
	var manager = GameStateScript.new()
	manager.event_bus = bus
	root.add_child(manager)
	var changes: Array = []
	bus.world_flag_changed.connect(func(key: StringName, value: Variant) -> void: changes.append([key, value]))
	assert(manager.set_flag(&"portal_seen", true))
	assert(not manager.set_flag(&"portal_seen", true))
	assert(changes == [[&"portal_seen", true]])
	manager.start_new_game()
	assert(manager.active.flags.is_empty())
	print("WORLD STATE TEST PASSED")
	quit(0)
