extends SceneTree


func _initialize() -> void:
	call_deferred("_check")


func _check() -> void:
	var entries: Array = JSON.parse_string(FileAccess.get_file_as_string("res://assets/fantasy_props/manifest.json"))
	var village := "--village" in OS.get_cmdline_user_args()
	var category := "village" if village else "nature"
	entries = entries.filter(func(entry: Dictionary) -> bool: return entry.category == category)
	assert(entries.size() == 5)
	var collision_count := 0
	for i in entries.size():
		var entry: Dictionary = entries[i]
		var path: String = "res://assets/fantasy_props/" + entry.name
		var model := (load(path + ".glb") as PackedScene).instantiate() as Node3D
		root.add_child(model)
		var meshes := model.find_children("*", "MeshInstance3D", true, false)
		assert(meshes.size() == 1)
		var mesh := meshes[0] as MeshInstance3D
		assert(mesh.mesh.get_blend_shape_count() == 0)
		if village or int(entry.get("revision", 1)) >= 2:
			for surface in mesh.mesh.get_surface_count():
				var mat := mesh.mesh.surface_get_material(surface) as StandardMaterial3D
				assert(mat.albedo_texture != null and mat.normal_enabled and mat.normal_texture != null)
				assert(mat.roughness_texture != null)
				assert(mat.albedo_texture.get_width() == 1024)
		assert(model.find_child("AnimationPlayer", true, false) == null)
		var bounds := mesh.mesh.get_aabb()
		assert(bounds.position.y >= -0.001 and bounds.size.y > 0.04)
		var blocking: bool = entry.name in ["08_MossRock_Broad", "09_MossRock_Split", "12_Hollow_Log"]
		if village:
			blocking = entry.name in ["17_Staved_Barrel", "19_Firewood_Stack", "21_Glazed_Amphora"]
		var text := '[gd_scene load_steps=%d format=3]\n\n[ext_resource type="PackedScene" path="%s.glb" id="1"]\n' % [3 if blocking else 2, path]
		if blocking:
			var collision := mesh.mesh.create_convex_shape(true, true)
			assert(collision != null and collision.points.size() >= 4)
			assert(ResourceSaver.save(collision, path + "_collision.tres") == OK)
			text += '[ext_resource type="Shape3D" path="%s_collision.tres" id="2"]\n' % path
		text += '\n[node name="%s" type="Node3D"]\n\n[node name="Model" parent="." instance=ExtResource("1")]\n' % entry.name
		if blocking:
			text += '\n[node name="StaticBody3D" type="StaticBody3D" parent="."]\n\n[node name="CollisionShape3D" type="CollisionShape3D" parent="StaticBody3D"]\nshape = ExtResource("2")\n'
		var file := FileAccess.open(path + ".tscn", FileAccess.WRITE)
		file.store_string(text)
		file.close()
		model.queue_free()
		var prefab := (load(path + ".tscn") as PackedScene).instantiate() as Node3D
		prefab.position.x = i * 3.0
		root.add_child(prefab)
		await physics_frame
		await physics_frame
		var center := prefab.global_position + bounds.get_center()
		var query := PhysicsRayQueryParameters3D.create(center + Vector3.UP * 2, center + Vector3.DOWN * 2)
		var hit := prefab.get_world_3d().direct_space_state.intersect_ray(query)
		assert(not hit.is_empty() if blocking else hit.is_empty(), "Static collision must match decorative/blocking role")
		if blocking:
			collision_count += 1
		prefab.queue_free()
		print(category.to_upper(), "_PASS ", entry.name, " triangles=", entry.triangles, " blocking=", blocking)
	assert(collision_count == 3)
	print(category.to_upper(), "_PROPS_PASS count=5 raycast_verified=5")
	quit()
