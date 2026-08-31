extends SceneTree


const NPC_SCENES: Dictionary[String, String] = {
	"MiraVisual": "res://scenes/npc/mira_visual.tscn",
	"TorenVisual": "res://scenes/npc/toren_visual.tscn",
	"NiaVisual": "res://scenes/npc/nia_visual.tscn",
}

const REQUIRED_MODELS := [
	"res://assets/kaykit/adventurers/Mage.glb",
	"res://assets/kaykit/adventurers/Knight.glb",
	"res://assets/kaykit/adventurers/Rogue.glb",
]


func _initialize() -> void:
	for model_path in REQUIRED_MODELS:
		assert(ResourceLoader.exists(model_path), "Missing NPC model: %s" % model_path)

	for expected_name in NPC_SCENES:
		var scene_path: String = NPC_SCENES[expected_name]
		assert(ResourceLoader.exists(scene_path), "Missing NPC visual scene: %s" % scene_path)
		var packed := load(scene_path) as PackedScene
		var visual := packed.instantiate() as Node3D
		root.add_child(visual)
		await process_frame

		assert(visual.name == expected_name)
		var model := visual.get_node_or_null("RiggedModel") as Node3D
		var animation_player := visual.get_node_or_null("AnimationPlayer") as AnimationPlayer
		assert(model != null)
		assert(animation_player != null)
		assert(animation_player.root_node == NodePath("../RiggedModel"))
		for animation_name in ["Idle", "Walk", "Run", "Interact", "PickUp"]:
			assert(animation_player.has_animation(animation_name))
		assert(animation_player.current_animation == "Idle")
		assert(animation_player.get_animation("Idle").loop_mode == Animation.LOOP_LINEAR)
		assert(animation_player.get_animation("Walk").loop_mode == Animation.LOOP_LINEAR)
		assert(animation_player.get_animation("PickUp").loop_mode == Animation.LOOP_NONE)

		var skeleton := model.find_child("Skeleton3D", true, false) as Skeleton3D
		assert(skeleton != null and skeleton.get_bone_count() == 23)
		assert(model.find_child("OtherworldMark", true, false) == null)
		for mesh_node in model.find_children("*", "MeshInstance3D", true, false):
			var mesh_instance := mesh_node as MeshInstance3D
			for surface_index in mesh_instance.get_surface_override_material_count():
				assert(mesh_instance.get_active_material(surface_index) is ShaderMaterial)

		visual.free()

	print("KAYKIT NPC VISUAL TEST PASSED")
	quit()
