extends SceneTree


func _initialize() -> void:
	call_deferred("_check")


func _check() -> void:
	var entries: Array = JSON.parse_string(FileAccess.get_file_as_string("res://assets/fantasy_props/manifest.json"))
	entries = entries.filter(func(e: Dictionary) -> bool: return e.category == "travel")
	assert(entries.size() == 4)
	for entry: Dictionary in entries:
		var path: String = "res://assets/fantasy_props/" + entry.name
		var model := (load(path + ".glb") as PackedScene).instantiate() as Node3D
		root.add_child(model)
		var meshes := model.find_children("*", "MeshInstance3D", true, false)
		assert(meshes.size() == 1)
		var mesh := meshes[0] as MeshInstance3D
		for surface in mesh.mesh.get_surface_count():
			var material := mesh.mesh.surface_get_material(surface) as StandardMaterial3D
			assert(material.albedo_texture != null and material.normal_enabled)
			assert(material.roughness_texture != null)
		var bounds := mesh.transform * mesh.mesh.get_aabb()
		assert(absf(bounds.position.y) < 0.002)
		var lantern: bool = entry.name == "15_Old_Lantern"
		var player := model.find_child("AnimationPlayer", true, false) as AnimationPlayer
		assert((player != null) == lantern)
		if lantern:
			var clip: String = player.get_animation_list()[0]
			assert(is_equal_approx(player.get_animation(clip).length, 4.0))
			player.play(clip)
			player.seek(0.0, true)
			var first := mesh.transform
			player.seek(1.0, true)
			assert(not mesh.transform.is_equal_approx(first))
			player.seek(4.0, true)
			assert(mesh.transform.is_equal_approx(first))
		var text := '[gd_scene load_steps=%d format=3]\n\n[ext_resource type="PackedScene" path="%s.glb" id="1"]\n' % [3 if lantern else 2, path]
		if lantern:
			text += '[ext_resource type="Script" path="res://assets/fantasy_props/lantern_idle.gd" id="2"]\n'
		text += '\n[node name="%s" type="Node3D"]\n' % entry.name
		if lantern:
			text += 'script = ExtResource("2")\n'
		text += '\n[node name="Model" parent="." instance=ExtResource("1")]\n'
		if lantern:
			text += '\n[node name="WarmLight" type="OmniLight3D" parent="."]\nposition = Vector3(0, 0.32, 0)\nlight_color = Color(1, 0.65, 0.28, 1)\nlight_energy = 0.65\nomni_range = 2.2\nshadow_enabled = false\n'
		var file := FileAccess.open(path + ".tscn", FileAccess.WRITE)
		file.store_string(text); file.close()
		model.queue_free()
		var prefab := (load(path + ".tscn") as PackedScene).instantiate()
		root.add_child(prefab)
		assert(prefab.find_children("*", "CollisionObject3D", true, false).is_empty())
		if lantern:
			assert((prefab.get_node("WarmLight") as OmniLight3D).visible)
			var runtime_player := prefab.find_child("AnimationPlayer", true, false) as AnimationPlayer
			assert(not runtime_player.is_playing())
			var suspended := (load(path + ".tscn") as PackedScene).instantiate()
			suspended.set("hanging", true)
			suspended.set("lit", false)
			root.add_child(suspended)
			assert((suspended.find_child("AnimationPlayer", true, false) as AnimationPlayer).is_playing())
			assert(not (suspended.get_node("WarmLight") as OmniLight3D).visible)
			suspended.queue_free()
		prefab.queue_free()
		print("TRAVEL_PASS ", entry.name, " triangles=", entry.triangles)
	print("TRAVEL_PROPS_PASS count=4 loop_verified=1")
	quit()
