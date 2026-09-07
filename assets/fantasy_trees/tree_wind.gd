extends Node3D
## Canopy morph animation; trunk and collision never move.

@export_range(0.1, 2.0) var wind_speed: float = 1.0
@export_range(0.0, 4.0) var wind_offset: float = 0.0
@export var falling_leaves := true
@export var ground_leaves := true
@export var tree_height := 7.0
@export var crown_width := 6.0
@export var crown_depth := 5.0


func _ready() -> void:
	var player := find_child("AnimationPlayer", true, false) as AnimationPlayer
	if player == null:
		push_error("Fantasy tree is missing its AnimationPlayer")
		return
	for animation_name in player.get_animation_list():
		if animation_name == "RESET":
			continue
		player.get_animation(animation_name).loop_mode = Animation.LOOP_LINEAR
		player.speed_scale = wind_speed
		player.play(animation_name)
		player.seek(fposmod(wind_offset + global_position.x * 0.31 + global_position.z * 0.19, 4.0), true)
		break
	_add_leaves()


func _add_leaves() -> void:
	if not falling_leaves and not ground_leaves:
		return
	var leaf_color := Color(0.3, 0.4, 0.1)
	for mesh: MeshInstance3D in find_children("*", "MeshInstance3D", true, false):
		if mesh.mesh.get_blend_shape_count() == 2:
			leaf_color = (mesh.mesh.surface_get_arrays(0)[Mesh.ARRAY_COLOR] as PackedColorArray)[0].linear_to_srgb()
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var points := [Vector3(-0.18, 0, 0), Vector3(0, 0, -0.08), Vector3(0.22, 0, 0), Vector3(0, 0, 0.09), Vector3(0, 0.025, 0)]
	for triangle in [[0, 1, 4], [1, 2, 4], [2, 3, 4], [3, 0, 4]]:
		for vertex: int in triangle:
			surface.add_vertex(points[vertex])
	surface.generate_normals()
	var material := StandardMaterial3D.new()
	material.albedo_color = leaf_color.darkened(0.12)
	material.roughness = 0.95
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	surface.set_material(material)
	var leaf_mesh := surface.commit()
	if falling_leaves:
		var particles := CPUParticles3D.new()
		particles.name = "FallingLeaves"
		particles.mesh = leaf_mesh
		particles.amount = 7
		particles.position.y = tree_height * 0.66
		particles.lifetime = particles.position.y / 0.6
		particles.preprocess = particles.lifetime
		particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
		particles.emission_box_extents = Vector3(crown_width * 0.26, 0, crown_depth * 0.23)
		particles.direction = Vector3.DOWN
		particles.spread = 0.0
		particles.gravity = Vector3(0.014, 0, 0.006)
		particles.initial_velocity_min = 0.6
		particles.initial_velocity_max = 0.6
		particles.angular_velocity_min = -65.0
		particles.angular_velocity_max = 80.0
		particles.particle_flag_rotate_y = true
		particles.scale_amount_min = 0.65
		particles.scale_amount_max = 1.15
		var fade := Curve.new()
		fade.add_point(Vector2(0, 0))
		fade.add_point(Vector2(0.08, 1))
		fade.add_point(Vector2(0.88, 1))
		fade.add_point(Vector2(1, 0))
		particles.scale_amount_curve = fade
		add_child(particles)
	if ground_leaves:
		var scatter := MultiMeshInstance3D.new()
		scatter.name = "GroundLeaves"
		scatter.multimesh = MultiMesh.new()
		scatter.multimesh.transform_format = MultiMesh.TRANSFORM_3D
		scatter.multimesh.mesh = leaf_mesh
		scatter.multimesh.instance_count = 10
		for i in 10:
			var angle := i * 2.39996
			var radius := 0.8 + fmod(i * 0.731, crown_width * 0.30)
			var basis := Basis(Vector3.UP, angle).scaled(Vector3.ONE * (0.65 + (i % 4) * 0.12))
			scatter.multimesh.set_instance_transform(i, Transform3D(basis, Vector3(cos(angle) * radius, 0.018, sin(angle) * radius * 0.85)))
		add_child(scatter)
