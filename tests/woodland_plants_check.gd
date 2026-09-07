extends SceneTree


func _initialize() -> void:
	call_deferred("_check")


func _check() -> void:
	var entries: Array = JSON.parse_string(FileAccess.get_file_as_string("res://assets/fantasy_props/manifest.json"))
	entries = entries.filter(func(entry: Dictionary) -> bool: return entry.category == "plants")
	assert(entries.size() == 7)
	var animated := 0
	for entry: Dictionary in entries:
		assert(entry.category == "plants")
		var path: String = "res://assets/fantasy_props/" + entry.name
		var model := (load(path + ".glb") as PackedScene).instantiate() as Node3D
		root.add_child(model)
		var meshes := model.find_children("*", "MeshInstance3D", true, false)
		assert(meshes.size() == 1, "Each prop should be one standalone mesh")
		var mesh := meshes[0] as MeshInstance3D
		assert(mesh.mesh.get_surface_count() <= 5)
		assert(mesh.mesh.get_aabb().size.length() > 0.1)
		var player := model.find_child("AnimationPlayer", true, false) as AnimationPlayer
		if entry.animated:
			assert(player != null and mesh.mesh.get_blend_shape_count() == 1)
			for clip in player.get_animation_list():
				if clip == "RESET":
					continue
				var animation := player.get_animation(clip)
				assert(is_equal_approx(animation.length, 4.0))
				for track in animation.get_track_count():
					assert(animation.track_get_type(track) == Animation.TYPE_BLEND_SHAPE)
					var count := animation.track_get_key_count(track)
					assert(is_equal_approx(float(animation.track_get_key_value(track, 0)), float(animation.track_get_key_value(track, count - 1))))
				player.play(clip)
				player.seek(1.0, true)
				var value := mesh.get_blend_shape_value(0)
				player.seek(3.0, true)
				assert(absf(value - mesh.get_blend_shape_value(0)) > 1.5)
				animated += 1
		else:
			assert(player == null or player.get_animation_list().is_empty())
		model.queue_free()
		var file := FileAccess.open(path + ".tscn", FileAccess.WRITE)
		file.store_string('[gd_scene load_steps=3 format=3]\n\n[ext_resource type="PackedScene" path="%s.glb" id="1"]\n[ext_resource type="Script" path="res://assets/fantasy_props/plant_idle.gd" id="2"]\n\n[node name="%s" type="Node3D"]\nscript = ExtResource("2")\n\n[node name="Model" parent="." instance=ExtResource("1")]\n' % [path, entry.name])
		file.close()
		var prefab := (load(path + ".tscn") as PackedScene).instantiate()
		root.add_child(prefab)
		if entry.animated:
			assert((prefab.find_child("AnimationPlayer", true, false) as AnimationPlayer).is_playing())
		prefab.queue_free()
		print("PLANT_PASS ", entry.name, " triangles=", entry.triangles, " animated=", entry.animated)
	assert(animated == 4)
	print("WOODLAND_PLANTS_PASS count=7 moving_closed_loops=4")
	quit()
