extends SceneTree


func _initialize() -> void:
	call_deferred("_prepare")


func _prepare() -> void:
	var manifest: Array = JSON.parse_string(FileAccess.get_file_as_string("res://assets/fantasy_trees/manifest.json"))
	assert(manifest.size() == 6)
	if "--configure-imports" in OS.get_cmdline_user_args():
		for entry: Dictionary in manifest:
			var config := ConfigFile.new()
			var config_path: String = "res://assets/fantasy_trees/" + entry.name + ".glb.import"
			assert(config.load(config_path) == OK)
			config.set_value("params", "import_script/path", "res://assets/fantasy_trees/import_tree.gd")
			assert(config.save(config_path) == OK)
		quit()
		return
	for entry: Dictionary in manifest:
		var path: String = "res://assets/fantasy_trees/" + entry.name
		var model := load(path + ".glb") as PackedScene
		assert(model != null)
		var tree := model.instantiate() as Node3D
		root.add_child(tree)
		var meshes := tree.find_children("*", "MeshInstance3D", true, false)
		assert(meshes.size() == 2, "Export must contain only trunk and canopy")
		var canopy: MeshInstance3D
		var trunk: MeshInstance3D
		for mesh: MeshInstance3D in meshes:
			var surface_mat := mesh.mesh.surface_get_material(0) as StandardMaterial3D
			assert(surface_mat.vertex_color_use_as_albedo, "Imported tree must display its vertex palette")
			if mesh.mesh.get_blend_shape_count() == 2:
				canopy = mesh
			else:
				trunk = mesh
		assert(canopy != null and trunk != null)
		var base_transform := trunk.transform
		var player := tree.find_child("AnimationPlayer", true, false) as AnimationPlayer
		assert(player != null)
		var checked := false
		for clip in player.get_animation_list():
			if clip == "RESET":
				continue
			var animation := player.get_animation(clip)
			print("CLIP ", clip, " length=", animation.length, " tracks=", animation.get_track_count())
			assert(is_equal_approx(animation.length, 4.0))
			for track in animation.get_track_count():
				assert(animation.track_get_type(track) == Animation.TYPE_BLEND_SHAPE)
				var count := animation.track_get_key_count(track)
				assert(is_equal_approx(float(animation.track_get_key_value(track, 0)), float(animation.track_get_key_value(track, count - 1))), "Wind must close without a jump")
			player.play(clip)
			player.seek(1.0, true)
			var first := canopy.get_blend_shape_value(0)
			player.seek(3.0, true)
			assert(absf(first - canopy.get_blend_shape_value(0)) > 1.5, "Morph animation must actually move")
			assert(trunk.transform == base_transform)
			checked = true
		assert(checked)
		tree.queue_free()
		var text := '[gd_scene load_steps=5 format=3]\n\n[ext_resource type="PackedScene" path="%s.glb" id="1"]\n[ext_resource type="Script" path="res://assets/fantasy_trees/tree_wind.gd" id="2"]\n\n[sub_resource type="CapsuleShape3D" id="Capsule"]\nradius = %s\nheight = 2.0\n\n[node name="%s" type="Node3D"]\nscript = ExtResource("2")\n\n[node name="Model" parent="." instance=ExtResource("1")]\n\n[node name="TrunkBody" type="StaticBody3D" parent="."]\n\n[node name="CollisionShape3D" type="CollisionShape3D" parent="TrunkBody"]\nposition = Vector3(0, 1, 0)\nshape = SubResource("Capsule")\n' % [path, entry.trunk_radius, entry.name]
		var file := FileAccess.open(path + ".tscn", FileAccess.WRITE)
		text = text.replace('script = ExtResource("2")', 'script = ExtResource("2")\ntree_height = %s\ncrown_width = %s\ncrown_depth = %s' % [entry.height, entry.width, entry.depth])
		file.store_string(text)
		file.close()
		var prefab := load(path + ".tscn") as PackedScene
		assert(prefab != null)
		var instance := prefab.instantiate()
		root.add_child(instance)
		var prefab_player := instance.find_child("AnimationPlayer", true, false) as AnimationPlayer
		assert(prefab_player.is_playing())
		assert(prefab_player.get_animation(prefab_player.current_animation).loop_mode == Animation.LOOP_LINEAR)
		var particles := instance.get_node("FallingLeaves") as CPUParticles3D
		assert(particles.emitting and particles.amount == 7)
		assert(is_equal_approx(particles.position.y, particles.lifetime * particles.initial_velocity_min))
		assert((instance.get_node("GroundLeaves") as MultiMeshInstance3D).multimesh.instance_count == 10)
		instance.queue_free()
		print("TREE_VALIDATED ", entry.name, " triangles=", entry.triangles, " loop=4s static_trunk=true")
	print("FANTASY_TREE_PACK_PASS six imports, six prefabs, closed moving canopy loops")
	quit()
