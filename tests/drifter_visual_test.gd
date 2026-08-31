extends SceneTree


const DRIFTER_SCENE := "res://scenes/player/drifter_visual.tscn"
const REQUIRED_ASSETS := [
	"res://assets/kaykit/adventurers/Rogue_Hooded.glb",
	"res://assets/kaykit/adventurers/Rig_Medium_General.glb",
	"res://assets/kaykit/adventurers/Rig_Medium_MovementBasic.glb",
	"res://shaders/drifter_palette.gdshader",
]


func _initialize() -> void:
	for asset_path in REQUIRED_ASSETS:
		assert(ResourceLoader.exists(asset_path), "Missing drifter dependency: %s" % asset_path)
	assert(FileAccess.file_exists("res://assets/kaykit/adventurers/License.txt"), "Missing KayKit license")
	assert(ResourceLoader.exists(DRIFTER_SCENE), "Drifter visual scene has not been created")

	var packed := load(DRIFTER_SCENE) as PackedScene
	assert(packed != null)
	var drifter := packed.instantiate() as Node3D
	root.add_child(drifter)
	await process_frame

	var model := drifter.get_node_or_null("RiggedModel") as Node3D
	var animation_player := drifter.get_node_or_null("AnimationPlayer") as AnimationPlayer
	assert(model != null)
	assert(animation_player != null)
	assert(animation_player.root_node == NodePath("../RiggedModel"), "Drifter animation root path is invalid")
	for animation_name in ["Idle", "Walk", "Run", "Interact", "PickUp"]:
		assert(animation_player.has_animation(animation_name), "Missing drifter animation: %s" % animation_name)
	assert(animation_player.current_animation == "Idle")
	assert(animation_player.get_animation("Idle").loop_mode == Animation.LOOP_LINEAR)
	assert(animation_player.get_animation("Walk").loop_mode == Animation.LOOP_LINEAR)
	assert(animation_player.get_animation("Run").loop_mode == Animation.LOOP_LINEAR)

	var skeleton := model.find_child("Skeleton3D", true, false) as Skeleton3D
	assert(skeleton != null and skeleton.get_bone_count() == 23)
	var mesh_nodes := model.find_children("*", "MeshInstance3D", true, false)
	assert(mesh_nodes.size() >= 8)
	for mesh_node in mesh_nodes:
		var mesh_instance := mesh_node as MeshInstance3D
		if mesh_instance.name == "OtherworldMark":
			continue
		for surface_index in mesh_instance.get_surface_override_material_count():
			assert(mesh_instance.get_active_material(surface_index) is ShaderMaterial)

	var mark := model.find_child("OtherworldMark", true, false) as MeshInstance3D
	assert(mark != null, "Drifter is missing the otherworld mark")
	assert(mark.get_parent() is BoneAttachment3D)
	assert((mark.get_parent() as BoneAttachment3D).bone_name == "chest")
	var mark_material := mark.material_override as StandardMaterial3D
	assert(mark_material != null and mark_material.emission_enabled)
	assert(mark_material.emission.is_equal_approx(Color("54d8cf")))

	print("DRIFTER VISUAL TEST PASSED")
	quit()
