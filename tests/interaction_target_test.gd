extends SceneTree

const InteractionTargetScript = preload("res://scripts/interaction/interaction_target.gd")


func _initialize() -> void:
	var actor := Node3D.new()
	root.add_child(actor)
	var low = InteractionTargetScript.new()
	low.target_id = &"low"
	low.interaction_priority = 1
	low.interaction_distance = 3.0
	root.add_child(low)
	var high = InteractionTargetScript.new()
	high.target_id = &"high"
	high.interaction_priority = 5
	high.interaction_distance = 3.0
	root.add_child(high)
	await process_frame
	actor.global_position = Vector3.ZERO
	low.global_position = Vector3(2.0, 0.0, 0.0)
	high.global_position = Vector3(2.0, 0.0, 0.0)
	assert(low.can_interact(actor))
	assert(high.can_interact(actor))
	assert(InteractionTargetScript.best_for_actor([low, high], actor) == high)
	high.enabled = false
	assert(InteractionTargetScript.best_for_actor([low, high], actor) == low)
	var received: Array[StringName] = []
	low.interacted.connect(func(target_id: StringName) -> void: received.append(target_id))
	assert(low.interact(actor))
	assert(received == [&"low"])
	actor.global_position = Vector3(8.0, 0.0, 0.0)
	assert(not low.interact(actor))
	print("INTERACTION TARGET TEST PASSED")
	quit(0)
