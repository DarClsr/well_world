class_name SceneRouter
extends Node

signal region_changed(region_id: StringName)

var region_container: Node
var game_state_manager: Node
var event_bus: Node
var current_region: Node
var _registry: Dictionary = {}


func configure(container: Node, state_manager: Node, bus: Node = null) -> void:
	assert(container != null and state_manager != null)
	region_container = container
	game_state_manager = state_manager
	event_bus = bus


func register_region(region_id: StringName, scene: PackedScene) -> void:
	assert(not region_id.is_empty() and scene != null)
	_registry[region_id] = scene


func travel_to(region_id: StringName, spawn_id: StringName) -> Error:
	if region_container == null or game_state_manager == null:
		return ERR_UNCONFIGURED
	if not _registry.has(region_id):
		return ERR_DOES_NOT_EXIST
	var scene := _registry[region_id] as PackedScene
	var next_region := scene.instantiate()
	region_container.add_child(next_region)
	var player := next_region.find_child("Player", true, false) as Node3D
	var marker := _find_spawn(next_region, spawn_id)
	if player == null or marker == null:
		region_container.remove_child(next_region)
		next_region.free()
		return ERR_INVALID_DATA
	player.global_position = marker.global_position
	var previous := current_region
	current_region = next_region
	game_state_manager.active.current_region = region_id
	game_state_manager.active.spawn_id = spawn_id
	if previous != null:
		previous.queue_free()
	region_changed.emit(region_id)
	if event_bus != null and event_bus.has_signal("region_changed"):
		event_bus.emit_signal("region_changed", region_id)
	return OK


func _find_spawn(region: Node, spawn_id: StringName) -> Marker3D:
	var group_name := "region_spawn:%s" % spawn_id
	for child: Node in region.find_children("*", "Marker3D", true, false):
		if child.is_in_group(group_name):
			return child as Marker3D
	return null

