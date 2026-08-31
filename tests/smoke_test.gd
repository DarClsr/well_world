extends SceneTree


func _initialize() -> void:
	var scene := load("res://scenes/main.tscn") as PackedScene
	assert(scene != null)
	var main := scene.instantiate()
	root.add_child(main)
	await process_frame
	var player := main.get_node_or_null("Player") as CharacterBody3D
	assert(player != null)
	var visual := player.get_node("Visual") as Node3D
	for character_name in ["Ranger", "Cleric", "Warrior", "Monk"]:
		assert(ResourceLoader.exists("res://assets/quaternius/characters/%s.gltf" % character_name))
	var player_model := visual.get_node_or_null("CharacterModel") as Node3D
	assert(player_model != null)
	var player_animation := player_model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	assert(player_animation != null)
	for animation_name in ["Idle", "Walk", "Run"]:
		assert(player_animation.has_animation(animation_name))
	assert(player_animation.current_animation == "Idle")
	assert(player_animation.get_animation("Idle").loop_mode == Animation.LOOP_LINEAR)
	player.call("_update_walk_visual", 0.2, 1.0)
	assert(player_animation.current_animation == "Run")
	player.call("_update_walk_visual", 0.2, 0.0)
	assert(player_animation.current_animation == "Idle")
	assert(ResourceLoader.exists("res://assets/audio/footstep_1.ogg"))
	assert(ResourceLoader.exists("res://assets/audio/footstep_2.ogg"))
	var footsteps := player.get_node_or_null("Footsteps") as AudioStreamPlayer3D
	assert(footsteps != null)
	assert(is_equal_approx(footsteps.volume_db, -26.0))
	assert(is_equal_approx(footsteps.max_db, -26.0))
	var footstep_1 := load("res://assets/audio/footstep_1.ogg") as AudioStreamOggVorbis
	var footstep_2 := load("res://assets/audio/footstep_2.ogg") as AudioStreamOggVorbis
	assert(footstep_1 != null and not footstep_1.loop)
	assert(footstep_2 != null and not footstep_2.loop)
	assert(not footsteps.playing)
	player.set("walk_time", 0.0)
	player.set("footstep_index", 0)
	player.call("_update_walk_visual", 0.32, 0.0)
	assert(not footsteps.playing)
	player.call("_update_walk_visual", 0.32, 1.0)
	assert(footsteps.playing)
	assert(footsteps.stream == footstep_1)
	footsteps.stop()
	player.call("_update_walk_visual", 0.32, 1.0)
	assert(footsteps.playing)
	assert(footsteps.stream == footstep_2)
	assert(player.get("footstep_index") == 0)
	var camera := main.get_node_or_null("Player/CameraRig/Camera3D") as Camera3D
	assert(camera != null)
	var camera_rig := main.get_node_or_null("Player/CameraRig") as Node3D
	assert(camera_rig != null)
	var listener := main.get_node_or_null("Player/AudioListener3D") as AudioListener3D
	assert(listener != null)
	assert(listener.is_current())
	assert(camera.fov < 42.0)
	var camera_position := camera.position
	var listener_position := listener.position
	player.call("_update_camera_lead", 1.0 / 60.0, Vector3(7.0, 0.0, 0.0))
	assert(camera_rig.position.x > 0.0 and camera_rig.position.x < 1.6)
	assert(is_zero_approx(camera_rig.position.z))
	player.call("_update_camera_lead", 1.0, Vector3(7.0, 0.0, 0.0))
	assert(camera_rig.position.is_equal_approx(Vector3(1.6, 0.0, 0.0)))
	player.call("_update_camera_lead", 1.0, Vector3.ZERO)
	assert(camera_rig.position.is_zero_approx())
	assert(camera.position.is_equal_approx(camera_position))
	assert(listener.position.is_equal_approx(listener_position))
	var zoom_in := InputEventMouseButton.new()
	zoom_in.button_index = MOUSE_BUTTON_WHEEL_UP
	zoom_in.pressed = true
	player.call("_unhandled_input", zoom_in)
	assert(is_equal_approx(player.get("camera_target_height"), 13.5))
	player.call("_update_camera_zoom", 1.0)
	assert(is_equal_approx(camera.position.y, 13.5))
	assert(is_equal_approx(camera.position.z, 13.5 * 14.0 / 15.0))
	for index in 10:
		player.call("_unhandled_input", zoom_in)
	assert(is_equal_approx(player.get("camera_target_height"), 10.0))
	var zoom_out := InputEventMouseButton.new()
	zoom_out.button_index = MOUSE_BUTTON_WHEEL_DOWN
	zoom_out.pressed = true
	for index in 10:
		player.call("_unhandled_input", zoom_out)
	assert(is_equal_approx(player.get("camera_target_height"), 20.0))
	assert(main.get_node_or_null("ArrivalRing") is MeshInstance3D)
	assert(main.get_node_or_null("Opening") != null)
	assert(main.get_node_or_null("PortalPath") != null)
	assert(main.get_node("VillagePath") is CSGPolygon3D)
	assert(main.get_node("VillageSquare") is CSGPolygon3D)
	assert(main.get_node("PortalPath") is CSGPolygon3D)
	for track_name in ["NorthCartTrackLeft", "NorthCartTrackRight", "SouthCartTrackLeft", "SouthCartTrackRight"]:
		var cart_track := main.get_node_or_null(track_name) as CSGPolygon3D
		assert(cart_track != null)
		assert(not cart_track.use_collision)
		assert(is_equal_approx(cart_track.position.y, 0.12))
		assert(is_equal_approx(cart_track.depth, 0.01))
		assert(cart_track.material != main.get("path_material"))
	var ground_material := main.get("ground_material") as StandardMaterial3D
	var path_material := main.get("path_material") as StandardMaterial3D
	for surface_material in [ground_material, path_material]:
		assert(surface_material.albedo_texture is ImageTexture)
		var surface_image := (surface_material.albedo_texture as ImageTexture).get_image()
		assert(surface_image.get_width() == 64)
		assert(surface_image.get_height() == 64)
		assert(surface_image.has_mipmaps())
		assert(surface_image.get_pixel(0, 0).is_equal_approx(surface_image.get_pixel(63, 63)))
	assert(ground_material.uv1_scale.is_equal_approx(Vector3.ONE * 7.0))
	assert(path_material.uv1_scale.is_equal_approx(Vector3.ONE * 4.0))
	assert(main.get_node_or_null("PortalPlatform") != null)
	assert(main.get_node_or_null("PortalRuin") != null)
	assert(main.get_node("PortalRuin").get_child_count() >= 11)
	assert(main.get_node_or_null("VillageProps") != null)
	assert(main.get_node("VillageProps").get_child_count() >= 8)
	var herb_plot := main.get_node_or_null("HerbPlot") as Node3D
	assert(herb_plot != null)
	assert(herb_plot.position.is_equal_approx(Vector3(-4.0, 0.0, -10.8)))
	assert(herb_plot.get_child_count() == 10)
	for bed_part_name in ["Soil", "NorthEdge", "SouthEdge", "WestEdge", "EastEdge"]:
		var bed_part := herb_plot.get_node_or_null(bed_part_name) as CSGBox3D
		assert(bed_part != null)
		assert(not bed_part.use_collision)
	assert(main.get_node("GrassShadeWest") is MeshInstance3D)
	assert(main.get_node("GrassLightEast") is MeshInstance3D)
	for wear_name in ["VillageWearHearth", "VillageWearHerbs", "VillageWearWagon", "VillageWearEastDoor"]:
		var wear_patch := main.get_node_or_null(wear_name) as MeshInstance3D
		assert(wear_patch != null)
		assert(is_equal_approx(wear_patch.position.y, 0.12))
		assert(wear_patch.mesh is PlaneMesh)
		var wear_material := wear_patch.material_override as StandardMaterial3D
		assert(wear_material != null)
		assert(wear_material.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA)
		assert(wear_material.albedo_texture is GradientTexture2D)
		var wear_texture := wear_material.albedo_texture as GradientTexture2D
		assert(is_equal_approx(wear_texture.gradient.colors[0].a, 0.34))
	assert(main.get_node("NorthCliff") is CSGBox3D)
	assert(main.get_node("SouthCliff") is CSGBox3D)
	assert(main.get_node("WestCliff") is CSGBox3D)
	assert(main.get_node("EastCliff") is CSGBox3D)
	assert(main.get_node("BoundaryScenery").get_child_count() == 30)
	var fog_banks: Array = main.get("fog_banks")
	assert(fog_banks.size() == 6)
	assert(main.get("fog_bank_origins").size() == 6)
	for fog_index in range(6):
		var fog_bank := main.get_node_or_null("FogBank%d" % fog_index) as MeshInstance3D
		assert(fog_bank != null)
		assert(fog_bank.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	var pond := main.get_node_or_null("MistPond")
	assert(pond != null)
	assert(pond.get_node_or_null("Water") is MeshInstance3D)
	var pond_collision := pond.get_node_or_null("PondCollision") as CSGCylinder3D
	assert(pond_collision != null)
	assert(pond_collision.use_collision)
	assert(not pond_collision.visible)
	assert(pond.get_child_count() >= 17)
	assert(ResourceLoader.exists("res://assets/quaternius/village/Prop_Wagon.gltf"))
	assert(ResourceLoader.exists("res://assets/quaternius/village/Prop_Vine1.gltf"))
	assert(ResourceLoader.exists("res://assets/quaternius/village/Prop_Chimney.gltf"))
	assert(ResourceLoader.exists("res://assets/audio/mist_valley_ambience.ogg"))
	assert(ResourceLoader.exists("res://assets/audio/portal_hum.ogg"))
	assert(ResourceLoader.exists("res://assets/audio/portal_react.ogg"))
	assert(ResourceLoader.exists("res://assets/audio/hearth_fire.ogg"))
	var ambience := main.get_node_or_null("MistValleyAmbience") as AudioStreamPlayer
	var hearth_audio := main.get_node_or_null("HearthFire") as AudioStreamPlayer3D
	var portal_hum := main.get_node_or_null("PortalHum") as AudioStreamPlayer3D
	var portal_react := main.get_node_or_null("PortalReact") as AudioStreamPlayer3D
	assert(ambience != null)
	assert(hearth_audio != null)
	assert(portal_hum != null)
	assert(portal_react != null)
	assert((ambience.stream as AudioStreamOggVorbis).loop)
	assert((hearth_audio.stream as AudioStreamOggVorbis).loop)
	assert((portal_hum.stream as AudioStreamOggVorbis).loop)
	assert(not (portal_react.stream as AudioStreamOggVorbis).loop)
	assert(ambience.playing)
	assert(hearth_audio.playing)
	assert(portal_hum.playing)
	assert(not portal_react.playing)
	assert(portal_hum.position.distance_to(main.get("portal_center") + Vector3.UP * 1.8) < 0.01)
	assert(hearth_audio.position.distance_to((main.get_node("VillageHearth") as Node3D).position + Vector3.UP * 0.65) < 0.01)
	assert(is_equal_approx(hearth_audio.volume_db, -15.0))
	assert(is_equal_approx(hearth_audio.max_db, -20.0))
	assert(is_equal_approx(hearth_audio.unit_size, 2.5))
	assert(is_equal_approx(hearth_audio.max_distance, 14.0))
	assert(portal_react.position.distance_to(main.get("portal_center") + Vector3.UP * 1.8) < 0.01)
	for house_index in range(1, 4):
		var house := main.get_node_or_null("VillageHouse%d" % house_index)
		assert(house != null)
		assert(house.get_node_or_null("Roof") is Node3D)
		assert((house.get_node_or_null("HouseCollision") as CSGBox3D).use_collision)
		assert(house.get_node_or_null("WindowGlow") is OmniLight3D)
		assert(house.get_node_or_null("SmokePuff0") is MeshInstance3D)
	var house_fade_materials: Array = main.get("house_fade_materials")
	assert(not house_fade_materials.is_empty())
	assert(house_fade_materials.size() == main.get("house_fade_centers").size())
	var first_house_material := house_fade_materials[0] as StandardMaterial3D
	assert(first_house_material.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA)
	assert(is_equal_approx(first_house_material.albedo_color.a, 1.0))
	player.position = Vector3(-9.0, 1.0, -5.5)
	main.call("_process", 1.0)
	assert(first_house_material.albedo_color.a < 0.1)
	var second_house_index := (main.get("house_fade_centers") as Array).find(Vector3(9.0, 0.0, -8.0))
	assert(second_house_index >= 0)
	assert(is_equal_approx((house_fade_materials[second_house_index] as StandardMaterial3D).albedo_color.a, 1.0))
	player.position = Vector3(0.0, 1.0, 30.0)
	main.call("_process", 1.0)
	assert(first_house_material.albedo_color.a > 0.99)
	assert(main.get_node_or_null("RuinPillar") == null)
	assert(main.get_node_or_null("RuinLintel") == null)
	assert(main.get("portal_ring") != null)
	assert(main.get("portal_light") != null)
	assert(main.get("portal_motes").size() == 8)
	assert(InputMap.has_action("interact"))
	var prompt := main.get_node_or_null("PortalInteraction/PromptStack/PortalPrompt") as Label
	var lore := main.get_node_or_null("PortalInteraction/PromptStack/PortalLore") as Label
	assert(prompt != null)
	assert(lore != null)
	var wind_nodes: Array = main.get("wind_nodes")
	assert(wind_nodes.size() >= 15)
	var pond_ripples: Array = main.get("pond_ripples")
	assert(pond_ripples.size() == 2)
	var mistcap_caps: Array = main.get("mistcap_caps")
	var mistcap_lights: Array = main.get("mistcap_lights")
	assert(mistcap_caps.size() == 12)
	assert(mistcap_lights.size() == 4)
	for cluster_index in range(1, 5):
		var cluster := main.get_node_or_null("MistcapCluster%d" % cluster_index)
		assert(cluster != null)
		assert(cluster.get_child_count() == 7)
		assert(cluster.get_node_or_null("MistcapGlow") is OmniLight3D)
	var villager_visuals: Array = main.get("villager_visuals")
	var villager_labels: Array = main.get("villager_labels")
	assert(villager_visuals.size() == 3)
	assert(villager_labels.size() == 3)
	assert(main.get("villagers").size() == 3)
	for npc_data in [
		["HerbalistMira", "米拉", "药草师"],
		["GatekeeperToren", "托伦", "守门人"],
		["WeaverNia", "尼娅", "织工"],
	]:
		var npc_name: String = npc_data[0]
		var npc := main.get_node_or_null(npc_name) as CharacterBody3D
		assert(npc != null)
		assert(npc.get_node_or_null("CollisionShape3D") is CollisionShape3D)
		var identity_label := npc.get_node_or_null("IdentityLabel") as Label3D
		assert(identity_label != null)
		assert(identity_label.text.contains(npc_data[1]))
		assert(identity_label.text.contains(npc_data[2]))
		assert(identity_label.billboard == BaseMaterial3D.BILLBOARD_ENABLED)
		assert(not identity_label.fixed_size)
		assert(is_equal_approx(identity_label.pixel_size, 0.012))
		assert(not identity_label.visible)
		var npc_model := npc.get_node_or_null("Visual/CharacterModel") as Node3D
		assert(npc_model != null)
		var npc_animation := npc_model.find_child("AnimationPlayer", true, false) as AnimationPlayer
		assert(npc_animation != null)
		assert(npc_animation.has_animation("Idle"))
		assert(npc_animation.has_animation("Walk"))
		if npc.name == "HerbalistMira":
			assert(npc_animation.has_animation("PickUp"))
			assert(npc_animation.get_animation("PickUp").loop_mode == Animation.LOOP_NONE)
		assert(npc_animation.current_animation == "Walk")
		assert(npc_animation.get_animation("Idle").loop_mode == Animation.LOOP_LINEAR)
		assert(npc_animation.get_animation("Walk").loop_mode == Animation.LOOP_LINEAR)
	assert(main.get("villager_patrol_origins").size() == 3)
	assert(main.get("villager_patrol_axes").size() == 3)
	assert(main.get("villager_patrol_directions").size() == 3)
	assert(main.get("villager_patrol_pauses").size() == 3)
	assert(main.get("villager_animations").size() == 3)
	var patrol_npc := main.get_node("HerbalistMira") as CharacterBody3D
	patrol_npc.position = main.get("villager_patrol_origins")[0]
	main.get("villager_patrol_directions")[0] = 1.0
	main.get("villager_patrol_pauses")[0] = 0.0
	var patrol_start := patrol_npc.position
	player.position = Vector3(0.0, 1.0, 30.0)
	main.call("_process", 0.0)
	main.call("_physics_process", 1.0 / 60.0)
	assert(patrol_npc.position.distance_to(patrol_start) > 0.001)
	assert(Vector2(patrol_npc.velocity.x, patrol_npc.velocity.z).length() > 0.6)
	assert((main.get("villager_animations")[0] as AnimationPlayer).assigned_animation == "Walk")
	patrol_npc.position = (main.get("villager_patrol_origins")[0] as Vector3) + (main.get("villager_patrol_axes")[0] as Vector3) * 1.21
	main.call("_physics_process", 1.0 / 60.0)
	var mira_animation := main.get("villager_animations")[0] as AnimationPlayer
	var pickup_length := mira_animation.get_animation("PickUp").length
	var gathering_pause: float = main.get("villager_patrol_pauses")[0]
	assert(gathering_pause >= pickup_length)
	assert(Vector2(patrol_npc.velocity.x, patrol_npc.velocity.z).is_zero_approx())
	assert(mira_animation.assigned_animation == "PickUp")
	var mira_visual := patrol_npc.get_node("Visual") as Node3D
	main.call("_process", 1.0)
	var plot_direction := herb_plot.global_position - patrol_npc.global_position
	assert(absf(angle_difference(mira_visual.rotation.y, atan2(plot_direction.x, plot_direction.z))) < 0.001)
	var pause_position := patrol_npc.position
	main.call("_physics_process", 0.5)
	assert(patrol_npc.position.distance_to(pause_position) < 0.01)
	assert(main.get("villager_patrol_pauses")[0] < gathering_pause)
	main.call("_physics_process", gathering_pause + 0.1)
	main.call("_physics_process", 1.0 / 60.0)
	assert(mira_animation.assigned_animation == "Walk")
	assert(main.get("villager_patrol_directions")[0] < 0.0)
	patrol_npc.position = (main.get("villager_patrol_origins")[0] as Vector3) - (main.get("villager_patrol_axes")[0] as Vector3) * 1.21
	main.get("villager_patrol_pauses")[0] = 0.0
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("villager_patrol_directions")[0] > 0.0)
	assert(mira_animation.assigned_animation == "Idle")
	main.get("villager_patrol_directions")[0] = -1.0
	main.get("villager_patrol_pauses")[0] = pickup_length
	player.position = patrol_npc.position + Vector3(0.0, 1.0, 2.0)
	main.call("_process", 0.0)
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("nearby_villager") == patrol_npc)
	assert(mira_animation.assigned_animation == "Idle")
	var identity_npc := main.get_node("WeaverNia") as CharacterBody3D
	var identity_label := identity_npc.get_node("IdentityLabel") as Label3D
	player.position = identity_npc.position + Vector3(0.0, 1.0, 5.0)
	main.call("_process", 1.0)
	assert(identity_label.visible)
	assert(identity_label.modulate.a > 0.9)
	assert(main.get("nearby_villager") == null)
	player.position = Vector3(0.0, 1.0, 30.0)
	main.call("_process", 1.0)
	assert(not identity_label.visible)
	var smoke_puffs: Array = main.get("smoke_puffs")
	assert(smoke_puffs.size() == 12)
	assert(main.get("smoke_origins").size() == 12)
	var hearth := main.get_node_or_null("VillageHearth")
	assert(hearth != null)
	assert(hearth.get_node_or_null("FireEmber") is CSGCylinder3D)
	assert(hearth.get_node_or_null("HearthLight") is OmniLight3D)
	assert(main.get("hearth_flames").size() == 3)
	var first_mote: MeshInstance3D = main.get("portal_motes")[0]
	var mote_position := first_mote.position
	var first_plant := wind_nodes[0] as Node3D
	var plant_rotation := first_plant.rotation
	var first_puff := smoke_puffs[0] as MeshInstance3D
	var puff_position := first_puff.position
	var puff_transparency := first_puff.transparency
	var first_flame := main.get("hearth_flames")[0] as MeshInstance3D
	var flame_position := first_flame.position
	var hearth_energy := (main.get("hearth_light") as OmniLight3D).light_energy
	var first_ripple := pond_ripples[0] as MeshInstance3D
	var ripple_scale := first_ripple.scale
	var ripple_transparency := first_ripple.transparency
	var first_villager := villager_visuals[0] as Node3D
	var villager_position := first_villager.position
	var mistcap_energy: float = main.get("mistcap_material").emission_energy_multiplier
	var first_mistcap_light := mistcap_lights[0] as OmniLight3D
	var mistcap_light_energy := first_mistcap_light.light_energy
	var first_fog := fog_banks[0] as MeshInstance3D
	var fog_position := first_fog.position
	var fog_transparency := first_fog.transparency
	main.call("_process", 0.5)
	assert(first_mote.position.distance_to(mote_position) > 0.01)
	assert(first_plant.rotation.distance_to(plant_rotation) > 0.001)
	assert(first_puff.position.distance_to(puff_position) > 0.01)
	assert(not is_equal_approx(first_puff.transparency, puff_transparency))
	assert(first_flame.position.distance_to(flame_position) > 0.01)
	assert(not is_equal_approx((main.get("hearth_light") as OmniLight3D).light_energy, hearth_energy))
	assert(first_ripple.scale.distance_to(ripple_scale) > 0.01)
	assert(not is_equal_approx(first_ripple.transparency, ripple_transparency))
	assert(first_villager.position.distance_to(villager_position) > 0.001)
	assert(not is_equal_approx(main.get("mistcap_material").emission_energy_multiplier, mistcap_energy))
	assert(not is_equal_approx(first_mistcap_light.light_energy, mistcap_light_energy))
	assert(first_fog.position.distance_to(fog_position) > 0.001)
	assert(not is_equal_approx(first_fog.transparency, fog_transparency))
	for dialogue_data in [
		["HerbalistMira", "米拉"],
		["GatekeeperToren", "托伦"],
		["WeaverNia", "尼娅"],
	]:
		var dialogue_npc := main.get_node(dialogue_data[0]) as CharacterBody3D
		player.position = dialogue_npc.position + Vector3(0.0, 1.0, 2.0)
		lore.hide()
		main.call("_process", 0.0)
		assert(main.get("nearby_villager") == dialogue_npc)
		assert(prompt.visible)
		assert(prompt.text.contains(dialogue_data[1]))
		main.call("_show_villager_dialogue")
		assert(lore.visible)
		assert(lore.text.contains(dialogue_data[1]))
		assert(not prompt.visible)
	var facing_npc := main.get_node("WeaverNia") as CharacterBody3D
	var facing_visual := facing_npc.get_node("Visual") as Node3D
	player.position = facing_npc.position + Vector3(2.0, 1.0, 0.0)
	lore.hide()
	var target_yaw := PI * 0.5
	var angle_before := absf(angle_difference(facing_visual.rotation.y, target_yaw))
	main.call("_process", 0.2)
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("nearby_villager") == facing_npc)
	assert(absf(angle_difference(facing_visual.rotation.y, target_yaw)) < angle_before)
	assert(Vector2(facing_npc.velocity.x, facing_npc.velocity.z).is_zero_approx())
	assert((main.get("villager_animations")[2] as AnimationPlayer).assigned_animation == "Idle")
	player.position = Vector3(0.0, 1.0, 30.0)
	main.call("_process", 0.5)
	main.call("_physics_process", 1.0 / 60.0)
	main.call("_process", 0.5)
	assert(main.get("nearby_villager") == null)
	var patrol_yaw := atan2(facing_npc.velocity.x, facing_npc.velocity.z)
	assert(absf(angle_difference(facing_visual.rotation.y, patrol_yaw)) < 0.05)
	lore.hide()
	var portal_light := main.get("portal_light") as OmniLight3D
	var far_energy := portal_light.light_energy
	var far_hum_volume := portal_hum.volume_db
	var portal_center: Vector3 = main.get("portal_center")
	player.position = portal_center + Vector3(0.0, 1.0, 3.5)
	main.call("_process", 0.0)
	assert(main.get("portal_nearby"))
	assert(prompt.visible)
	assert(portal_light.light_energy > far_energy)
	assert(portal_hum.volume_db > far_hum_volume)
	var near_ring_scale := (main.get("portal_ring") as Node3D).scale.x
	var near_light_energy := portal_light.light_energy
	main.call("_show_portal_lore")
	assert(portal_react.playing)
	assert(is_equal_approx(main.get("portal_reaction_time"), 1.0))
	main.call("_process", 0.0)
	assert((main.get("portal_ring") as Node3D).scale.x > near_ring_scale)
	assert(portal_light.light_energy > near_light_energy)
	main.call("_process", 0.25)
	assert(main.get("portal_reaction_time") < 1.0)
	assert(lore.visible)
	assert(lore.text.contains("异界气息"))
	assert(not prompt.visible)
	assert(main.get_child_count() > 20)
	print("SMOKE TEST PASSED")
	quit(0)
