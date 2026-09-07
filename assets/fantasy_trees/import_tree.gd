@tool
extends EditorScenePostImport


func _post_import(scene: Node) -> Object:
	for mesh: MeshInstance3D in scene.find_children("*", "MeshInstance3D", true, false):
		for surface in mesh.mesh.get_surface_count():
			var material := mesh.mesh.surface_get_material(surface) as StandardMaterial3D
			material.vertex_color_use_as_albedo = true
			material.vertex_color_is_srgb = false
	var player := scene.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if player:
		for clip in player.get_animation_list():
			if clip != "RESET":
				player.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
	return scene
