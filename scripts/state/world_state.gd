class_name WorldState
extends Resource

const CURRENT_VERSION := 1

var version: int = CURRENT_VERSION
var current_region: StringName = &"fog_valley"
var spawn_id: StringName = &"portal_arrival"
var flags: Dictionary = {}
var quests: Dictionary = {}
var relationships: Dictionary = {}
var collected_ids: Array[StringName] = []


func to_dictionary() -> Dictionary:
	var collected: Array[String] = []
	for item_id: StringName in collected_ids:
		collected.append(String(item_id))
	return {
		"version": version,
		"current_region": String(current_region),
		"spawn_id": String(spawn_id),
		"flags": _stringify_keys(flags),
		"quests": _stringify_keys(quests),
		"relationships": _stringify_keys(relationships),
		"collected_ids": collected,
	}


static func from_dictionary(data: Dictionary) -> WorldState:
	if not data.has("version") or typeof(data["version"]) not in [TYPE_INT, TYPE_FLOAT]:
		return null
	var parsed_version := int(data["version"])
	if float(data["version"]) != float(parsed_version) or parsed_version != CURRENT_VERSION:
		return null
	var state := WorldState.new()
	state.version = parsed_version
	state.current_region = StringName(str(data.get("current_region", "fog_valley")))
	state.spawn_id = StringName(str(data.get("spawn_id", "portal_arrival")))
	var raw_flags: Variant = data.get("flags", {})
	var raw_quests: Variant = data.get("quests", {})
	var raw_relationships: Variant = data.get("relationships", {})
	var raw_collected_ids: Variant = data.get("collected_ids", [])
	if not raw_flags is Dictionary or not raw_quests is Dictionary or not raw_relationships is Dictionary or not raw_collected_ids is Array:
		return null
	state.flags = _name_keys(raw_flags as Dictionary)
	state.quests = _name_keys(raw_quests as Dictionary)
	state.relationships = _name_keys(raw_relationships as Dictionary)
	for value: Variant in raw_collected_ids as Array:
		state.collected_ids.append(StringName(str(value)))
	return state


static func _stringify_keys(source: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key: Variant in source:
		var value: Variant = source[key]
		result[String(key)] = value.duplicate(true) if value is Dictionary or value is Array else value
	return result


static func _name_keys(source: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key: Variant in source:
		var value: Variant = source[key]
		result[StringName(str(key))] = value.duplicate(true) if value is Dictionary or value is Array else value
	return result
