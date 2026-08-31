extends Node3D


const GENERAL_ANIMATIONS: PackedScene = preload("res://assets/kaykit/adventurers/Rig_Medium_General.glb")
const MOVEMENT_ANIMATIONS: PackedScene = preload("res://assets/kaykit/adventurers/Rig_Medium_MovementBasic.glb")
const PALETTE_SHADER: Shader = preload("res://shaders/drifter_palette.gdshader")

const ANIMATION_SOURCES: Dictionary[String, String] = {
	"Idle": "Idle_A",
	"Walk": "Walking_A",
	"Run": "Running_A",
	"Interact": "Interact",
	"PickUp": "PickUp",
}

@export_group("Palette")
@export var tint_color: Color = Color("b8c6b3")
@export var rim_color: Color = Color("4db8ad")
@export_range(0.0, 1.0, 0.01) var saturation: float = 0.68
@export_range(0.25, 1.25, 0.01) var value_scale: float = 0.78
@export_range(0.0, 1.0, 0.01) var rim_strength: float = 0.10
@export_group("Identity")
@export var add_otherworld_mark: bool = false


func _ready() -> void:
	var model := get_node("RiggedModel") as Node3D
	_apply_palette(model)
	if add_otherworld_mark:
		_add_otherworld_mark(model)
	var animation_player := _build_animation_player()
	animation_player.play("Idle")


func _build_animation_player() -> AnimationPlayer:
	var general_library := _source_library(GENERAL_ANIMATIONS)
	var movement_library := _source_library(MOVEMENT_ANIMATIONS)
	var combined_library := AnimationLibrary.new()
	for target_name in ANIMATION_SOURCES:
		var source_name: String = ANIMATION_SOURCES[target_name]
		var source_library := movement_library if source_name.begins_with("Walking") or source_name.begins_with("Running") else general_library
		assert(source_library.has_animation(source_name), "Missing source animation: %s" % source_name)
		var animation := source_library.get_animation(source_name).duplicate(true) as Animation
		animation.loop_mode = Animation.LOOP_LINEAR if target_name in ["Idle", "Walk", "Run"] else Animation.LOOP_NONE
		combined_library.add_animation(target_name, animation)

	var animation_player := AnimationPlayer.new()
	animation_player.name = "AnimationPlayer"
	animation_player.root_node = NodePath("../RiggedModel")
	animation_player.add_animation_library("", combined_library)
	add_child(animation_player)
	return animation_player


func _source_library(scene: PackedScene) -> AnimationLibrary:
	var source_root := scene.instantiate() as Node3D
	var source_player := source_root.find_child("AnimationPlayer", true, false) as AnimationPlayer
	assert(source_player != null)
	var source_library := source_player.get_animation_library("").duplicate(true) as AnimationLibrary
	source_root.free()
	return source_library


func _apply_palette(model: Node3D) -> void:
	var material_cache: Dictionary[Material, ShaderMaterial] = {}
	for mesh_node in model.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := mesh_node as MeshInstance3D
		for surface_index in mesh_instance.get_surface_override_material_count():
			var source_material := mesh_instance.get_active_material(surface_index)
			if not (source_material is StandardMaterial3D):
				continue
			var standard_material := source_material as StandardMaterial3D
			var palette_material: ShaderMaterial = material_cache.get(source_material)
			if palette_material == null:
				palette_material = ShaderMaterial.new()
				palette_material.shader = PALETTE_SHADER
				palette_material.set_shader_parameter("albedo_texture", standard_material.albedo_texture)
				palette_material.set_shader_parameter("tint_color", tint_color)
				palette_material.set_shader_parameter("rim_color", rim_color)
				palette_material.set_shader_parameter("saturation", saturation)
				palette_material.set_shader_parameter("value_scale", value_scale)
				palette_material.set_shader_parameter("rim_strength", rim_strength)
				material_cache[source_material] = palette_material
			mesh_instance.set_surface_override_material(surface_index, palette_material)


func _add_otherworld_mark(model: Node3D) -> void:
	var skeleton := model.find_child("Skeleton3D", true, false) as Skeleton3D
	assert(skeleton != null and skeleton.find_bone("chest") >= 0)
	var attachment := BoneAttachment3D.new()
	attachment.name = "OtherworldMarkAttachment"
	attachment.bone_name = "chest"
	skeleton.add_child(attachment)

	var mark := MeshInstance3D.new()
	mark.name = "OtherworldMark"
	var mark_mesh := SphereMesh.new()
	mark_mesh.radius = 0.055
	mark_mesh.height = 0.11
	mark_mesh.radial_segments = 12
	mark_mesh.rings = 6
	mark.mesh = mark_mesh
	mark.position = Vector3(0.0, 0.02, 0.18)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("54d8cf")
	material.roughness = 0.25
	material.emission_enabled = true
	material.emission = Color("54d8cf")
	material.emission_energy_multiplier = 2.2
	mark.material_override = material
	attachment.add_child(mark)
