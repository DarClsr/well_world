extends SceneTree


func _initialize() -> void:
	call_deferred("_inspect")


func _inspect() -> void:
	for character_name in ["Ranger", "Cleric", "Warrior", "Monk"]:
		var path := "res://assets/quaternius/characters/%s.gltf" % character_name
		var scene := load(path) as PackedScene
		assert(scene != null)
		var character := scene.instantiate() as Node3D
		root.add_child(character)
		await process_frame
		var animation_players := character.find_children("*", "AnimationPlayer", true, false)
		var animation_names: PackedStringArray = []
		for animation_player in animation_players:
			animation_names.append_array((animation_player as AnimationPlayer).get_animation_list())
		var bounds := AABB()
		var has_bounds := false
		for mesh_node in character.find_children("*", "MeshInstance3D", true, false):
			var mesh_instance := mesh_node as MeshInstance3D
			var mesh_bounds: AABB = mesh_instance.global_transform * mesh_instance.get_aabb()
			bounds = bounds.merge(mesh_bounds) if has_bounds else mesh_bounds
			has_bounds = true
		print(character_name, " root=", character.name, " animation_players=", animation_players.size(), " animations=", animation_names, " bounds=", bounds)
		character.free()
	print("CHARACTER ASSET INSPECTION PASSED")
	quit()
