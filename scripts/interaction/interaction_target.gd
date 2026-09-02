class_name InteractionTarget
extends Area3D

signal interacted(target_id: StringName)

@export var target_id: StringName
@export var prompt_key: StringName = &"interaction.inspect"
@export var interaction_priority: int = 0
@export_range(0.1, 20.0, 0.1) var interaction_distance: float = 3.0
@export var enabled: bool = true


func can_interact(actor: Node3D) -> bool:
	return enabled and actor != null and global_position.distance_to(actor.global_position) <= interaction_distance


func interact(actor: Node3D) -> bool:
	if not can_interact(actor):
		return false
	interacted.emit(target_id)
	return true


static func best_for_actor(targets: Array, actor: Node3D) -> InteractionTarget:
	var best: InteractionTarget
	var best_distance := INF
	for candidate: Variant in targets:
		var target := candidate as InteractionTarget
		if target == null or not target.can_interact(actor):
			continue
		var distance := target.global_position.distance_to(actor.global_position)
		if best == null or target.interaction_priority > best.interaction_priority or (target.interaction_priority == best.interaction_priority and distance < best_distance):
			best = target
			best_distance = distance
	return best
