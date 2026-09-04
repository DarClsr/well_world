extends Node3D


const ROCK_SCENES: Array[PackedScene] = [
	preload("res://assets/quaternius/nature/Rock_Medium_1.gltf"),
	preload("res://assets/quaternius/nature/Rock_Medium_2.gltf"),
]
const ROCK_TEXTURE := preload("res://assets/quaternius/nature/Rocks_Diffuse.png")

const NORTH_X: Array[float] = [-24.0, -19.0, -14.0, -9.0, -5.5, 5.5, 9.0, 14.0, 19.0, 24.0]
const SOUTH_X: Array[float] = [-24.0, -19.0, -14.0, -9.0, -4.0, 1.0, 6.0, 11.0, 16.0, 21.0, 25.0]
const SIDE_Z: Array[float] = [-22.0, -16.0, -10.0, -4.0, 2.0, 8.0, 14.0, 20.0, 26.0]


func build(stone_material: Material) -> void:
	assert(get_child_count() == 0, "ValleyBoundary.build() must only run once")
	_add_collision_box("NorthCliffWest", Vector3(26.0, 8.0, 5.0), Vector3(-17.0, 3.0, -27.0), stone_material)
	_add_collision_box("NorthCliffEast", Vector3(26.0, 8.0, 5.0), Vector3(17.0, 3.0, -27.0), stone_material)
	_add_collision_box("SouthCliff", Vector3(60.0, 7.0, 5.0), Vector3(0.0, 2.5, 32.0), stone_material)
	_add_collision_box("WestCliff", Vector3(5.0, 7.0, 59.0), Vector3(-27.0, 2.5, 2.5), stone_material)
	_add_collision_box("EastCliff", Vector3(5.0, 7.0, 59.0), Vector3(27.0, 2.5, 2.5), stone_material)
	_build_cliff_visuals()


func _add_collision_box(node_name: String, size: Vector3, position: Vector3, material: Material) -> void:
	var cliff := CSGBox3D.new()
	cliff.name = node_name
	cliff.size = size
	cliff.position = position
	cliff.material = material
	cliff.use_collision = true
	cliff.visible = false
	add_child(cliff)


func _build_cliff_visuals() -> void:
	var cliff_visuals := Node3D.new()
	cliff_visuals.name = "CliffVisuals"
	add_child(cliff_visuals)
	var cliff_material := StandardMaterial3D.new()
	cliff_material.resource_name = "BoundaryRockMuted"
	cliff_material.albedo_color = Color("748084")
	cliff_material.albedo_texture = ROCK_TEXTURE
	cliff_material.roughness = 0.98
	cliff_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	var placements: Array[Vector3] = []
	for x in NORTH_X:
		placements.append(Vector3(x, 0.0, -25.4))
	for x in SOUTH_X:
		placements.append(Vector3(x, 0.0, 30.3))
	for z in SIDE_Z:
		placements.append(Vector3(-25.3, 0.0, z))
		placements.append(Vector3(25.3, 0.0, z + 1.2))
	for index in placements.size():
		var scale_factor := 2.35 + float((index * 7) % 5) * 0.18
		var position := placements[index]
		position.y = float(index % 3) * 0.22 - 0.12
		if position.z < -25.0 and absf(position.x) < 10.0:
			scale_factor = minf(scale_factor * 0.72, 2.05)
		var cliff_rock := ROCK_SCENES[index % ROCK_SCENES.size()].instantiate() as Node3D
		cliff_rock.name = "CliffRock%02d" % index
		cliff_rock.position = position
		cliff_rock.rotation.y = fmod(float(index) * 1.37, TAU)
		cliff_rock.scale = Vector3.ONE * scale_factor
		cliff_visuals.add_child(cliff_rock)
		for mesh_node in cliff_rock.find_children("*", "MeshInstance3D", true, false):
			(mesh_node as MeshInstance3D).material_override = cliff_material
