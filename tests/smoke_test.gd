extends SceneTree


func _initialize() -> void:
	assert(WorldState.from_dictionary({"version": 1, "flags": null}) == null)
	var scene := load("res://scenes/main.tscn") as PackedScene
	assert(scene != null)
	var main := scene.instantiate()
	main.set("time_hour", 9.5)
	main.set("time_running", false)
	main.set("weather_seed", 20260902)
	main.set("weather_override", "clear")
	main.set("weather_running", false)
	root.add_child(main)
	await process_frame
	var player := main.get_node_or_null("Player") as CharacterBody3D
	assert(player != null)
	assert(is_equal_approx(main.get("time_hour"), 9.5))
	assert(not main.get("time_running"))
	var environment_settings := main.get("environment_settings") as Environment
	var sun := main.get_node_or_null("Sun") as DirectionalLight3D
	assert(environment_settings != null)
	assert(main.get_node_or_null("WorldEnvironment") is WorldEnvironment)
	assert(sun != null and sun.shadow_enabled)
	assert(sun.directional_shadow_mode == DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS)
	assert(is_equal_approx(sun.directional_shadow_max_distance, 55.0))
	assert(is_equal_approx(sun.shadow_blur, 1.4))
	var day_keys: Array = main.get("day_keys")
	assert(day_keys.size() == 11)
	for day_key in day_keys:
		assert((day_key[6] as float) >= 0.35)
		assert((day_key[10] as float) >= 0.2 and (day_key[10] as float) <= 0.6)
	var midnight_sample := main.call("_sample_day", 0.0) as Dictionary
	var noon_sample := main.call("_sample_day", 12.0) as Dictionary
	assert((midnight_sample["amb_energy"] as float) >= 0.35)
	assert((noon_sample["sun_energy"] as float) > (midnight_sample["sun_energy"] as float))
	var before_midnight := main.call("_sample_day", 23.99) as Dictionary
	var after_midnight := main.call("_sample_day", 0.01) as Dictionary
	assert(absf((before_midnight["sun_energy"] as float) - (after_midnight["sun_energy"] as float)) < 0.01)
	var before_angle := deg_to_rad(before_midnight["azim"] as float)
	var after_angle := deg_to_rad(after_midnight["azim"] as float)
	assert(Vector2(cos(before_angle), sin(before_angle)).distance_to(Vector2(cos(after_angle), sin(after_angle))) < 0.03)
	main.set("time_running", true)
	main.call("_process", 1.0)
	assert(is_equal_approx(main.get("time_hour"), 9.5 + 24.0 / 1800.0))
	main.set("time_running", false)
	main.set("time_hour", 0.0)
	main.call("_process", 0.0)
	var night_hearth_energy := (main.get("hearth_light") as OmniLight3D).light_energy
	var night_window_energy := (main.get("window_glows")[0] as OmniLight3D).light_energy
	var night_portal_energy := (main.get("portal_light") as OmniLight3D).light_energy
	var night_mistcap_energy := (main.get("mistcap_lights")[0] as OmniLight3D).light_energy
	var night_player_fill_energy := (main.get("player_fill_light") as SpotLight3D).light_energy
	assert(environment_settings.ambient_light_energy >= 0.35)
	assert(sun.light_color.b > sun.light_color.r)
	main.set("time_hour", 12.0)
	main.set("portal_time", 0.0)
	main.call("_process", 0.0)
	assert(night_hearth_energy > (main.get("hearth_light") as OmniLight3D).light_energy)
	assert(night_window_energy > (main.get("window_glows")[0] as OmniLight3D).light_energy)
	assert(night_portal_energy > (main.get("portal_light") as OmniLight3D).light_energy)
	assert(night_mistcap_energy > (main.get("mistcap_lights")[0] as OmniLight3D).light_energy)
	assert((main.get("portal_surface_material") as ShaderMaterial).get_shader_parameter("time_glow") < 1.0)
	var player_fill := main.get("player_fill_light") as SpotLight3D
	assert(player_fill != null and not player_fill.shadow_enabled)
	assert(player_fill.light_cull_mask == 2)
	assert(is_equal_approx(player_fill.spot_range, 35.0))
	assert(night_player_fill_energy > player_fill.light_energy)
	main.set("time_hour", 9.5)
	main.call("_process", 0.0)
	assert(sun.rotation_degrees.is_equal_approx(Vector3(-52.0, -28.0, 0.0)))
	assert(is_equal_approx(sun.shadow_opacity, 0.58))
	assert(environment_settings.background_color.is_equal_approx(Color("839da3")))
	(main.get("portal_surface_material") as ShaderMaterial).set_shader_parameter("reaction_strength", 0.0)
	var weather_schedule: Array = main.get("weather_schedule")
	assert(weather_schedule.size() == 13)
	assert(weather_schedule == main.call("_make_weather_schedule", 20260902))
	assert(weather_schedule == main.call("_make_weather_schedule", 20260902))
	var weather_counts := {"clear": 0, "cloudy": 0, "mist": 0, "light_rain": 0}
	for index in weather_schedule.size():
		var segment: Dictionary = weather_schedule[index]
		assert(segment["state"] in weather_counts)
		weather_counts[segment["state"]] += 1
		var duration_range := main.call("_weather_duration_range", segment["state"] as String) as Vector2
		assert((segment["duration"] as float) >= duration_range.x)
		assert((segment["duration"] as float) <= duration_range.y)
		if index > 0:
			assert(segment["state"] != weather_schedule[index - 1]["state"])
	assert(weather_schedule[-1]["state"] != weather_schedule[0]["state"])
	for state in weather_counts:
		assert(weather_counts[state] >= 3)
	var rain_field := main.get_node_or_null("LightRain") as Node3D
	assert(rain_field != null and rain_field.get_child_count() == 28)
	assert(rain_field.get_meta("weather_seed") == 20260902)
	assert(rain_field.get_meta("rain_seed") == 20261603)
	assert(main.get("rain_params").size() == 28)
	var rain_material := main.get("rain_material") as StandardMaterial3D
	assert(rain_material != null and rain_material.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA)
	assert(((rain_field.get_child(0) as MeshInstance3D).mesh as QuadMesh).size == Vector2(0.025, 0.55))
	for streak in rain_field.get_children():
		assert((streak as MeshInstance3D).material_override == rain_material)
		assert((streak as MeshInstance3D).cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	var clear_sun_energy := sun.light_energy
	var clear_fog_density := environment_settings.fog_density
	var clear_ground_color := (main.get("ground_material") as StandardMaterial3D).albedo_color
	var clear_ground_roughness := (main.get("ground_material") as StandardMaterial3D).roughness
	var clear_path_color := (main.get("path_material") as StandardMaterial3D).albedo_color
	var clear_path_roughness := (main.get("path_material") as StandardMaterial3D).roughness
	var clear_pond_roughness := (main.get("pond_water_material") as StandardMaterial3D).roughness
	main.set("portal_time", 2.75)
	main.call("_process", 0.0)
	var clear_hearth_energy := (main.get("hearth_light") as OmniLight3D).light_energy
	var clear_hearth_flame_emission := (main.get("hearth_flame_material") as StandardMaterial3D).emission_energy_multiplier
	var clear_hearth_ember_emission := (main.get("hearth_ember_material") as StandardMaterial3D).emission_energy_multiplier
	var clear_hearth_flame_scale := ((main.get("hearth_flames") as Array)[0] as CSGPolygon3D).scale
	var clear_hearth_flame_position := ((main.get("hearth_flames") as Array)[0] as CSGPolygon3D).position
	var clear_hearth_smoke := (main.get("smoke_puffs") as Array)[9] as MeshInstance3D
	var clear_hearth_smoke_position := clear_hearth_smoke.position
	var clear_hearth_smoke_transparency := clear_hearth_smoke.transparency
	var clear_house_smoke := (main.get("smoke_puffs") as Array)[0] as MeshInstance3D
	var clear_house_smoke_position := clear_house_smoke.position
	var clear_house_smoke_transparency := clear_house_smoke.transparency
	var clear_portal_energy := (main.get("portal_light") as OmniLight3D).light_energy
	main.set("weather_override", "cloudy")
	main.call("_process", 0.0)
	var cloudy_sun_energy := sun.light_energy
	var cloudy_fog_density := environment_settings.fog_density
	assert(cloudy_sun_energy < clear_sun_energy)
	assert(cloudy_fog_density > clear_fog_density)
	assert(environment_settings.ambient_light_energy >= 0.35)
	assert(not rain_field.visible)
	main.set("weather_override", "mist")
	main.call("_process", 0.0)
	assert(environment_settings.fog_density > cloudy_fog_density)
	assert(not rain_field.visible)
	main.set("weather_override", "light_rain")
	main.call("_process", 0.0)
	assert(sun.light_energy < cloudy_sun_energy)
	assert(environment_settings.fog_density > clear_fog_density)
	assert(environment_settings.ambient_light_energy >= 0.35)
	assert(rain_field.visible and rain_material.albedo_color.a > 0.25)
	assert(is_equal_approx(main.get("weather_surface_wetness"), 0.78))
	var rain_ground_material := main.get("ground_material") as StandardMaterial3D
	var rain_path_material := main.get("path_material") as StandardMaterial3D
	var rain_pond_material := main.get("pond_water_material") as StandardMaterial3D
	assert(rain_ground_material.albedo_color.get_luminance() < clear_ground_color.get_luminance())
	assert(rain_ground_material.roughness < clear_ground_roughness)
	assert(rain_path_material.albedo_color.get_luminance() < clear_path_color.get_luminance())
	assert(rain_path_material.roughness < clear_path_roughness)
	assert(rain_pond_material.roughness > clear_pond_roughness)
	var rain_hearth_energy := (main.get("hearth_light") as OmniLight3D).light_energy
	var rain_hearth_flame_emission := (main.get("hearth_flame_material") as StandardMaterial3D).emission_energy_multiplier
	var rain_hearth_ember_emission := (main.get("hearth_ember_material") as StandardMaterial3D).emission_energy_multiplier
	var rain_hearth_flame := (main.get("hearth_flames") as Array)[0] as CSGPolygon3D
	assert(rain_hearth_energy < clear_hearth_energy and rain_hearth_energy > clear_hearth_energy * 0.9)
	assert(rain_hearth_flame_emission < clear_hearth_flame_emission and rain_hearth_flame_emission > clear_hearth_flame_emission * 0.93)
	assert(rain_hearth_ember_emission < clear_hearth_ember_emission and rain_hearth_ember_emission > clear_hearth_ember_emission * 0.95)
	assert(rain_hearth_flame.scale.y < clear_hearth_flame_scale.y and rain_hearth_flame.scale.y > clear_hearth_flame_scale.y * 0.87)
	assert(rain_hearth_flame.position.distance_to(main.get("hearth_flame_origins")[0]) < clear_hearth_flame_position.distance_to(main.get("hearth_flame_origins")[0]))
	assert(clear_hearth_smoke.transparency > clear_hearth_smoke_transparency)
	assert(Vector2(clear_hearth_smoke.position.x, clear_hearth_smoke.position.z).length() > Vector2(clear_hearth_smoke_position.x, clear_hearth_smoke_position.z).length())
	assert(clear_house_smoke.position.is_equal_approx(clear_house_smoke_position))
	assert(is_equal_approx(clear_house_smoke.transparency, clear_house_smoke_transparency))
	assert(is_equal_approx((main.get("portal_light") as OmniLight3D).light_energy, clear_portal_energy))
	var rain_position := (rain_field.get_child(0) as Node3D).position
	main.set("portal_time", 1.0)
	main.call("_animate_weather")
	assert(not (rain_field.get_child(0) as Node3D).position.is_equal_approx(rain_position))
	var shelter_house := main.get_node("VillageHouse1") as Node3D
	var shelter_streak := rain_field.get_child(0) as MeshInstance3D
	var shelter_params: Dictionary = (main.get("rain_params") as Array)[0]
	var original_shelter_params := shelter_params.duplicate()
	var original_rain_player_position := player.position
	main.set("portal_time", 0.0)
	player.position = shelter_house.position
	shelter_params["x"] = 0.0
	shelter_params["z"] = 0.0
	shelter_params["phase"] = 0.0
	main.call("_animate_weather")
	assert(shelter_streak.transparency > 0.99)
	shelter_params["x"] = 6.0
	main.call("_animate_weather")
	assert(is_zero_approx(shelter_streak.transparency))
	var shelter_edge_world := shelter_house.to_global(Vector3(2.9, 2.0, 0.0))
	shelter_params["x"] = shelter_edge_world.x - player.position.x
	shelter_params["z"] = shelter_edge_world.z - player.position.z
	main.call("_animate_weather")
	assert(shelter_streak.transparency > 0.0 and shelter_streak.transparency < 1.0)
	shelter_params.assign(original_shelter_params)
	player.position = original_rain_player_position
	var original_schedule := weather_schedule.duplicate(true)
	main.set("weather_schedule", [{"state": "clear", "duration": 5.0}, {"state": "light_rain", "duration": 4.0}])
	main.set("weather_schedule_index", 0)
	main.set("weather_segment_elapsed", 4.625)
	main.set("weather_override", "")
	var half_transition := main.call("_sample_weather") as Dictionary
	assert(is_equal_approx(main.get("weather_blend"), 0.5))
	assert(is_equal_approx(half_transition["rain"] as float, 0.5))
	main.set("weather_running", true)
	main.set("weather_segment_elapsed", 4.9)
	main.call("_update_weather", 15.0)
	assert(main.get("weather_schedule_index") == 1)
	assert(is_equal_approx(main.get("weather_segment_elapsed"), 0.1))
	main.set("weather_schedule", original_schedule)
	main.set("weather_schedule_index", 0)
	main.set("weather_segment_elapsed", 0.0)
	main.set("weather_running", false)
	main.set("weather_override", "clear")
	main.set("portal_time", 0.0)
	main.call("_process", 0.0)
	var butterflies := main.get_node_or_null("Butterflies") as Node3D
	var fireflies := main.get_node_or_null("Fireflies") as Node3D
	assert(butterflies != null and butterflies.get_child_count() == 7)
	assert(fireflies != null and fireflies.get_child_count() == 14)
	assert(butterflies.get_meta("seed") == 3131)
	assert(fireflies.get_meta("seed") == 6262)
	assert(butterflies.get_meta("active_hours") == Vector2(7.0, 19.0))
	assert(fireflies.get_meta("active_hours") == Vector2(19.5, 5.5))
	var butterfly_material := main.get("butterfly_material") as StandardMaterial3D
	var firefly_material := main.get("firefly_material") as StandardMaterial3D
	assert(butterfly_material != null and firefly_material != null)
	assert(butterfly_material.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA)
	assert(firefly_material.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA)
	assert(butterfly_material.albedo_texture.get_image().get_size() == Vector2i(32, 32))
	assert(firefly_material.albedo_texture.get_image().get_size() == Vector2i(32, 32))
	assert(((butterflies.get_child(0) as MeshInstance3D).mesh as QuadMesh).size == Vector2(0.32, 0.22))
	assert(((fireflies.get_child(0) as MeshInstance3D).mesh as QuadMesh).size == Vector2(0.12, 0.12))
	var ecology_portal_center: Vector3 = main.get("portal_center")
	for fly in butterflies.get_children():
		assert((fly as MeshInstance3D).material_override == butterfly_material)
		var params: Dictionary = fly.get_meta("params")
		var home: Vector2 = params["home"]
		var radius := maxf(params["radius_x"] as float, params["radius_z"] as float)
		assert(absf(home.x) > 4.0 and home.y > -18.0 and home.y < 0.0)
		assert((main.call("_meadow_road_edge_distance", home) as float) > radius + 0.8)
		assert(home.distance_to(Vector2(4.3, -5.5)) > radius + 3.25)
		assert(home.distance_to(Vector2(-14.8, -10.0)) > radius + 2.7)
		for house_center in [Vector2(-9.0, -10.0), Vector2(9.0, -8.0), Vector2(-10.0, 5.0)]:
			assert(absf(home.x - house_center.x) > radius + 3.45 or absf(home.y - house_center.y) > radius + 3.45)
	for fly in fireflies.get_children():
		assert((fly as MeshInstance3D).material_override == firefly_material)
		var params: Dictionary = fly.get_meta("params")
		var home: Vector2 = params["home"]
		var radius := maxf(params["radius_x"] as float, params["radius_z"] as float)
		assert(absf(home.x) > 12.0)
		assert((main.call("_meadow_road_edge_distance", home) as float) > radius + 3.0)
		assert(home.distance_to(Vector2(4.3, -5.5)) > radius + 3.25)
		assert(home.distance_to(Vector2(ecology_portal_center.x, ecology_portal_center.z)) > radius + 4.8)
	assert(is_zero_approx(main.call("_butterfly_alpha", 7.0) as float))
	assert(is_equal_approx(main.call("_butterfly_alpha", 8.0) as float, 1.0))
	assert(is_equal_approx(main.call("_butterfly_alpha", 18.0) as float, 1.0))
	assert(is_zero_approx(main.call("_butterfly_alpha", 19.0) as float))
	assert(is_zero_approx(main.call("_firefly_alpha", 19.5) as float))
	assert(is_equal_approx(main.call("_firefly_alpha", 20.5) as float, 1.0))
	assert(is_equal_approx(main.call("_firefly_alpha", 4.5) as float, 1.0))
	assert(is_zero_approx(main.call("_firefly_alpha", 5.5) as float))
	assert(absf((main.call("_butterfly_alpha", 7.01) as float) - (main.call("_butterfly_alpha", 6.99) as float)) < 0.001)
	assert(absf((main.call("_firefly_alpha", 19.51) as float) - (main.call("_firefly_alpha", 19.49) as float)) < 0.001)
	main.set("time_hour", 12.0)
	main.call("_process", 0.0)
	assert(butterflies.visible and not fireflies.visible)
	assert(butterfly_material.albedo_color.a > 0.99 and firefly_material.albedo_color.a < 0.01)
	assert(butterfly_material.albedo_color.r > butterfly_material.albedo_color.g)
	assert(butterfly_material.albedo_color.g > butterfly_material.albedo_color.b)
	main.set("weather_rain_amount", 0.5)
	main.call("_animate_ecosystem")
	assert(butterflies.visible)
	assert(is_equal_approx(butterfly_material.albedo_color.a, 0.5))
	assert(firefly_material.albedo_color.a < 0.01)
	main.set("weather_override", "light_rain")
	main.call("_process", 0.0)
	assert(is_equal_approx(main.get("weather_rain_amount"), 1.0))
	assert(not butterflies.visible)
	assert(butterfly_material.albedo_color.a < 0.01)
	assert(not fireflies.visible)
	main.set("weather_override", "clear")
	main.call("_process", 0.0)
	assert(butterflies.visible and butterfly_material.albedo_color.a > 0.99)
	var butterfly_position := (butterflies.get_child(0) as Node3D).position
	main.set("portal_time", 1.0)
	main.call("_animate_ecosystem")
	assert(not (butterflies.get_child(0) as Node3D).position.is_equal_approx(butterfly_position))
	main.set("time_hour", 22.0)
	main.call("_process", 0.0)
	assert(not butterflies.visible and fireflies.visible)
	assert(butterfly_material.albedo_color.a < 0.01 and firefly_material.albedo_color.a > 0.99)
	assert(firefly_material.albedo_color.g > firefly_material.albedo_color.r)
	main.set("portal_time", 0.0)
	main.set("time_hour", 9.5)
	main.call("_process", 0.0)
	(main.get("portal_surface_material") as ShaderMaterial).set_shader_parameter("reaction_strength", 0.0)
	var initial_portal_center: Vector3 = main.get("portal_center")
	var expected_spawn := Vector2(initial_portal_center.x, initial_portal_center.z + 3.0)
	assert(
		Vector2(player.position.x, player.position.z).distance_to(expected_spawn) < 0.25,
		"Unexpected portal spawn: player=%s portal=%s" % [player.position, initial_portal_center]
	)
	var visual := player.get_node("Visual") as Node3D
	for character_name in ["Ranger", "Cleric", "Warrior", "Monk"]:
		assert(ResourceLoader.exists("res://assets/quaternius/characters/%s.gltf" % character_name))
	var player_model := visual.get_node_or_null("CharacterModel") as Node3D
	assert(player_model != null)
	assert(player_model.get_node_or_null("RiggedModel") is Node3D)
	assert(player_model.get_node_or_null("AnimationPlayer") is AnimationPlayer)
	assert(player_model.position.is_equal_approx(Vector3.ZERO))
	assert(player_model.scale.is_equal_approx(Vector3.ONE * 0.78))
	var player_collider := player.get_node("CollisionShape3D") as CollisionShape3D
	assert(player_collider.position.is_equal_approx(Vector3(0.0, 0.8, 0.0)))
	var player_capsule := player_collider.shape as CapsuleShape3D
	assert(is_equal_approx(player_capsule.radius, 0.38))
	assert(is_equal_approx(player_capsule.height, 1.6))
	var player_skeleton := player_model.find_child("Skeleton3D", true, false) as Skeleton3D
	assert(player_skeleton != null and player_skeleton.get_bone_count() == 23)
	var player_visual_height := _visual_height(player_model)
	assert(player_visual_height >= 1.65 and player_visual_height <= 1.75)
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
	player.call("_update_camera_lead", 1.0, Vector3(0.1, 0.0, 0.0))
	assert(camera_rig.position.is_zero_approx())
	player.call("_update_camera_lead", 1.0, Vector3(3.5, 0.0, 0.0))
	assert(camera_rig.position.is_equal_approx(Vector3(0.8, 0.0, 0.0)))
	camera_rig.position = Vector3.ZERO
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
	var village_path := main.get_node("VillagePath") as MeshInstance3D
	var portal_path := main.get_node("PortalPath") as MeshInstance3D
	var pond_path := main.get_node("PondPath") as MeshInstance3D
	for road in [village_path, portal_path, pond_path]:
		assert(road.mesh is ArrayMesh and road.mesh.get_surface_count() == 1)
		assert(road.get_node_or_null("Shoulder") is MeshInstance3D)
		var road_arrays: Array = road.mesh.surface_get_arrays(0)
		var road_vertices := road_arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
		var road_colors := road_arrays[Mesh.ARRAY_COLOR] as PackedColorArray
		assert(road_vertices.size() % 3 == 0 and road_colors.size() == road_vertices.size())
		for vertex_index in range(0, road_vertices.size(), 3):
			var left_color := road_colors[vertex_index]
			var center_color := road_colors[vertex_index + 1]
			var right_color := road_colors[vertex_index + 2]
			assert(left_color.r == 1.0 and left_color.g == 1.0 and left_color.b == 1.0)
			assert(center_color.r >= 0.928 and center_color.r <= 0.932)
			assert(center_color.g >= 0.928 and center_color.g <= 0.932)
			assert(center_color.b >= 0.928 and center_color.b <= 0.932)
			assert(is_equal_approx(center_color.a, left_color.a))
			assert(right_color.r == 1.0 and right_color.g == 1.0 and right_color.b == 1.0)
			assert(is_equal_approx(right_color.a, left_color.a))
	var village_path_vertices: PackedVector3Array = village_path.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	var village_path_min_width := INF
	var village_path_max_width := 0.0
	for vertex_index in range(0, village_path_vertices.size(), 3):
		var cross_section_width := village_path_vertices[vertex_index].distance_to(village_path_vertices[vertex_index + 2])
		village_path_min_width = minf(village_path_min_width, cross_section_width)
		village_path_max_width = maxf(village_path_max_width, cross_section_width)
	assert(is_equal_approx(village_path_min_width, 2.24))
	assert(is_equal_approx(village_path_max_width, 4.2))
	var village_core_x := PackedFloat32Array([0.1, -0.78, -0.2, 0.78, 0.1])
	var village_core_widths := PackedFloat32Array([2.5, 2.4, 2.24, 2.56, 3.4])
	for core_index in village_core_x.size():
		var vertex_index := (core_index + 3) * 15
		var left := village_path_vertices[vertex_index]
		var center := village_path_vertices[vertex_index + 1]
		var right := village_path_vertices[vertex_index + 2]
		assert(is_equal_approx(center.x, village_core_x[core_index]))
		assert(is_equal_approx(left.distance_to(right), village_core_widths[core_index]))
	assert(village_core_x[1] < -0.75 and village_core_x[3] > 0.75)
	assert(main.get_node_or_null("VillageSquare") == null)
	for lane_name in ["VillageWestLane", "VillageHearthLane", "VillageWagonLane", "VillageSouthLane"]:
		var lane := main.get_node_or_null(lane_name) as MeshInstance3D
		assert(lane != null and lane.mesh is ArrayMesh)
		assert(lane.get_node_or_null("Shoulder") is MeshInstance3D)
	var village_west_vertices := (main.get_node("VillageWestLane") as MeshInstance3D).mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var village_hearth_vertices := (main.get_node("VillageHearthLane") as MeshInstance3D).mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var village_wagon_vertices := (main.get_node("VillageWagonLane") as MeshInstance3D).mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array
	assert(Vector2(village_west_vertices[1].x, village_west_vertices[1].z).is_equal_approx(Vector2(-1.35, -6.85)))
	assert(Vector2(village_hearth_vertices[1].x, village_hearth_vertices[1].z).is_equal_approx(Vector2(1.3, -4.55)))
	assert(Vector2(village_wagon_vertices[1].x, village_wagon_vertices[1].z).is_equal_approx(Vector2(-1.35, -1.9)))
	var wagon_lane_end := village_wagon_vertices[village_wagon_vertices.size() - 2]
	assert(Vector2(wagon_lane_end.x, wagon_lane_end.z).is_equal_approx(Vector2(-6.9, -2.75)))
	assert(main.get_node_or_null("VillageCommonGround") == null)
	var mist_pass_path := main.get_node("MistPassPath") as MeshInstance3D
	assert(mist_pass_path.mesh is ArrayMesh and mist_pass_path.get_node_or_null("Shoulder") is MeshInstance3D)
	var mist_pass_tone := main.get_node_or_null("MistPassTone") as MeshInstance3D
	assert(mist_pass_tone != null and is_equal_approx(mist_pass_tone.position.y, 0.105))
	for track_name in ["NorthCartTrackLeft", "NorthCartTrackRight", "SouthCartTrackLeft", "SouthCartTrackRight"]:
		var cart_track := main.get_node_or_null(track_name) as MeshInstance3D
		assert(cart_track != null)
		assert(cart_track.mesh is ArrayMesh)
		assert(cart_track.material_override != main.get("path_material"))
		assert(is_equal_approx((cart_track.material_override as StandardMaterial3D).albedo_color.a, 0.42))
		assert((cart_track.material_override as StandardMaterial3D).vertex_color_use_as_albedo)
		var track_vertices := cart_track.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array
		var track_colors := cart_track.mesh.surface_get_arrays(0)[Mesh.ARRAY_COLOR] as PackedColorArray
		assert(track_vertices.size() >= 2 and is_equal_approx(track_vertices[0].distance_to(track_vertices[1]), 0.28))
		var track_min_alpha := 1.0
		var track_max_alpha := 0.0
		for track_color in track_colors:
			track_min_alpha = minf(track_min_alpha, track_color.a)
			track_max_alpha = maxf(track_max_alpha, track_color.a)
		assert(track_min_alpha < 0.08 and track_max_alpha > 0.95)
	var ground_material := main.get("ground_material") as StandardMaterial3D
	var path_material := main.get("path_material") as StandardMaterial3D
	assert(ground_material.albedo_texture is ImageTexture)
	var ground_image := (ground_material.albedo_texture as ImageTexture).get_image()
	assert(ground_image.get_width() == 128 and ground_image.get_height() == 128)
	assert(ground_image.has_mipmaps())
	var warm_pixel_count := 0
	var cool_pixel_count := 0
	var darkest_channel := 1.0
	var brightest_channel := 0.0
	for y in ground_image.get_height():
		for x in ground_image.get_width():
			var pixel := ground_image.get_pixel(x, y)
			if pixel.r - pixel.b > 0.008:
				warm_pixel_count += 1
			elif pixel.b - pixel.r > 0.008:
				cool_pixel_count += 1
			darkest_channel = minf(darkest_channel, minf(pixel.r, minf(pixel.g, pixel.b)))
			brightest_channel = maxf(brightest_channel, maxf(pixel.r, maxf(pixel.g, pixel.b)))
	assert(warm_pixel_count > 490 and cool_pixel_count > 490)
	assert(darkest_channel >= 0.819 and brightest_channel <= 0.996)
	for edge in ground_image.get_width():
		assert(ground_image.get_pixel(0, edge).is_equal_approx(ground_image.get_pixel(127, edge)))
		assert(ground_image.get_pixel(edge, 0).is_equal_approx(ground_image.get_pixel(edge, 127)))
	var repeated_ground_image := (main.call("_ground_texture") as ImageTexture).get_image()
	assert(ground_image.get_data() == repeated_ground_image.get_data())
	assert(path_material.albedo_texture is ImageTexture)
	var path_image := (path_material.albedo_texture as ImageTexture).get_image()
	assert(path_image.get_width() == 128 and path_image.get_height() == 128)
	assert(path_image.has_mipmaps())
	var path_warm_pixels := 0
	var path_cool_pixels := 0
	var path_dark_details := 0
	for y in path_image.get_height():
		for x in path_image.get_width():
			var path_pixel := path_image.get_pixel(x, y)
			if path_pixel.r - path_pixel.b > 0.006:
				path_warm_pixels += 1
			elif path_pixel.b - path_pixel.r > 0.006:
				path_cool_pixels += 1
			if path_pixel.get_luminance() < 0.80:
				path_dark_details += 1
	assert(
		path_warm_pixels > 100 and path_cool_pixels > 100,
		"Road texture warm=%d cool=%d" % [path_warm_pixels, path_cool_pixels]
	)
	assert(path_dark_details > 20, "Road texture dark details=%d" % path_dark_details)
	for edge in path_image.get_width():
		assert(path_image.get_pixel(0, edge).is_equal_approx(path_image.get_pixel(127, edge)))
		assert(path_image.get_pixel(edge, 0).is_equal_approx(path_image.get_pixel(edge, 127)))
	var repeated_path_image := (main.call("_road_texture") as ImageTexture).get_image()
	assert(path_image.get_data() == repeated_path_image.get_data())
	var road_texture_source := FileAccess.get_file_as_string("res://scripts/main.gd").get_slice("func _road_texture()", 1)
	assert("sin(" not in road_texture_source and "cos(" not in road_texture_source)
	assert(ground_material.uv1_scale.is_equal_approx(Vector3.ONE * 24.0))
	assert(path_material.uv1_scale.is_equal_approx(Vector3.ONE))
	assert(path_material.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA)
	assert(path_material.vertex_color_use_as_albedo)
	var roadside_stone_count := 0
	for road_name in [
		"VillagePath", "VillageWestLane", "VillageHearthLane", "VillageWagonLane",
		"VillageSouthLane", "PortalPath", "PondPath", "MistPassPath", "HerbYardPath",
	]:
		var road := main.get_node(road_name) as MeshInstance3D
		var edge_stones := road.get_node_or_null("EdgeStones") as Node3D
		assert(edge_stones != null)
		assert(edge_stones.get_meta("seed") == 490031 + absi(road_name.hash() % 100000))
		roadside_stone_count += edge_stones.get_child_count()
		for stone in edge_stones.get_children():
			var source_asset := stone.get_meta("source_asset") as String
			assert(source_asset.ends_with("Rock_Medium_1.gltf") or source_asset.ends_with("Rock_Medium_2.gltf"))
			assert(stone.scale.x >= 0.054 and stone.scale.x <= 0.096)
	assert(roadside_stone_count >= 10 and roadside_stone_count <= 35)
	var meadow := main.get_node_or_null("MeadowGrass") as MultiMeshInstance3D
	assert(meadow != null and meadow.multimesh != null)
	assert(meadow.get_meta("seed") == 20260901)
	assert(meadow.multimesh.use_custom_data)
	assert(meadow.multimesh.mesh.get_surface_count() == 1)
	var meadow_vertices := meadow.multimesh.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array
	assert(meadow_vertices.size() == 303)
	assert(meadow.multimesh.instance_count == 1902, "Unexpected meadow instance count: %d" % meadow.multimesh.instance_count)
	assert(meadow.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	var meadow_material := meadow.material_override as ShaderMaterial
	assert(meadow_material != null)
	assert((meadow_material.shader as Shader).resource_path == "res://shaders/meadow_grass.gdshader")
	var meadow_shader_code := (meadow_material.shader as Shader).code
	assert("MODEL_MATRIX[3].xyz" in meadow_shader_code)
	assert("height_ratio * height_ratio" in meadow_shader_code)
	assert("CAMERA_POSITION_WORLD" in meadow_shader_code)
	assert("INSTANCE_CUSTOM.r" in meadow_shader_code)
	assert("vec3(0.72, 0.95, 0.70)" in meadow_shader_code)
	assert("if (!FRONT_FACING)" in meadow_shader_code)
	assert("wind_strength" in meadow_shader_code and "motion_time" in meadow_shader_code)
	assert("1.0 - smoothstep(26.0, 42.0, camera_distance)" in meadow_shader_code)
	assert("EMISSION = grass_color * 0.03" in meadow_shader_code)
	assert(is_equal_approx(meadow_material.get_shader_parameter("wind_strength"), 0.62))
	assert(is_zero_approx(meadow_material.get_shader_parameter("motion_time")))
	var meadow_positions: PackedVector3Array = meadow.get_meta("positions")
	var meadow_brightness: PackedFloat32Array = meadow.get_meta("brightness_values")
	assert(meadow_positions.size() == meadow.multimesh.instance_count)
	assert(meadow_brightness.size() == meadow.multimesh.instance_count)
	assert(hash(meadow_positions) == 1499786692, "Unexpected meadow position hash: %d" % hash(meadow_positions))
	assert(hash(meadow_brightness) == 870796962, "Unexpected meadow brightness hash: %d" % hash(meadow_brightness))
	var meadow_silhouette_scales: Array = meadow.get_meta("silhouette_scales")
	var meadow_profile_indices: PackedByteArray = meadow.get_meta("silhouette_profile_indices")
	assert(meadow_silhouette_scales == [Vector3(1.10, 0.88, 1.10), Vector3.ONE, Vector3(0.90, 1.12, 0.90)])
	assert(meadow_profile_indices.size() == meadow.multimesh.instance_count)
	var dense_meadow_instances := 0
	var meadow_profile_counts := [0, 0, 0]
	for meadow_index in meadow.multimesh.instance_count:
		var meadow_origin := meadow_positions[meadow_index]
		var meadow_point := Vector2(meadow_origin.x, meadow_origin.z)
		var profile_index := meadow_profile_indices[meadow_index]
		assert(profile_index < meadow_silhouette_scales.size())
		meadow_profile_counts[profile_index] += 1
		assert(not main.call("_is_meadow_excluded", meadow_point), "Excluded meadow instance %d at %s" % [meadow_index, meadow_point])
		assert(meadow_brightness[meadow_index] >= 0.939 and meadow_brightness[meadow_index] <= 1.061)
		if meadow_point.x > -20.0 and meadow_point.x < 18.0 and meadow_point.y > -19.0 and meadow_point.y < 9.5:
			dense_meadow_instances += 1
	assert(meadow_profile_counts == [634, 634, 634])
	assert(0.34 * (meadow_silhouette_scales[2] as Vector3).y <= 0.381)
	assert(dense_meadow_instances > 1100, "Unexpected village meadow count: %d" % dense_meadow_instances)
	for activity_point in [Vector2(-4.7, 5.25), Vector2(-5.5, 7.4), Vector2(3.0, -14.1), Vector2(4.2, -15.2)]:
		assert(main.call("_is_meadow_excluded", activity_point))
	var meadow_noise := FastNoiseLite.new()
	meadow_noise.seed = 20260901
	meadow_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	meadow_noise.frequency = 0.075
	var sparse_roadside_samples := 0
	var dense_roadside_samples := 0
	for meadow_z in range(-18, 10):
		for meadow_x in range(-18, 19):
			var meadow_sample := Vector2(float(meadow_x) + 0.5, float(meadow_z) + 0.5)
			var meadow_road_edge: float = main.call("_meadow_road_edge_distance", meadow_sample, "VillagePath")
			if meadow_road_edge < 0.35 or meadow_road_edge >= 2.1:
				continue
			var sample_density: float = main.call("_meadow_density", meadow_sample, meadow_noise)
			if sample_density < 1.0:
				sparse_roadside_samples += 1
			elif sample_density > 5.5:
				dense_roadside_samples += 1
	assert(
		sparse_roadside_samples >= 8 and dense_roadside_samples >= 8,
		"Roadside samples sparse=%d dense=%d" % [sparse_roadside_samples, dense_roadside_samples]
	)
	var portal_platform := main.get_node_or_null("PortalPlatform") as CSGCylinder3D
	assert(portal_platform != null)
	assert(portal_platform.use_collision and not portal_platform.visible)
	assert(is_equal_approx(portal_platform.height, 0.08))
	assert(main.get_node("PortalStoneBed") is MeshInstance3D)
	assert(main.get_node("PortalArrivalWear") is MeshInstance3D)
	var portal_ground_ring := main.get_node_or_null("PortalGroundRing") as Node3D
	assert(portal_ground_ring != null and portal_ground_ring.get_child_count() == 7)
	for rune_index in 7:
		var ground_rune := portal_ground_ring.get_node("GroundRune%d" % rune_index) as CSGBox3D
		assert(ground_rune != null and not ground_rune.use_collision)
		var radial := Vector2(ground_rune.position.x, ground_rune.position.z).normalized()
		var tangent := Vector2(ground_rune.basis.x.x, ground_rune.basis.x.z).normalized()
		assert(absf(radial.dot(tangent)) < 0.01)
		assert((ground_rune.material as StandardMaterial3D).emission_energy_multiplier < 0.5)
	var portal_ruin := main.get_node_or_null("PortalRuin") as Node3D
	assert(portal_ruin != null)
	assert(portal_ruin.get_child_count() >= 17)
	var expected_arch_depths := [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	for arch_index in expected_arch_depths.size():
		var arch_stone := portal_ruin.get_node_or_null("ArchStone%d" % arch_index) as Node3D
		assert(arch_stone != null)
		assert(is_equal_approx(arch_stone.position.z, expected_arch_depths[arch_index]))
	assert((portal_ruin.get_node("LeftArchCollision") as CSGBox3D).position.is_equal_approx(Vector3(-2.0, 1.6, 0.0)))
	assert((portal_ruin.get_node("RightArchCollision") as CSGBox3D).position.is_equal_approx(Vector3(2.0, 1.6, 0.0)))
	assert(main.get_node("PortalRuin/PortalFern") is Node3D)
	assert(main.get_node("PortalRuin/PortalGrass") is Node3D)
	var portal_surface := main.get_node_or_null("PortalSurface") as MeshInstance3D
	assert(portal_surface != null and portal_surface.mesh is QuadMesh)
	assert((portal_surface.mesh as QuadMesh).size.is_equal_approx(Vector2(2.8, 2.8)))
	assert(portal_surface.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	var portal_occluders: Array = main.get("portal_occluders")
	assert(portal_occluders.size() == 11)
	assert(portal_occluders.all(func(occluder): return (occluder as Node3D).visible))
	assert(not main.get("portal_occluding"))
	var portal_xz := Vector2(main.get("portal_center").x, main.get("portal_center").z)
	var offset_camera := portal_xz + Vector2(6.0, 1.15)
	var offset_player := portal_xz + Vector2(-4.5, 1.15)
	assert(not main.call("_is_portal_occluding", offset_camera, offset_player, false))
	assert(main.call("_is_portal_occluding", offset_camera, offset_player, true))
	var portal_camera_rig := player.get_node("CameraRig") as Node3D
	player.position = main.get("portal_center") + Vector3(-4.5, 1.0, 0.0)
	player.set("camera_target_height", 12.0)
	player.call("_update_camera_zoom", 1.0)
	portal_camera_rig.rotation.y = PI * 0.5
	main.call("_process", 0.0)
	assert(main.get("portal_occluding"))
	assert(portal_occluders.all(func(occluder): return not (occluder as Node3D).visible))
	assert(not (main.get("portal_ring") as CSGTorus3D).visible)
	assert(not portal_surface.visible)
	assert(portal_ground_ring.visible)
	assert(portal_ruin.get_node("InteractionTarget").get("enabled"))
	player.position = main.get("portal_center") + Vector3(-5.2, 1.0, 0.0)
	main.call("_process", 0.0)
	assert(main.get("portal_occluding"), "Active portal occlusion must stay hidden inside the 5.0m-5.4m hysteresis band")
	main.set("portal_occluding", false)
	main.call("_process", 0.0)
	assert(not main.get("portal_occluding"), "Inactive portal occlusion must stay visible inside the 5.0m-5.4m hysteresis band")
	assert(portal_occluders.all(func(occluder): return (occluder as Node3D).visible))
	player.position = main.get("portal_center") + Vector3(0.0, 1.0, 3.0)
	player.set("camera_yaw", 0.0)
	player.set("camera_target_height", 15.0)
	player.call("_update_camera_zoom", 1.0)
	portal_camera_rig.rotation.y = 0.0
	main.call("_process", 0.0)
	assert(not main.get("portal_occluding"))
	assert(portal_occluders.all(func(occluder): return (occluder as Node3D).visible))
	(portal_surface.material_override as ShaderMaterial).set_shader_parameter("reaction_strength", 0.0)
	var portal_surface_material := portal_surface.material_override as ShaderMaterial
	assert(portal_surface_material != null)
	assert((portal_surface_material.shader as Shader).resource_path == "res://shaders/portal_surface.gdshader")
	assert(is_zero_approx(portal_surface_material.get_shader_parameter("reaction_strength")))
	var main_constants := (main.get_script() as Script).get_script_constant_map()
	assert(main.get_node_or_null("VillageProps") != null)
	var village_props := main.get_node("VillageProps") as Node3D
	assert(village_props.get_child_count() >= 12)
	assert(village_props.get_node_or_null("HerbDryingRack") is Node3D)
	assert(village_props.get_node_or_null("HerbHarvestCrate") is Node3D)
	var otherworld_trace := village_props.get_node_or_null("OtherworldTrace") as Node3D
	assert(otherworld_trace != null and otherworld_trace.position.is_equal_approx(Vector3(-3.35, 0.0, -1.22)))
	assert(otherworld_trace.get_node_or_null("TraceStone") is CSGCylinder3D)
	for trace_name in ["TraceSegmentA", "TraceSegmentB", "TraceSegmentC"]:
		var trace_segment := otherworld_trace.get_node_or_null(trace_name) as CSGBox3D
		assert(trace_segment != null and not trace_segment.use_collision)
	var trace_material := main.get("otherworld_trace_material") as StandardMaterial3D
	assert(trace_material.emission_enabled and trace_material.emission_energy_multiplier <= 0.2)
	var weaving_line := village_props.get_node_or_null("WeaverDryingLine") as Node3D
	assert(weaving_line != null and weaving_line.get_child_count() == 6)
	var village_marker := village_props.get_node_or_null("VillageBoundaryMarker") as Node3D
	assert(village_marker != null and village_marker.position.is_equal_approx(Vector3(3.35, 0.0, 5.1)))
	assert((-village_marker.basis.z).dot(Vector3.FORWARD) > 0.99)
	assert(village_marker.get_node_or_null("BoundaryFooting") != null)
	var boundary_stone := village_marker.get_node_or_null("BoundaryStone") as CSGPolygon3D
	var village_wedge := village_marker.get_node_or_null("VillageWedge") as CSGBox3D
	assert(boundary_stone != null and not boundary_stone.use_collision and boundary_stone.polygon.size() == 6)
	assert(boundary_stone.polygon[3].y <= 0.75)
	assert(village_wedge != null and not village_wedge.use_collision and village_wedge.size.z < 0.4)
	assert(village_marker.find_children("*", "Light3D", true, false).is_empty())
	var village_entry := village_props.get_node_or_null("VillageEntryBoundary") as Node3D
	assert(village_entry != null and village_entry.get_meta("open_side") == "east")
	var entry_positions := village_entry.get_meta("entry_positions") as PackedVector3Array
	assert(entry_positions.size() == 3)
	for entry_position in entry_positions:
		assert((main.call("_meadow_road_edge_distance", Vector2(entry_position.x, entry_position.z), "VillagePath") as float) > 0.1)
	for entry_name in ["LeftPost", "LeftPostInner", "LeftRail", "RightPost"]:
		var entry_piece := village_entry.get_node_or_null(entry_name) as CSGBox3D
		assert(entry_piece != null and not entry_piece.use_collision)
	var entry_left_stone := village_entry.get_node_or_null("LeftStone") as Node3D
	var entry_right_stone := village_entry.get_node_or_null("RightStone") as Node3D
	assert(entry_left_stone != null and entry_right_stone != null)
	assert(village_entry.find_children("*", "Light3D", true, false).is_empty())
	var village_wagon := village_props.get_node_or_null("VillageWagon") as Node3D
	assert(village_wagon != null and village_wagon.position.is_equal_approx(Vector3(-5.8, 0.0, -2.7)))
	assert(is_equal_approx(village_wagon.rotation.y, 1.37))
	var wagon_cargo_positions: Array = main_constants["WAGON_CARGO_POSITIONS"]
	var wagon_cargo_scales: Array = main_constants["WAGON_CARGO_SCALES"]
	assert(wagon_cargo_positions.size() == 2 and wagon_cargo_scales.size() == 2)
	for cargo_index in wagon_cargo_positions.size():
		var wagon_cargo := village_wagon.get_node_or_null("WagonCargoCrate%d" % cargo_index) as Node3D
		assert(wagon_cargo != null and wagon_cargo.get_parent() == village_wagon)
		assert(wagon_cargo.position.is_equal_approx(wagon_cargo_positions[cargo_index]))
		assert(is_equal_approx(wagon_cargo.scale.x, wagon_cargo_scales[cargo_index]))
		assert(wagon_cargo.position.y < 0.8 and wagon_cargo.find_children("*", "CollisionShape3D", true, false).is_empty())
	var wagon_shaft_direction := village_wagon.basis.z.normalized()
	var wagon_lane_exit := Vector3(2.0, 0.0, 0.4).normalized()
	assert(wagon_shaft_direction.dot(wagon_lane_exit) > 0.99)
	var wagon_crate_large := village_props.get_node_or_null("WagonUnloadCrateLarge") as Node3D
	var wagon_crate_small := village_props.get_node_or_null("WagonUnloadCrateSmall") as Node3D
	assert(wagon_crate_large.position.is_equal_approx(Vector3(-7.4, 0.0, -2.1)))
	assert(wagon_crate_small.position.is_equal_approx(Vector3(-7.45, 0.0, -3.0)))
	for wagon_crate in [wagon_crate_large, wagon_crate_small]:
		assert((wagon_crate.position - village_wagon.position).dot(wagon_shaft_direction) < 0.0)
	var wagon_collision := village_props.get_node_or_null("WagonCollision") as CSGBox3D
	assert(wagon_collision != null and wagon_collision.use_collision and not wagon_collision.visible)
	assert(wagon_collision.size.is_equal_approx(Vector3(1.9, 1.5, 2.6)))
	assert(is_equal_approx(wagon_collision.rotation.y, village_wagon.rotation.y))
	var warm_glass_materials: Array[StandardMaterial3D] = []
	for house_index in range(1, 4):
		var house := main.get_node("VillageHouse%d" % house_index) as Node3D
		assert((house.get_node("Door") as Node3D).position.is_equal_approx(Vector3(-0.515, 0.0, 3.09)))
		var window := house.get_node("Window") as Node3D
		assert(window.position.is_equal_approx(Vector3(2.0, 0.0, 2.875)))
		var warm_glass_found := false
		for window_mesh in window.find_children("*", "MeshInstance3D", true, false):
			var mesh_instance := window_mesh as MeshInstance3D
			for surface_index in mesh_instance.mesh.get_surface_count():
				var glass_material := mesh_instance.get_surface_override_material(surface_index) as StandardMaterial3D
				if glass_material != null and glass_material.emission_enabled:
					warm_glass_found = true
					warm_glass_materials.append(glass_material)
					assert(glass_material.albedo_color.r > glass_material.albedo_color.b)
					assert(glass_material.albedo_color.a <= 0.7)
					assert(glass_material.emission.r > glass_material.emission.b)
					assert(glass_material.emission_energy_multiplier <= 0.2)
		assert(warm_glass_found)
		assert((house.get_node("WindowGlow") as OmniLight3D).position.is_equal_approx(Vector3(2.0, 1.85, 3.18)))
	var herb_plot := main.get_node_or_null("HerbPlot") as Node3D
	assert(herb_plot != null)
	assert(herb_plot.position.is_equal_approx(Vector3(-14.8, 0.0, -10.0)))
	assert(is_equal_approx(herb_plot.rotation.y, PI * 0.5))
	assert(herb_plot.get_child_count() == 16)
	for bed_part_name in ["Soil", "NorthEdge", "SouthEdge", "MiddleEdge", "WestEdge", "EastEdge"]:
		var bed_part := herb_plot.get_node_or_null(bed_part_name) as CSGBox3D
		assert(bed_part != null)
		assert(not bed_part.use_collision)
	assert((herb_plot.get_node("Soil") as CSGBox3D).size.is_equal_approx(Vector3(5.2, 0.08, 3.2)))
	assert((herb_plot.get_node("Soil") as CSGBox3D).size.x * (herb_plot.get_node("Soil") as CSGBox3D).size.z >= 16.0)
	assert(main.get_node_or_null("HerbYardGrass") is MeshInstance3D)
	var herb_yard_path := main.get_node_or_null("HerbYardPath") as MeshInstance3D
	assert(herb_yard_path != null and herb_yard_path.mesh is ArrayMesh)
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
	var wagon_wear := main.get_node("VillageWearWagon") as MeshInstance3D
	assert(wagon_wear.position.is_equal_approx(Vector3(-6.25, 0.12, -2.65)))
	assert((wagon_wear.mesh as PlaneMesh).size.is_equal_approx(Vector2(6.25, 3.6)))
	for inset_name in ["VillageGrassNorthWest", "VillageGrassWest", "VillageGrassNorthEast", "VillageGrassSouthEast"]:
		var inset := main.get_node_or_null(inset_name) as MeshInstance3D
		assert(inset != null and is_equal_approx(inset.position.y, 0.115))
		var inset_texture := (inset.material_override as StandardMaterial3D).albedo_texture as GradientTexture2D
		assert(is_equal_approx(inset_texture.gradient.colors[0].a, 0.62))
	for wear_name in ["RoadWearNorth", "RoadWearFork", "RoadWearSouth"]:
		var wear := main.get_node_or_null(wear_name) as MeshInstance3D
		assert(wear != null and is_equal_approx(wear.position.y, 0.11))
	for blend_name in ["PortalPathBlend", "PondPathBlend"]:
		assert(main.get_node_or_null(blend_name) is MeshInstance3D)
	var pond_lookout := main.get_node_or_null("PondLookout") as MeshInstance3D
	assert(pond_lookout != null and pond_lookout.position.is_equal_approx(Vector3(-3.9, 0.058, 12.4)))
	assert((pond_lookout.mesh as PlaneMesh).size.is_equal_approx(Vector2(2.04, 2.85)))
	assert(main.get_node_or_null("NorthCliff") == null)
	assert(ResourceLoader.exists("res://scenes/world/valley_boundary.tscn"))
	var valley_boundary := main.get_node_or_null("ValleyBoundary") as Node3D
	assert(valley_boundary != null)
	assert(main.get_node_or_null("NorthCliffWest") == null)
	var north_cliff_west := valley_boundary.get_node("NorthCliffWest") as CSGBox3D
	var north_cliff_east := valley_boundary.get_node("NorthCliffEast") as CSGBox3D
	assert(north_cliff_west.use_collision and north_cliff_east.use_collision)
	assert(not north_cliff_west.visible and not north_cliff_east.visible)
	assert(north_cliff_west.position.x < -4.0 and north_cliff_east.position.x > 4.0)
	var mist_pass := main.get_node_or_null("MistPass") as Node3D
	assert(mist_pass != null and mist_pass.get_child_count() >= 15)
	var pass_boundary := mist_pass.get_node_or_null("MistPassBoundary") as CSGBox3D
	assert(pass_boundary != null and pass_boundary.use_collision and not pass_boundary.visible)
	assert(mist_pass.get_node_or_null("MistPillarLeft") is CSGCylinder3D)
	assert(mist_pass.get_node_or_null("MistPillarRight") is CSGCylinder3D)
	for step_index in 3:
		var mist_step := mist_pass.get_node_or_null("MistStep%d" % step_index) as CSGBox3D
		assert(mist_step != null)
		assert((mist_step.material as StandardMaterial3D).albedo_texture is ImageTexture)
	var mist_curtain := mist_pass.get_node_or_null("MistCurtain") as MeshInstance3D
	assert(mist_curtain != null)
	var mist_curtain_material := mist_curtain.material_override as ShaderMaterial
	assert(mist_curtain_material != null)
	assert((mist_curtain_material.shader as Shader).resource_path == "res://shaders/mist_curtain.gdshader")
	for rune_name in ["MistRuneLeft", "MistRuneRight"]:
		var rune := mist_pass.get_node_or_null(rune_name) as MeshInstance3D
		assert(rune != null)
		assert((rune.material_override as StandardMaterial3D).emission_enabled)
	var south_cliff := valley_boundary.get_node("SouthCliff") as CSGBox3D
	var west_cliff := valley_boundary.get_node("WestCliff") as CSGBox3D
	var east_cliff := valley_boundary.get_node("EastCliff") as CSGBox3D
	for cliff in [south_cliff, west_cliff, east_cliff]:
		assert(cliff.use_collision and not cliff.visible)
	var cliff_visuals := valley_boundary.get_node_or_null("CliffVisuals") as Node3D
	assert(cliff_visuals != null and cliff_visuals.get_child_count() >= 36)
	for cliff_index in cliff_visuals.get_child_count():
		var cliff_rock := cliff_visuals.get_child(cliff_index) as Node3D
		assert(cliff_rock.name == "CliffRock%02d" % cliff_index)
		if cliff_rock.position.z < -25.0 and absf(cliff_rock.position.x) < 10.0:
			assert(cliff_rock.scale.x <= 2.1)
	assert(main.get_node("BoundaryScenery").get_child_count() == 29)
	var fog_banks: Array = main.get("fog_banks")
	assert(fog_banks.size() == 7)
	assert(main.get("fog_bank_origins").size() == 7)
	for fog_index in range(7):
		var fog_bank := main.get_node_or_null("FogBank%d" % fog_index) as MeshInstance3D
		assert(fog_bank != null)
		assert(fog_bank.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	var pond := main.get_node_or_null("MistPond")
	assert(pond != null)
	assert(pond.position.is_equal_approx(Vector3(-7.8, 0.0, 12.0)))
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
	var roof_wood_materials: Array[StandardMaterial3D] = []
	var roof_tile_materials: Array[StandardMaterial3D] = []
	var expected_interior_identities: Array[String] = ["herbalist", "hearth", "weaver"]
	var expected_rug_colors: Array[Color] = [Color("697563"), Color("806552"), Color("755f66")]
	var expected_rug_sizes: Array[Vector3] = [Vector3(2.1, 0.03, 1.0), Vector3(2.3, 0.03, 1.5), Vector3(1.8, 0.03, 1.4)]
	var expected_rug_positions: Array[Vector3] = [Vector3(1.2, 0.085, 0.6), Vector3(0.9, 0.085, 0.55), Vector3(1.2, 0.085, 0.65)]
	var expected_bench_yaws: Array[float] = [0.0, PI * 0.5, 0.0]
	var expected_crate_positions: Array[Vector3] = [Vector3(-1.9, 0.0, -1.35), Vector3(1.85, 0.0, -1.75), Vector3(-1.9, 0.0, -1.65)]
	for house_index in range(1, 4):
		var house := main.get_node_or_null("VillageHouse%d" % house_index)
		assert(house != null)
		var interior_index := house_index - 1
		assert(house.get_meta("interior_identity") == expected_interior_identities[interior_index])
		assert(house.get_node_or_null("Roof") is Node3D)
		var house_collision := house.get_node_or_null("HouseCollision") as CSGBox3D
		assert(house_collision.use_collision and not house_collision.visible)
		for wall_name in ["HouseWallLeft", "HouseWallRight", "HouseWallBack"]:
			var house_wall := house.get_node_or_null(wall_name) as CSGBox3D
			assert(house_wall != null and not house_wall.use_collision)
			assert(house_wall.visible and house_wall.material.transparency == BaseMaterial3D.TRANSPARENCY_DISABLED)
		var interior_floor := house.get_node_or_null("HouseInteriorFloor") as CSGBox3D
		assert(interior_floor != null and not interior_floor.use_collision)
		assert(interior_floor.size.is_equal_approx(Vector3(5.55, 0.06, 5.55)))
		assert(interior_floor.position.is_equal_approx(Vector3(0.0, 0.05, 0.0)))
		assert(interior_floor.material == main.get("interior_floor_material"))
		for base_name in ["HouseStoneBaseLeft", "HouseStoneBaseRight", "HouseStoneBaseBack"]:
			var stone_base := house.get_node_or_null(base_name) as CSGBox3D
			assert(stone_base != null and not stone_base.use_collision)
		for trim_name in ["HouseTrimLeftMiddle", "HouseTrimRightMiddle", "HouseTrimBackMiddle", "HouseTrimLeftTop", "HouseTrimRightTop", "HouseTrimBackTop"]:
			var house_trim := house.get_node_or_null(trim_name) as CSGBox3D
			assert(house_trim != null and not house_trim.use_collision)
		assert(house.get_node_or_null("BackWindow") is Node3D)
		var interior_rug := house.get_node_or_null("InteriorRug") as CSGBox3D
		assert(interior_rug != null and not interior_rug.use_collision)
		assert(interior_rug.size.is_equal_approx(expected_rug_sizes[interior_index]))
		assert(interior_rug.position.is_equal_approx(expected_rug_positions[interior_index]))
		assert((interior_rug.material as StandardMaterial3D).albedo_color.is_equal_approx(expected_rug_colors[interior_index]))
		var interior_bench := house.get_node_or_null("InteriorBenchSeat") as CSGBox3D
		assert(interior_bench != null and not interior_bench.use_collision)
		assert(is_equal_approx(interior_bench.rotation.y, expected_bench_yaws[interior_index]))
		var interior_crate := house.get_node_or_null("InteriorCrate") as Node3D
		assert(interior_crate != null and interior_crate.position.is_equal_approx(expected_crate_positions[interior_index]))
		for interior_box in house.find_children("Interior*", "CSGBox3D", true, false):
			assert(not (interior_box as CSGBox3D).use_collision)
		match house_index:
			1:
				assert(house.get_node_or_null("InteriorHerbTableTop") is CSGBox3D)
				for bundle_index in 3:
					assert(house.get_node_or_null("InteriorHerbBundle%d" % bundle_index) is CSGBox3D)
				assert(house.get_node_or_null("InteriorHearthTableTop") == null)
				assert(house.get_node_or_null("InteriorLoomTopBeam") == null)
			2:
				assert(house.get_node_or_null("InteriorHearthTableTop") is CSGBox3D)
				assert(house.get_node_or_null("InteriorHearthTableBase") is CSGBox3D)
				assert(house.get_node_or_null("InteriorHearthStool") is CSGBox3D)
				assert(house.get_node_or_null("InteriorHerbTableTop") == null)
				assert(house.get_node_or_null("InteriorLoomTopBeam") == null)
			3:
				assert(house.get_node_or_null("InteriorLoomTopBeam") is CSGBox3D)
				assert(house.get_node_or_null("InteriorLoomBottomBeam") is CSGBox3D)
				for cloth_index in 3:
					assert(house.get_node_or_null("InteriorLoomCloth%d" % cloth_index) is CSGBox3D)
				assert(house.get_node_or_null("InteriorHerbTableTop") == null)
				assert(house.get_node_or_null("InteriorHearthTableTop") == null)
		assert(house.get_node_or_null("Roof/Chimney") is Node3D)
		assert(house.get_node_or_null("WindowGlow") is OmniLight3D)
		assert(house.get_node_or_null("SmokePuff0") is MeshInstance3D)
		var roof := house.get_node("Roof") as Node3D
		for roof_mesh in roof.find_children("*", "MeshInstance3D", true, false):
			var roof_mesh_instance := roof_mesh as MeshInstance3D
			for surface_index in roof_mesh_instance.mesh.get_surface_count():
				var roof_material := roof_mesh_instance.get_surface_override_material(surface_index) as StandardMaterial3D
				if roof_material == null:
					continue
				if roof_material.resource_name == "MI_WoodTrim":
					roof_wood_materials.append(roof_material)
					assert(roof_material.albedo_color.is_equal_approx(Color("c6b99a")))
					assert(roof_material.render_priority == 0)
				elif roof_material.resource_name == "MI_RoundTiles":
					roof_tile_materials.append(roof_material)
					assert(roof_material.albedo_texture.resource_path == "res://assets/quaternius/village/T_RoundTiles_BaseColor_Muted.png")
					assert(roof_material.render_priority == 1)
	assert(roof_wood_materials.size() == 3 and roof_tile_materials.size() == 3)
	var source_tile_image := (load("res://assets/quaternius/village/T_RoundTiles_BaseColor.png") as Texture2D).get_image()
	var muted_tile_image := (roof_tile_materials[0].albedo_texture as Texture2D).get_image()
	assert(muted_tile_image.get_size() == source_tile_image.get_size())
	var source_saturation := 0.0
	var muted_saturation := 0.0
	var source_value := 0.0
	var muted_value := 0.0
	var tile_sample_count := 0
	for y in range(0, source_tile_image.get_height(), 16):
		for x in range(0, source_tile_image.get_width(), 16):
			var source_pixel := source_tile_image.get_pixel(x, y)
			var muted_pixel := muted_tile_image.get_pixel(x, y)
			source_saturation += source_pixel.s
			muted_saturation += muted_pixel.s
			source_value += source_pixel.v
			muted_value += muted_pixel.v
			tile_sample_count += 1
	var source_average_saturation := source_saturation / float(tile_sample_count)
	var muted_average_saturation := muted_saturation / float(tile_sample_count)
	var source_average_value := source_value / float(tile_sample_count)
	var muted_average_value := muted_value / float(tile_sample_count)
	assert(
		muted_average_saturation < source_average_saturation * 0.75,
		"Roof saturation source=%.4f muted=%.4f" % [source_average_saturation, muted_average_saturation]
	)
	assert(
		muted_average_value < source_average_value * 0.98,
		"Roof value source=%.4f muted=%.4f" % [source_average_value, muted_average_value]
	)
	var house_fade_materials: Array = main.get("house_fade_materials")
	assert(not house_fade_materials.is_empty())
	assert(house_fade_materials.size() >= 6)
	assert(house_fade_materials.size() == main.get("house_fade_alphas").size())
	assert(house_fade_materials.size() == main.get("house_fade_house_indices").size())
	assert((main.get("house_roofs_faded") as Array).size() == 3)
	assert((main.get("house_roofs_faded") as Array).all(func(is_faded): return not is_faded))
	var player_occlusion_material := main.get("player_occlusion_material") as StandardMaterial3D
	assert(player_occlusion_material != null)
	assert(player_occlusion_material.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA)
	assert(player_occlusion_material.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED)
	assert(player_occlusion_material.no_depth_test)
	assert(player_occlusion_material.cull_mode == BaseMaterial3D.CULL_FRONT)
	assert(player_occlusion_material.grow)
	assert(is_equal_approx(player_occlusion_material.grow_amount, 0.035))
	assert(player_occlusion_material.render_priority == 127)
	assert(player_occlusion_material.albedo_color.is_equal_approx(Color(0.22, 0.32, 0.29, 0.0)))
	var player_body_mesh_count := 0
	for player_mesh_node in player.get_node("Visual").find_children("*", "MeshInstance3D", true, false):
		if player_mesh_node.name == "OtherworldMark":
			assert((player_mesh_node as MeshInstance3D).material_overlay == null)
			continue
		player_body_mesh_count += 1
		assert((player_mesh_node as MeshInstance3D).material_overlay == player_occlusion_material)
	assert(player_body_mesh_count > 0)
	var first_house_material := house_fade_materials[0] as StandardMaterial3D
	assert(first_house_material.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA)
	assert(is_equal_approx(first_house_material.albedo_color.a, 1.0))
	assert((main.get("house_fade_alphas") as Array).all(func(alpha): return is_equal_approx(alpha, 1.0)))
	var roof_animation_time: float = main.get("portal_time")
	var roof_camera_rig := player.get_node("CameraRig") as Node3D
	player.set("camera_target_height", 10.0)
	player.call("_update_camera_zoom", 1.0)
	player.position = Vector3(-9.0, 1.0, -5.5)
	roof_camera_rig.rotation.y = 0.0
	for frame_index in 120:
		main.call("_process", 1.0 / 60.0)
	assert(first_house_material.albedo_color.a > 0.99)
	roof_camera_rig.rotation.y = PI
	main.call("_process", 1.0 / 60.0)
	assert(first_house_material.albedo_color.a > 0.0 and first_house_material.albedo_color.a < 1.0)
	assert(player_occlusion_material.albedo_color.a > 0.0 and player_occlusion_material.albedo_color.a < 0.30)
	for frame_index in 120:
		main.call("_process", 1.0 / 60.0)
	assert(first_house_material.albedo_color.a < 0.001)
	assert((main.get("house_roofs_faded") as Array)[0])
	assert(is_equal_approx(player_occlusion_material.albedo_color.a, 0.30))
	var house_fade_house_indices: Array = main.get("house_fade_house_indices")
	for material_index in house_fade_materials.size():
		if house_fade_house_indices[material_index] == 0:
			assert((house_fade_materials[material_index] as StandardMaterial3D).albedo_color.a < 0.001)
	assert(is_equal_approx(warm_glass_materials[0].albedo_color.a, 0.66))
	var second_house_index := (main.get("house_fade_house_indices") as Array).find(1)
	assert(second_house_index >= 0)
	assert(is_equal_approx((house_fade_materials[second_house_index] as StandardMaterial3D).albedo_color.a, 1.0))
	player.position = Vector3(-9.0, 1.0, -4.1)
	main.call("_process", 1.0 / 60.0)
	assert((main.get("house_roofs_faded") as Array)[0], "Active roof must stay faded inside the 5.8m-6.3m distance hysteresis band")
	player.position = Vector3(-9.0, 1.0, -3.6)
	main.call("_process", 1.0 / 60.0)
	assert(not (main.get("house_roofs_faded") as Array)[0])
	player.position = Vector3(-9.0, 1.0, -4.1)
	main.call("_process", 1.0 / 60.0)
	assert(not (main.get("house_roofs_faded") as Array)[0], "Inactive roof must stay intact inside the 5.8m-6.3m distance hysteresis band")
	player.position = Vector3(-9.0, 1.0, -4.3)
	main.call("_process", 1.0 / 60.0)
	assert((main.get("house_roofs_faded") as Array)[0])
	player.position = Vector3(-5.7, 1.0, -5.5)
	main.call("_process", 1.0 / 60.0)
	assert((main.get("house_roofs_faded") as Array)[0], "Active roof must stay faded inside the 3.0m-3.6m view hysteresis band")
	player.position = Vector3(-5.3, 1.0, -5.5)
	main.call("_process", 1.0 / 60.0)
	assert(not (main.get("house_roofs_faded") as Array)[0])
	player.position = Vector3(-5.7, 1.0, -5.5)
	main.call("_process", 1.0 / 60.0)
	assert(not (main.get("house_roofs_faded") as Array)[0], "Inactive roof must stay intact inside the 3.0m-3.6m view hysteresis band")
	player.position = Vector3(-6.1, 1.0, -5.5)
	main.call("_process", 1.0 / 60.0)
	assert((main.get("house_roofs_faded") as Array)[0])
	player.position = Vector3(-9.0, 1.0, -5.5)
	roof_camera_rig.rotation.y = 0.0
	main.call("_process", 1.0 / 60.0)
	assert(first_house_material.albedo_color.a > 0.0 and first_house_material.albedo_color.a < 1.0)
	assert(player_occlusion_material.albedo_color.a > 0.0 and player_occlusion_material.albedo_color.a < 0.30)
	for frame_index in 120:
		main.call("_process", 1.0 / 60.0)
	assert(first_house_material.albedo_color.a > 0.99)
	assert(player_occlusion_material.albedo_color.a < 0.001)
	assert(is_equal_approx(warm_glass_materials[0].albedo_color.a, 0.66))
	player.position = Vector3(0.0, 1.0, 30.0)
	main.call("_process", 0.0)
	assert((main.get("house_roofs_faded") as Array).all(func(is_faded): return not is_faded))
	main.set("portal_time", roof_animation_time)
	for roof_label_node in main.get("villager_labels") as Array:
		var roof_label := roof_label_node as Label3D
		var roof_label_color := roof_label.modulate
		roof_label_color.a = 0.0
		roof_label.modulate = roof_label_color
		var roof_outline_color := roof_label.outline_modulate
		roof_outline_color.a = 0.0
		roof_label.outline_modulate = roof_outline_color
		roof_label.visible = false
	main.call("_process", 0.0)
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
	var tree_canopies: Array = main.get("tree_canopies")
	var tree_canopy_materials: Array = main.get("tree_canopy_materials")
	assert(tree_canopies.size() == 16 and tree_canopy_materials.size() == 16)
	var northwest_tree_canopy: MeshInstance3D
	var northwest_pine_canopy: MeshInstance3D
	var pond_twisted_tree_canopy: MeshInstance3D
	for canopy_node in tree_canopies:
		var candidate := canopy_node as MeshInstance3D
		if Vector2(candidate.global_position.x, candidate.global_position.z).is_equal_approx(Vector2(-21.0, -24.8)):
			northwest_tree_canopy = candidate
		elif Vector2(candidate.global_position.x, candidate.global_position.z).is_equal_approx(Vector2(-24.8, -12.5)):
			northwest_pine_canopy = candidate
		elif Vector2(candidate.global_position.x, candidate.global_position.z).is_equal_approx(Vector2(-16.0, 17.0)):
			pond_twisted_tree_canopy = candidate
	assert(northwest_tree_canopy != null and northwest_pine_canopy != null and pond_twisted_tree_canopy != null)
	var northwest_tree_collision: CSGCylinder3D
	for child in main.get_children():
		if child is CSGCylinder3D and (child as CSGCylinder3D).position.is_equal_approx(Vector3(-21.0, 1.8375, -24.8)):
			northwest_tree_collision = child as CSGCylinder3D
			break
	assert(northwest_tree_collision != null and northwest_tree_collision.position.z < -24.5)
	var muted_tree_canopy_count := 0
	for canopy_index in tree_canopies.size():
		var canopy := tree_canopies[canopy_index] as MeshInstance3D
		var canopy_material := tree_canopy_materials[canopy_index] as ShaderMaterial
		var canopy_texture := canopy_material.get_shader_parameter("albedo_tex") as Texture2D
		assert(canopy != null and canopy_material.shader.resource_path == "res://shaders/tree_canopy.gdshader")
		assert(canopy_texture.resource_path.contains("nature"))
		if canopy_texture.resource_path == "res://assets/quaternius/nature/Leaves_TwistedTree_C_Muted.png":
			muted_tree_canopy_count += 1
			assert(canopy == pond_twisted_tree_canopy)
		assert((canopy_material.get_shader_parameter("canopy_max_y") as float) > (canopy_material.get_shader_parameter("canopy_min_y") as float))
		assert(is_equal_approx(canopy_material.get_shader_parameter("wind_strength"), 0.62))
	assert(muted_tree_canopy_count == 1)
	var tree_shader_code := (tree_canopy_materials[0] as ShaderMaterial).shader.code
	assert("MODEL_MATRIX[3].xyz" in tree_shader_code)
	assert("motion_time" in tree_shader_code and "wind_strength" in tree_shader_code)
	assert("height_ratio * height_ratio" in tree_shader_code)
	assert("smoothstep(20.0, 42.0, camera_distance)" in tree_shader_code)
	assert("ALPHA_SCISSOR_THRESHOLD = 0.2" in tree_shader_code)
	var falling_leaves := main.get_node_or_null("FallingLeaves") as Node3D
	assert(falling_leaves != null and falling_leaves.get_child_count() == 12)
	assert(falling_leaves.get_meta("seed") == 20260903)
	var leaf_clusters: Array = falling_leaves.get_meta("clusters")
	assert(leaf_clusters.size() == 4)
	assert((leaf_clusters[0] as Vector2).is_equal_approx(Vector2(-21.0, -24.4)))
	assert((leaf_clusters[0] as Vector2).distance_to(Vector2(northwest_tree_canopy.global_position.x, northwest_tree_canopy.global_position.z)) <= 0.41)
	for cluster in leaf_clusters:
		assert(absf((cluster as Vector2).x) >= 8.0)
	var falling_leaf_materials: Array = main.get("falling_leaf_materials")
	assert(falling_leaf_materials.size() == 3)
	for leaf_material in falling_leaf_materials:
		assert((leaf_material as StandardMaterial3D).resource_name == "OtherworldLeaf")
		assert((leaf_material as StandardMaterial3D).emission_energy_multiplier <= 0.08)
	var first_leaf := falling_leaves.get_child(0) as MeshInstance3D
	assert(first_leaf.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	var leaf_vertices := first_leaf.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array
	assert(leaf_vertices.size() == 4)
	assert(leaf_vertices[2].x - leaf_vertices[0].x >= 0.299)
	assert(leaf_vertices[3].z - leaf_vertices[1].z >= 0.144)
	assert(leaf_vertices[1].y > 0.0 and leaf_vertices[3].y < 0.0)
	for leaf_index in falling_leaves.get_child_count():
		var leaf_params: Dictionary = (falling_leaves.get_child(leaf_index) as MeshInstance3D).get_meta("params")
		var cluster: Vector2 = leaf_clusters[leaf_index % leaf_clusters.size()]
		var edge_distance := (leaf_params["home"] as Vector2).distance_to(cluster)
		assert(edge_distance >= 1.79 and edge_distance <= 3.01)
	var leaf_start_position := first_leaf.position
	main.set("portal_time", 1.0)
	main.call("_animate_falling_leaves")
	assert(first_leaf.position.distance_to(leaf_start_position) > 0.01)
	var clear_leaf_position := first_leaf.position
	main.set("weather_override", "light_rain")
	main.call("_apply_time_of_day")
	main.call("_animate_falling_leaves")
	assert(main.get("weather_wind_amount") > 1.0)
	assert(first_leaf.position.distance_to(clear_leaf_position) > 0.01)
	main.call("_animate_tree_canopies")
	assert(is_equal_approx((tree_canopy_materials[0] as ShaderMaterial).get_shader_parameter("wind_strength"), 1.12))
	assert(is_equal_approx(meadow_material.get_shader_parameter("wind_strength"), 1.12))
	var rack_for_rain := main.get_node("VillageProps/HerbDryingRack") as Node3D
	var rain_params_for_test: Array = main.get("rain_params")
	var first_rain_param: Dictionary = rain_params_for_test[0]
	var saved_rain_x: float = first_rain_param["x"]
	var saved_rain_z: float = first_rain_param["z"]
	var saved_rain_start_y: float = first_rain_param["start_y"]
	var saved_player_position := player.position
	var saved_portal_time: float = main.get("portal_time")
	first_rain_param["x"] = 0.0
	first_rain_param["z"] = 0.0
	first_rain_param["start_y"] = 0.45
	main.set("portal_time", 0.0)
	player.position = rack_for_rain.position + Vector3(0.0, 1.0, 0.0)
	main.call("_animate_weather")
	var first_rain_streak := (main.get("rain_streaks") as Array)[0] as MeshInstance3D
	assert(is_equal_approx(first_rain_streak.transparency, 1.0))
	first_rain_param["x"] = saved_rain_x
	first_rain_param["z"] = saved_rain_z
	first_rain_param["start_y"] = saved_rain_start_y
	main.set("portal_time", saved_portal_time)
	player.position = saved_player_position
	main.set("weather_override", "clear")
	main.set("time_hour", 22.0)
	main.call("_apply_time_of_day")
	var night_clear_ambient := (main.get("environment_settings") as Environment).ambient_light_energy
	main.set("weather_override", "light_rain")
	main.call("_apply_time_of_day")
	var night_rain_environment := main.get("environment_settings") as Environment
	assert(night_rain_environment.ambient_light_energy > night_clear_ambient + 0.04)
	var night_rain_base_fog := (main.call("_sample_day", 22.0)["fog_density"] as float) * 1.48
	assert(night_rain_environment.fog_density < night_rain_base_fog)
	main.set("weather_override", "clear")
	main.set("time_hour", 9.5)
	main.set("portal_time", 0.0)
	main.call("_apply_time_of_day")
	assert(is_equal_approx(main.get("weather_surface_wetness"), 0.0))
	assert((main.get("ground_material") as StandardMaterial3D).albedo_color.is_equal_approx(clear_ground_color))
	assert(is_equal_approx((main.get("ground_material") as StandardMaterial3D).roughness, clear_ground_roughness))
	main.call("_animate_tree_canopies")
	main.call("_animate_falling_leaves")
	var seasonal_bushes: Array = main.get("seasonal_bushes")
	var seasonal_bush_materials: Array = main.get("seasonal_bush_materials")
	assert(seasonal_bushes.size() == 3)
	assert(seasonal_bush_materials.size() == 3)
	for index in seasonal_bushes.size():
		assert((seasonal_bushes[index] as Node3D).name == "SeasonalBush%d" % index)
		assert((seasonal_bushes[index] as Node3D) in wind_nodes)
		var bush_material := seasonal_bush_materials[index] as StandardMaterial3D
		assert(bush_material.resource_name == "SeasonalBushLeaves")
		assert(bush_material.albedo_texture.resource_path == "res://assets/quaternius/nature/Leaves_TwistedTree_C_Muted.png")
		assert(not bush_material.emission_enabled)
		assert(bush_material.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR)
		assert(bush_material.cull_mode == BaseMaterial3D.CULL_DISABLED)
		if index > 0:
			assert(bush_material != seasonal_bush_materials[0])
	var source_bush_image := (load("res://assets/quaternius/nature/Leaves_TwistedTree_C.png") as Texture2D).get_image()
	var muted_bush_image := (seasonal_bush_materials[0] as StandardMaterial3D).albedo_texture.get_image()
	assert(muted_bush_image.get_size() == source_bush_image.get_size())
	var source_bush_saturation := 0.0
	var muted_bush_saturation := 0.0
	var source_bush_value := 0.0
	var muted_bush_value := 0.0
	var bush_sample_count := 0
	for y in range(0, source_bush_image.get_height(), 16):
		for x in range(0, source_bush_image.get_width(), 16):
			var source_pixel := source_bush_image.get_pixel(x, y)
			if source_pixel.a < 0.5:
				continue
			var muted_pixel := muted_bush_image.get_pixel(x, y)
			assert(absf(muted_pixel.a - source_pixel.a) < 0.02)
			source_bush_saturation += source_pixel.s
			muted_bush_saturation += muted_pixel.s
			source_bush_value += source_pixel.v
			muted_bush_value += muted_pixel.v
			bush_sample_count += 1
	assert(bush_sample_count > 1000)
	var source_bush_average_saturation := source_bush_saturation / float(bush_sample_count)
	var muted_bush_average_saturation := muted_bush_saturation / float(bush_sample_count)
	var source_bush_average_value := source_bush_value / float(bush_sample_count)
	var muted_bush_average_value := muted_bush_value / float(bush_sample_count)
	assert(muted_bush_average_saturation < source_bush_average_saturation * 0.7)
	assert(muted_bush_average_value > source_bush_average_value * 0.85)
	assert(muted_bush_average_value < source_bush_average_value)
	var pond_ripples: Array = main.get("pond_ripples")
	assert(pond_ripples.size() == 2)
	var pond_ripple_mesh := (pond_ripples[0] as MeshInstance3D).mesh as TorusMesh
	assert(pond_ripple_mesh != null and pond_ripple_mesh.rings == 32)
	assert(pond_ripple_mesh.ring_segments == 16)
	assert((pond_ripples[1] as MeshInstance3D).mesh == pond_ripple_mesh)
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
		["HerbalistMira", "米拉", "药草师", 0.64],
		["GatekeeperToren", "托伦", "守门人", 0.67],
		["WeaverNia", "尼娅", "织工", 0.78],
	]:
		var npc_name: String = npc_data[0]
		var npc := main.get_node_or_null(npc_name) as CharacterBody3D
		assert(npc != null)
		var npc_collider := npc.get_node_or_null("CollisionShape3D") as CollisionShape3D
		assert(npc_collider != null and is_equal_approx(npc_collider.position.y, 0.8))
		var npc_capsule := npc_collider.shape as CapsuleShape3D
		assert(is_equal_approx(npc_capsule.radius, 0.32))
		assert(is_equal_approx(npc_capsule.height, 1.6))
		var identity_label := npc.get_node_or_null("IdentityLabel") as Label3D
		assert(identity_label != null)
		assert(identity_label.text.contains(npc_data[1]))
		assert(identity_label.text.contains(npc_data[2]))
		assert(identity_label.billboard == BaseMaterial3D.BILLBOARD_ENABLED)
		assert(not identity_label.fixed_size)
		assert(is_equal_approx(identity_label.pixel_size, 0.009))
		assert(not identity_label.visible)
		var npc_model := npc.get_node_or_null("Visual/CharacterModel") as Node3D
		assert(npc_model != null)
		assert(npc_model.get_node_or_null("RiggedModel") is Node3D)
		assert(npc_model.find_child("OtherworldMark", true, false) == null)
		assert(npc_model.position.is_equal_approx(Vector3.ZERO))
		var expected_visual_scale: float = npc_data[3]
		assert(npc_model.scale.is_equal_approx(Vector3.ONE * expected_visual_scale))
		var npc_skeleton := npc_model.find_child("Skeleton3D", true, false) as Skeleton3D
		assert(npc_skeleton != null and npc_skeleton.get_bone_count() == 23)
		var npc_visual_height := _visual_height(npc_model)
		assert(npc_visual_height >= 1.65 and npc_visual_height <= 1.75)
		assert(npc_visual_height >= player_visual_height * 0.97)
		assert(npc_visual_height <= player_visual_height * 1.03)
		assert(identity_label.position.y >= npc_visual_height + 0.2)
		var npc_animation := npc_model.find_child("AnimationPlayer", true, false) as AnimationPlayer
		assert(npc_animation != null)
		assert(npc_animation.has_animation("Idle"))
		assert(npc_animation.has_animation("Walk"))
		if npc.name == "HerbalistMira":
			assert(npc_animation.has_animation("PickUp"))
			assert(npc_animation.get_animation("PickUp").loop_mode == Animation.LOOP_NONE)
		if npc.name == "GatekeeperToren" or npc.name == "HerbalistMira":
			assert(npc_animation.current_animation == "Idle", "%s unexpectedly playing %s" % [npc.name, npc_animation.current_animation])
		else:
			assert(npc_animation.current_animation == "Walk")
		assert(npc_animation.get_animation("Idle").loop_mode == Animation.LOOP_LINEAR)
		assert(npc_animation.get_animation("Walk").loop_mode == Animation.LOOP_LINEAR)
	assert(main.get("villager_patrol_origins").size() == 3)
	assert(main.get("villager_patrol_axes").size() == 3)
	for patrol_axis in main.get("villager_patrol_axes"):
		assert(is_equal_approx((patrol_axis as Vector3).length(), 1.0))
	assert(main.get("villager_patrol_directions").size() == 3)
	assert(main.get("villager_patrol_pauses").size() == 3)
	var toren_route: Array = main_constants["TOREN_WATCH_ROUTE"]
	var toren_targets: Array = main_constants["TOREN_WATCH_TARGETS"]
	var toren_pauses: Array = main_constants["TOREN_WATCH_PAUSES"]
	var nia_public_route: Array = main_constants["NIA_PUBLIC_ROUTE"]
	var nia_work_route: Array = main_constants["NIA_WORK_ROUTE"]
	var nia_work_targets: Array = main_constants["NIA_WORK_TARGETS"]
	var nia_work_pauses: Array = main_constants["NIA_WORK_PAUSES"]
	var nia_day_rain_route: Array = main_constants["NIA_DAY_RAIN_ROUTE"]
	assert(toren_route.size() == 3 and toren_targets.size() == 3 and toren_pauses.size() == 3)
	assert(nia_public_route.size() == 9)
	assert((nia_public_route[0] as Vector3).is_equal_approx(Vector3(-5.5, 0.0, 6.5)))
	assert((nia_public_route[4] as Vector3).is_equal_approx(Vector3(-0.35, 0.0, 2.0)))
	assert((nia_public_route[-1] as Vector3).x < -7.0)
	assert(nia_work_route.size() == 3 and nia_work_targets.size() == 3 and nia_work_pauses.size() == 3)
	var nia_work_first_leg: Vector3 = (nia_work_route[1] as Vector3) - (nia_work_route[0] as Vector3)
	var nia_work_second_leg: Vector3 = (nia_work_route[2] as Vector3) - (nia_work_route[0] as Vector3)
	assert(absf(nia_work_first_leg.x * nia_work_second_leg.z - nia_work_first_leg.z * nia_work_second_leg.x) > 0.2)
	assert(is_equal_approx(main_constants["NIA_WORK_SPEED"], 0.46))
	assert(nia_day_rain_route.size() == 2)
	assert((nia_day_rain_route[0] as Vector3).is_equal_approx(nia_work_route[0]))
	assert((nia_day_rain_route[-1] as Vector3).is_equal_approx(Vector3(-6.5, 0.0, 6.4)))
	assert((nia_day_rain_route[0] as Vector3).distance_to(nia_day_rain_route[-1]) < 1.1)
	assert((nia_work_targets[2] as Vector3).is_equal_approx(weaving_line.global_position))
	assert((nia_work_route[2] as Vector3).distance_to(weaving_line.global_position) > 1.0)
	assert((nia_work_route[2] as Vector3).distance_to(weaving_line.global_position) < 1.2)
	for work_point_value in nia_work_route:
		var work_point := work_point_value as Vector3
		assert(work_point.x >= -6.2 and work_point.x <= -4.65)
		assert(work_point.z >= 6.3 and work_point.z <= 7.0)
		assert(work_point.distance_to((weaving_line.get_node("LeftPost") as Node3D).global_position) > 0.65)
		assert(work_point.distance_to((weaving_line.get_node("RightPost") as Node3D).global_position) > 0.65)
	assert((toren_route[0] as Vector3).is_equal_approx(Vector3(3.0, 0.0, -15.2)))
	var toren_first_leg := (toren_route[1] as Vector3) - (toren_route[0] as Vector3)
	var toren_second_leg := (toren_route[2] as Vector3) - (toren_route[0] as Vector3)
	assert(absf(toren_first_leg.x * toren_second_leg.z - toren_first_leg.z * toren_second_leg.x) > 0.5)
	assert(not is_equal_approx(toren_pauses[0], toren_pauses[1]))
	assert(not is_equal_approx(toren_pauses[1], toren_pauses[2]))
	assert(is_equal_approx(main_constants["TOREN_WATCH_SPEED"], 0.52))
	var toren_origin := main.get("villager_patrol_origins")[1] as Vector3
	assert(toren_origin.is_equal_approx(Vector3(3.0, 0.0, -15.2)))
	var toren := main.get_node("GatekeeperToren") as CharacterBody3D
	assert(toren.position.distance_to(toren_origin) < 0.1)
	assert(main.get("villager_animations").size() == 3)
	player.position = Vector3(0.0, 1.0, 30.0)
	toren.position = toren_route[0]
	main.set("toren_watch_index", 0)
	main.get("villager_patrol_pauses")[1] = 0.0
	main.call("_physics_process", 1.0 / 60.0)
	assert(is_equal_approx(Vector2(toren.velocity.x, toren.velocity.z).length(), 0.52))
	var first_watch_direction := Vector2(toren_first_leg.x, toren_first_leg.z).normalized()
	assert(Vector2(toren.velocity.x, toren.velocity.z).normalized().dot(first_watch_direction) > 0.999)
	var toren_animation := main.get("villager_animations")[1] as AnimationPlayer
	assert(toren_animation.assigned_animation == "Walk")
	toren.position = (toren_route[1] as Vector3) - toren_first_leg.normalized() * 0.04
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("toren_watch_index") == 1)
	assert(Vector2(toren.position.x, toren.position.z).is_equal_approx(Vector2((toren_route[1] as Vector3).x, (toren_route[1] as Vector3).z)))
	assert(is_equal_approx(main.get("villager_patrol_pauses")[1], toren_pauses[1]))
	assert(toren_animation.assigned_animation == "Idle")
	main.call("_process", 1.0)
	var watch_direction := (toren_targets[1] as Vector3) - toren.global_position
	var toren_visual := toren.get_node("Visual") as Node3D
	var watch_angle_error := absf(angle_difference(toren_visual.rotation.y, atan2(watch_direction.x, watch_direction.z)))
	assert(watch_angle_error < 0.001, "Toren watch angle error %.4f, current %.4f" % [watch_angle_error, toren_visual.rotation.y])
	main.get("villager_patrol_pauses")[1] = 0.0
	main.call("_physics_process", 1.0 / 60.0)
	var second_route_leg := (toren_route[2] as Vector3) - (toren_route[1] as Vector3)
	assert(Vector2(toren.velocity.x, toren.velocity.z).normalized().dot(Vector2(second_route_leg.x, second_route_leg.z).normalized()) > 0.999)
	assert(toren_animation.assigned_animation == "Walk")
	var toren_talk_position := Vector2(toren.position.x, toren.position.z)
	player.position = toren.position + Vector3(0.0, 1.0, 2.0)
	main.call("_process", 0.0)
	assert(main.get("nearby_villager") == toren)
	main.call("_physics_process", 1.0)
	assert(Vector2(toren.position.x, toren.position.z).distance_to(toren_talk_position) < 0.001)
	assert(main.get("toren_watch_index") == 1 and is_zero_approx(main.get("villager_patrol_pauses")[1]))
	assert(toren_animation.assigned_animation == "Idle")
	player.position = Vector3(0.0, 1.0, 30.0)
	main.call("_process", 0.0)
	toren.position = toren_route[0]
	toren.velocity = Vector3.ZERO
	main.set("toren_watch_index", 0)
	main.get("villager_patrol_pauses")[1] = 2.8
	toren_animation.play("Idle")
	var mira_route: Array = main_constants["MIRA_HERB_ROUTE"]
	var mira_targets: Array = main_constants["MIRA_HERB_TARGETS"]
	var mira_pauses: Array = main_constants["MIRA_HERB_PAUSES"]
	assert(mira_route.size() == 4 and mira_targets.size() == 4 and mira_pauses.size() == 4)
	assert((mira_route[0] as Vector3).is_equal_approx(Vector3(-12.0, 0.0, -7.0)))
	assert((mira_route[2] as Vector3).distance_to(herb_plot.position) < 1.0)
	var drying_rack := village_props.get_node("HerbDryingRack") as Node3D
	assert((mira_route[3] as Vector3).distance_to(drying_rack.position) < 1.0)
	var rain_awning := drying_rack.get_node("RainAwning") as CSGBox3D
	assert(rain_awning.size.x >= 1.85 and rain_awning.size.z >= 0.68)
	assert(rain_awning.position.y > 1.6 and rain_awning.position.z < 0.0)
	var cloth_rose := weaving_line.get_node("ClothRose") as Node3D
	assert(cloth_rose != null and cloth_rose in wind_nodes)
	var herb_bundles: Array[Node3D] = []
	for bundle_index in 4:
		var bundle_anchor := drying_rack.get_node("HerbBundle%d" % bundle_index) as Node3D
		assert(bundle_anchor != null and bundle_anchor in wind_nodes)
		var bundle_mesh := bundle_anchor.get_node("Mesh") as Node3D
		assert(bundle_mesh != null)
		assert(bundle_mesh.rotation.z > 3.0)
		herb_bundles.append(bundle_anchor)
	assert(is_equal_approx(main_constants["MIRA_HERB_SPEED"], 0.46))
	var mira_shelter := main.get_node("VillageHouse1/MiraRainShelter") as Node3D
	assert(mira_shelter != null)
	assert(mira_shelter.position.is_equal_approx(Vector3(-0.52, 0.0, 3.58)))
	assert(mira_shelter.get_node("Canopy") is CSGBox3D)
	assert(mira_shelter.get_node("CanopyPostLeft") is CSGBox3D)
	assert(mira_shelter.get_node("CanopyPostRight") is CSGBox3D)
	assert(not (mira_shelter.get_node("Canopy") as CSGBox3D).use_collision)
	assert((main_constants["MIRA_RAIN_SHELTER"] as Vector3).distance_to(Vector3(-8.98, 0.0, -6.38)) < 0.08)
	var mira := main.get_node("HerbalistMira") as CharacterBody3D
	var mira_animation := main.get("villager_animations")[0] as AnimationPlayer
	var pickup_length := mira_animation.get_animation("PickUp").length
	main.set("time_hour", 9.5)
	main.set("weather_override", "light_rain")
	main.call("_process", 0.0)
	mira.position = mira_route[2]
	main.set("mira_route_index", 2)
	main.set("mira_routine", "work")
	main.set("mira_rain_shelter_active", false)
	main.set("mira_rain_shelter_leg", 0)
	main.get("villager_patrol_pauses")[0] = 0.0
	var mira_rain_departure := mira.position
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("mira_routine") == "homeward")
	assert(main.get("mira_rain_shelter_active"))
	assert(main.get("mira_route_index") == 1)
	assert(mira_animation.assigned_animation == "Walk")
	var rain_approach: Vector3 = main_constants["MIRA_RAIN_SHELTER_APPROACH"]
	var mira_rain_step := Vector2(mira.position.x, mira.position.z).distance_to(Vector2(mira_rain_departure.x, mira_rain_departure.z))
	assert(mira_rain_step > 0.001 and mira_rain_step < 0.15)
	var rain_route_direction: Vector3 = (mira_route[1] as Vector3) - mira_rain_departure
	assert(Vector2(mira.velocity.x, mira.velocity.z).normalized().dot(Vector2(rain_route_direction.x, rain_route_direction.z).normalized()) > 0.999)
	mira.position = mira_route[0]
	main.set("mira_route_index", 0)
	main.set("mira_rain_shelter_leg", 0)
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("mira_rain_shelter_leg") == 1)
	assert(mira_animation.assigned_animation == "Walk")
	mira.position = rain_approach
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("mira_rain_shelter_leg") == 2)
	assert(mira_animation.assigned_animation == "Walk")
	mira.position = main_constants["MIRA_RAIN_SHELTER"]
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("mira_routine") == "rain_shelter")
	assert(mira.position.distance_to(main_constants["MIRA_RAIN_SHELTER"] as Vector3) < 0.14)
	assert(mira.position.distance_to(mira_shelter.global_position) < 0.1)
	assert(mira_animation.assigned_animation == "Idle")
	main.set("weather_override", "clear")
	main.call("_process", 0.0)
	main.set("mira_route_index", 0)
	main.set("mira_routine", "work")
	main.set("mira_rain_shelter_active", false)
	main.set("mira_rain_shelter_leg", 0)
	mira.position = mira_route[0]
	mira.velocity = Vector3.ZERO
	main.get("villager_patrol_pauses")[0] = 0.0
	player.position = Vector3(0.0, 1.0, 30.0)
	main.call("_process", 0.0)
	main.call("_physics_process", 1.0 / 60.0)
	assert(mira.position.distance_to(mira_route[0]) > 0.001)
	assert(is_equal_approx(Vector2(mira.velocity.x, mira.velocity.z).length(), 0.46))
	assert(mira_animation.assigned_animation == "Walk")
	var first_mira_leg: Vector3 = (mira_route[1] as Vector3) - (mira_route[0] as Vector3)
	mira.position = (mira_route[1] as Vector3) - first_mira_leg.normalized() * 0.04
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("mira_route_index") == 1)
	assert(is_equal_approx(main.get("villager_patrol_pauses")[0], mira_pauses[1]))
	assert(mira_animation.assigned_animation == "Idle")
	var mira_visual := mira.get_node("Visual") as Node3D
	main.call("_process", 1.0)
	var entry_direction: Vector3 = (mira_targets[1] as Vector3) - mira.global_position
	assert(absf(angle_difference(mira_visual.rotation.y, atan2(entry_direction.x, entry_direction.z))) < 0.001)
	main.get("villager_patrol_pauses")[0] = 0.0
	main.call("_physics_process", 1.0 / 60.0)
	assert(mira_animation.assigned_animation == "Walk")
	var second_mira_leg: Vector3 = (mira_route[2] as Vector3) - (mira_route[1] as Vector3)
	mira.position = (mira_route[2] as Vector3) - second_mira_leg.normalized() * 0.04
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("mira_route_index") == 2)
	assert(main.get("villager_patrol_pauses")[0] >= pickup_length)
	assert(mira_animation.assigned_animation == "PickUp")
	main.call("_process", 1.0)
	var plot_direction := herb_plot.global_position - mira.global_position
	assert(absf(angle_difference(mira_visual.rotation.y, atan2(plot_direction.x, plot_direction.z))) < 0.001)
	main.get("villager_patrol_pauses")[0] = 0.0
	main.call("_physics_process", 1.0 / 60.0)
	var third_mira_leg: Vector3 = (mira_route[3] as Vector3) - (mira_route[2] as Vector3)
	mira.position = (mira_route[3] as Vector3) - third_mira_leg.normalized() * 0.04
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("mira_route_index") == 3)
	assert(main.get("villager_patrol_pauses")[0] >= pickup_length)
	assert(mira_animation.assigned_animation == "PickUp")
	main.call("_process", 1.0)
	var rack_direction: Vector3 = (mira_targets[3] as Vector3) - mira.global_position
	assert(absf(angle_difference(mira_visual.rotation.y, atan2(rack_direction.x, rack_direction.z))) < 0.001)
	main.get("villager_patrol_pauses")[0] = 0.0
	main.call("_physics_process", 1.0 / 60.0)
	var final_mira_leg: Vector3 = (mira_route[0] as Vector3) - (mira_route[3] as Vector3)
	mira.position = (mira_route[0] as Vector3) - final_mira_leg.normalized() * 0.04
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("mira_route_index") == 0)
	assert(mira_animation.assigned_animation == "Idle")
	main.set("time_hour", 18.6)
	main.set("weather_override", "clear")
	main.call("_process", 0.0)
	main.set("mira_routine", "work")
	main.set("mira_route_index", 2)
	main.set("mira_rain_shelter_leg", 0)
	mira.position = (mira_route[2] as Vector3).lerp(mira_route[3] as Vector3, 0.45)
	mira.velocity = Vector3.ZERO
	mira.visible = true
	mira.collision_layer = 1
	mira.collision_mask = 1
	main.get("villager_patrol_pauses")[0] = 0.5
	mira_animation.play("PickUp")
	var mira_pickup_position := mira.position
	main.call("_physics_process", 0.2)
	assert(main.get("mira_routine") == "work")
	assert(is_equal_approx(main.get("villager_patrol_pauses")[0], 0.3))
	assert(mira.position.distance_to(mira_pickup_position) < 0.001)
	assert(mira_animation.assigned_animation == "PickUp")
	main.call("_physics_process", 0.4)
	assert(main.get("mira_routine") == "work")
	assert(main.get("villager_patrol_pauses")[0] == 0.0)
	assert(mira_animation.assigned_animation == "Idle")
	var mira_homeward_start := mira.position
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("mira_routine") == "homeward")
	assert(main.get("mira_rain_shelter_leg") == 0)
	var mira_homeward_step := Vector2(mira.position.x, mira.position.z).distance_to(Vector2(mira_homeward_start.x, mira_homeward_start.z))
	assert(mira_homeward_step > 0.001 and mira_homeward_step < 0.15)
	var mira_homeward_direction: Vector3 = (mira_route[2] as Vector3) - mira_homeward_start
	assert(Vector2(mira.velocity.x, mira.velocity.z).normalized().dot(Vector2(mira_homeward_direction.x, mira_homeward_direction.z).normalized()) > 0.999)
	assert(is_equal_approx(Vector2(mira.velocity.x, mira.velocity.z).length(), 0.52))
	assert(mira_animation.assigned_animation == "Walk")
	mira.position = mira_route[0]
	main.set("mira_route_index", 0)
	main.set("mira_rain_shelter_leg", 0)
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("mira_rain_shelter_leg") == 1)
	mira.position = rain_approach
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("mira_rain_shelter_leg") == 2)
	mira.position = main_constants["MIRA_RAIN_SHELTER"]
	main.set("time_hour", 20.0)
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("mira_routine") == "evening_shelter")
	assert(mira.visible and mira.collision_layer == 1 and mira.collision_mask == 1)
	assert(mira_animation.assigned_animation == "Idle")
	main.call("_process", 1.0)
	var mira_home_look: Vector3 = main_constants["MIRA_HOME_LOOK_TARGET"] - mira.global_position
	assert(absf(angle_difference(mira_visual.rotation.y, atan2(mira_home_look.x, mira_home_look.z))) < 0.001)
	main.set("time_hour", 23.0)
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("mira_routine") == "home")
	assert(not mira.visible and mira.collision_layer == 0 and mira.collision_mask == 0)
	var mira_night_position := mira.position
	main.set("time_hour", 0.0)
	main.call("_physics_process", 1.0)
	assert(mira.position.is_equal_approx(mira_night_position))
	assert(mira.velocity.is_zero_approx())
	player.position = mira.position + Vector3(0.0, 1.0, 1.0)
	main.call("_process", 0.0)
	assert(main.get("nearby_villager") != mira)
	main.set("time_hour", 6.5)
	main.set("weather_override", "light_rain")
	main.call("_process", 0.0)
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("mira_routine") == "home")
	assert(not mira.visible and mira.position.is_equal_approx(mira_night_position))
	main.set("weather_override", "clear")
	main.call("_process", 0.0)
	player.position = Vector3(0.0, 1.0, 30.0)
	main.call("_process", 0.0)
	var mira_morning_start := mira.position
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("mira_routine") == "returning")
	assert(main.get("mira_rain_shelter_leg") == 1)
	assert(mira.visible and mira.collision_layer == 1 and mira.collision_mask == 1)
	var mira_morning_step := Vector2(mira.position.x, mira.position.z).distance_to(Vector2(mira_morning_start.x, mira_morning_start.z))
	assert(mira_morning_step > 0.001 and mira_morning_step < 0.15)
	assert(mira_animation.assigned_animation == "Walk")
	var mira_return_midpoint := (main_constants["MIRA_RAIN_SHELTER"] as Vector3).lerp(rain_approach, 0.45)
	mira.position = mira_return_midpoint
	main.set("mira_routine", "returning")
	main.set("mira_rain_shelter_leg", 1)
	main.set("weather_override", "light_rain")
	main.call("_process", 0.0)
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("mira_routine") == "homeward")
	assert(main.get("mira_rain_shelter_leg") == 2)
	var resumed_shelter_direction: Vector3 = (main_constants["MIRA_RAIN_SHELTER"] as Vector3) - mira_return_midpoint
	assert(Vector2(mira.velocity.x, mira.velocity.z).normalized().dot(Vector2(resumed_shelter_direction.x, resumed_shelter_direction.z).normalized()) > 0.999)
	mira.position = main_constants["MIRA_RAIN_SHELTER"]
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("mira_routine") == "rain_shelter")
	assert(mira.visible and mira_animation.assigned_animation == "Idle")
	main.set("weather_override", "clear")
	main.call("_process", 0.0)
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("mira_routine") == "returning")
	assert(main.get("mira_rain_shelter_leg") == 1)
	mira.position = rain_approach
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("mira_rain_shelter_leg") == 0)
	assert(mira_animation.assigned_animation == "Walk")
	mira.position = mira_route[0]
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("mira_routine") == "work")
	assert(main.get("mira_route_index") == 0)
	assert(is_equal_approx(main.get("villager_patrol_pauses")[0], mira_pauses[0]))
	assert(mira_animation.assigned_animation == "Idle")
	main.set("time_hour", 19.0)
	main.set("mira_routine", "homeward")
	main.set("mira_rain_shelter_leg", 1)
	mira.position = (mira_route[0] as Vector3).lerp(rain_approach, 0.45)
	mira.velocity = Vector3.ZERO
	main.get("villager_patrol_pauses")[0] = 0.0
	player.position = mira.position + Vector3(0.0, 1.0, 1.5)
	main.call("_process", 0.0)
	var mira_talk_homeward_position := mira.position
	main.call("_physics_process", 0.5)
	assert(main.get("nearby_villager") == mira)
	assert(main.get("mira_routine") == "homeward" and main.get("mira_rain_shelter_leg") == 1)
	assert(mira.position.distance_to(mira_talk_homeward_position) < 0.001)
	assert(mira_animation.assigned_animation == "Idle")
	player.position = Vector3(0.0, 1.0, 30.0)
	main.call("_process", 0.0)
	main.call("_physics_process", 1.0 / 60.0)
	assert(mira.position.distance_to(mira_talk_homeward_position) > 0.001)
	assert(mira_animation.assigned_animation == "Walk")
	main.set("time_hour", 9.5)
	main.set("weather_override", "clear")
	main.call("_process", 0.0)
	main.set("mira_routine", "work")
	main.set("mira_route_index", 0)
	main.set("mira_rain_shelter_active", false)
	main.set("mira_rain_shelter_leg", 0)
	mira.position = mira_route[0]
	mira.velocity = Vector3.ZERO
	mira.visible = true
	mira.collision_layer = 1
	mira.collision_mask = 1
	main.get("villager_patrol_pauses")[0] = mira_pauses[0]
	player.position = mira.position + Vector3(0.0, 1.0, 2.0)
	main.call("_process", 0.0)
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("nearby_villager") == mira)
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
	var nia_animation := main.get("villager_animations")[2] as AnimationPlayer
	var nia_public_origin: Vector3 = nia_public_route[0]
	var nia_public_destination: Vector3 = nia_public_route[-1]
	var nia_visual := identity_npc.get_node("Visual") as Node3D
	var nia_interact_length := nia_animation.get_animation("Interact").length
	assert(nia_animation.get_animation("Interact").loop_mode == Animation.LOOP_NONE)
	main.set("time_hour", 9.0)
	main.set("weather_override", "clear")
	main.set("nia_routine", "work")
	main.set("nia_work_index", 1)
	main.set("nia_work_action_done", false)
	identity_npc.position = nia_work_route[2]
	identity_npc.velocity = Vector3.ZERO
	main.get("villager_patrol_pauses")[2] = 0.0
	main.call("_process", 0.0)
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("nia_routine") == "work")
	assert(main.get("nia_work_index") == 2)
	assert(not main.get("nia_work_action_done"))
	var nia_work_action_pause: float = main.get("villager_patrol_pauses")[2]
	assert(nia_work_action_pause >= nia_interact_length)
	assert(nia_animation.assigned_animation == "Interact")
	main.call("_process", 1.0)
	var nia_work_direction: Vector3 = (nia_work_targets[2] as Vector3) - identity_npc.global_position
	assert(absf(angle_difference(nia_visual.rotation.y, atan2(nia_work_direction.x, nia_work_direction.z))) < 0.001)
	var nia_work_action_position := Vector2(identity_npc.position.x, identity_npc.position.z)
	main.call("_physics_process", nia_work_action_pause + 0.05)
	assert(main.get("nia_work_action_done"))
	assert(main.get("villager_patrol_pauses")[2] == 0.0)
	assert(nia_animation.assigned_animation == "Idle")
	assert(Vector2(identity_npc.position.x, identity_npc.position.z).distance_to(nia_work_action_position) < 0.001)
	main.call("_physics_process", 1.0 / 60.0)
	assert(nia_animation.assigned_animation == "Walk")
	assert(Vector2(identity_npc.position.x, identity_npc.position.z).distance_to(nia_work_action_position) > 0.001)
	identity_npc.position = nia_work_route[2]
	identity_npc.velocity = Vector3.ZERO
	main.set("nia_work_index", 2)
	main.set("nia_work_action_done", false)
	main.get("villager_patrol_pauses")[2] = 1.0
	nia_animation.play("Interact")
	player.position = identity_npc.position + Vector3(0.0, 1.0, 1.5)
	main.call("_process", 0.0)
	var nia_talk_position := Vector2(identity_npc.position.x, identity_npc.position.z)
	main.call("_physics_process", 0.5)
	assert(main.get("nearby_villager") == identity_npc)
	assert(nia_animation.assigned_animation == "Idle")
	assert(is_equal_approx(main.get("villager_patrol_pauses")[2], 1.0))
	assert(Vector2(identity_npc.position.x, identity_npc.position.z).distance_to(nia_talk_position) < 0.001)
	player.position = Vector3(0.0, 1.0, 30.0)
	main.call("_process", 0.0)
	main.call("_physics_process", 0.1)
	assert(nia_animation.assigned_animation == "Interact")
	var nia_resumed_action_pause: float = main.get("villager_patrol_pauses")[2]
	assert(nia_resumed_action_pause >= nia_interact_length + 0.15)
	main.call("_physics_process", nia_resumed_action_pause + 0.05)
	assert(main.get("nia_work_action_done"))
	assert(main.get("villager_patrol_pauses")[2] == 0.0)
	assert(nia_animation.assigned_animation == "Idle")
	assert(Vector2(identity_npc.position.x, identity_npc.position.z).distance_to(nia_talk_position) < 0.001)
	main.call("_physics_process", 1.0 / 60.0)
	assert(nia_animation.assigned_animation == "Walk")
	assert(Vector2(identity_npc.position.x, identity_npc.position.z).distance_to(nia_talk_position) > 0.001)
	main.set("time_hour", 11.0)
	main.set("weather_override", "light_rain")
	main.set("nia_routine", "work")
	main.set("nia_work_index", 2)
	main.set("nia_work_action_done", false)
	identity_npc.position = nia_work_route[2]
	identity_npc.velocity = Vector3.ZERO
	main.get("villager_patrol_pauses")[2] = 1.0
	nia_animation.play("Interact")
	player.position = identity_npc.position + Vector3(0.0, 1.0, 1.5)
	main.call("_process", 0.0)
	var nia_rain_talk_position := Vector2(identity_npc.position.x, identity_npc.position.z)
	main.call("_physics_process", 0.25)
	assert(main.get("nia_routine") == "work")
	assert(Vector2(identity_npc.position.x, identity_npc.position.z).distance_to(nia_rain_talk_position) < 0.001)
	assert(nia_animation.assigned_animation == "Idle")
	player.position = Vector3(0.0, 1.0, 30.0)
	main.call("_process", 0.0)
	var nia_day_rain_departure := identity_npc.position
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("nia_routine") == "day_rain_shelter")
	assert(main.get("nia_route_index") == nia_day_rain_route.size() - 1)
	var nia_day_rain_step := Vector2(identity_npc.position.x, identity_npc.position.z).distance_to(Vector2(nia_day_rain_departure.x, nia_day_rain_departure.z))
	assert(nia_day_rain_step > 0.001 and nia_day_rain_step < 0.15)
	var nia_day_rain_direction := Vector2(identity_npc.position.x - nia_day_rain_departure.x, identity_npc.position.z - nia_day_rain_departure.z).normalized()
	var nia_day_rain_expected_direction := Vector2(nia_day_rain_route[-1].x - nia_day_rain_departure.x, nia_day_rain_route[-1].z - nia_day_rain_departure.z).normalized()
	assert(nia_day_rain_direction.dot(nia_day_rain_expected_direction) > 0.999)
	assert(is_equal_approx(Vector2(identity_npc.velocity.x, identity_npc.velocity.z).length(), 0.72))
	assert(main.get("villager_patrol_pauses")[2] == 0.0)
	assert(nia_animation.assigned_animation == "Walk")
	identity_npc.position = nia_day_rain_route[-1]
	main.set("nia_route_index", nia_day_rain_route.size() - 1)
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("nia_routine") == "day_rain_shelter")
	assert(nia_animation.assigned_animation == "Idle")
	main.call("_process", 1.0)
	var nia_day_shelter_direction: Vector3 = main_constants["NIA_DAY_RAIN_LOOK_TARGET"] - identity_npc.global_position
	assert(absf(angle_difference(nia_visual.rotation.y, atan2(nia_day_shelter_direction.x, nia_day_shelter_direction.z))) < 0.001)
	main.set("weather_override", "clear")
	main.call("_process", 0.0)
	var nia_day_rain_return_start := identity_npc.position
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("nia_routine") == "day_rain_returning")
	var nia_day_rain_return_step := Vector2(identity_npc.position.x, identity_npc.position.z).distance_to(Vector2(nia_day_rain_return_start.x, nia_day_rain_return_start.z))
	assert(nia_day_rain_return_step > 0.001 and nia_day_rain_return_step < 0.15)
	assert(nia_animation.assigned_animation == "Walk")
	var nia_mid_return_steps := 0
	while identity_npc.position.distance_to(nia_day_rain_route[-1]) <= 0.14 and nia_mid_return_steps < 20:
		main.call("_physics_process", 1.0 / 60.0)
		nia_mid_return_steps += 1
	assert(main.get("nia_routine") == "day_rain_returning")
	assert(identity_npc.position.distance_to(nia_day_rain_route[-1]) > 0.14)
	assert(identity_npc.position.distance_to(nia_day_rain_route[0]) > 0.14)
	var nia_before_rain_resume := identity_npc.position
	main.set("weather_override", "light_rain")
	main.call("_process", 0.0)
	assert(is_equal_approx(main.get("weather_rain_amount"), 1.0))
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("nia_routine") == "day_rain_shelter", "unexpected Nia routine after rain resumed: %s" % main.get("nia_routine"))
	var nia_rain_resume_step := Vector2(identity_npc.position.x, identity_npc.position.z).distance_to(Vector2(nia_before_rain_resume.x, nia_before_rain_resume.z))
	assert(nia_rain_resume_step > 0.001 and nia_rain_resume_step < 0.15)
	assert(nia_animation.assigned_animation == "Walk")
	main.set("weather_override", "clear")
	main.call("_process", 0.0)
	assert(is_equal_approx(main.get("weather_rain_amount"), 0.0))
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("nia_routine") == "day_rain_returning")
	identity_npc.position = nia_day_rain_route[0]
	main.set("nia_route_index", nia_day_rain_route.size() - 1)
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("nia_routine") == "work")
	assert(main.get("nia_work_index") == 0)
	assert(main.get("villager_patrol_pauses")[2] == 0.0)
	assert(nia_animation.assigned_animation == "Idle")
	main.set("time_hour", 11.0)
	main.set("weather_override", "clear")
	main.set("nia_routine", "work")
	main.set("nia_work_index", 1)
	main.set("nia_work_action_done", false)
	identity_npc.position = nia_work_route[1]
	identity_npc.velocity = Vector3.ZERO
	main.get("villager_patrol_pauses")[2] = 0.0
	var nia_errand_start := identity_npc.position
	main.call("_process", 0.0)
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("nia_routine") == "errand")
	assert(main.get("nia_route_index") == 0)
	var nia_errand_step := Vector2(identity_npc.position.x, identity_npc.position.z).distance_to(Vector2(nia_errand_start.x, nia_errand_start.z))
	assert(nia_errand_step > 0.001)
	assert(nia_errand_step < 0.15, "Nia errand first XZ step %.4f from %s to %s" % [nia_errand_step, nia_errand_start, identity_npc.position])
	assert(is_equal_approx(Vector2(identity_npc.velocity.x, identity_npc.velocity.z).length(), 0.72))
	identity_npc.position = nia_public_destination
	main.set("nia_route_index", nia_public_route.size() - 1)
	main.get("villager_patrol_pauses")[2] = 0.0
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("nia_route_index") == nia_public_route.size() - 1)
	var nia_pickup_length := nia_animation.get_animation("PickUp").length
	assert(main.get("nia_errand_action_done") == false)
	assert(main.get("villager_patrol_pauses")[2] >= nia_pickup_length)
	assert(nia_animation.assigned_animation == "PickUp")
	main.call("_physics_process", nia_pickup_length + 0.2)
	assert(main.get("nia_errand_action_done"))
	assert(main.get("villager_patrol_pauses")[2] == 0.0)
	assert(nia_animation.assigned_animation == "Idle")
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("nia_errand_action_done"))
	assert(nia_animation.assigned_animation == "Idle")
	main.call("_process", 1.0)
	var nia_public_visual := identity_npc.get_node("Visual") as Node3D
	var nia_public_direction: Vector3 = main_constants["NIA_PUBLIC_LOOK_TARGET"] - identity_npc.global_position
	assert(absf(angle_difference(nia_public_visual.rotation.y, atan2(nia_public_direction.x, nia_public_direction.z))) < 0.001)
	main.set("time_hour", 12.5)
	main.call("_update_nia_routine", identity_npc, nia_animation)
	assert(main.get("nia_routine") == "returning")
	assert(nia_animation.assigned_animation == "Walk")
	var nia_return_start := identity_npc.position
	main.call("_physics_process", 1.0 / 60.0)
	assert(identity_npc.position.distance_to(nia_return_start) > 0.001)
	var nia_work_reset: Vector3 = main.get("villager_patrol_origins")[2]
	identity_npc.position = nia_work_reset
	main.set("nia_route_index", nia_public_route.size() - 1)
	main.get("villager_patrol_pauses")[2] = 0.0
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("nia_routine") == "work")
	assert(identity_npc.position.is_equal_approx(nia_work_reset))
	assert(main.get("nia_work_index") == 0)
	assert(nia_animation.assigned_animation == "Idle")
	main.set("time_hour", 19.0)
	main.set("weather_override", "clear")
	main.set("nia_routine", "work")
	identity_npc.position = Vector3(5.6, 0.0, -4.2)
	main.call("_process", 0.0)
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("nia_routine") == "hearth")
	assert(identity_npc.visible and identity_npc.collision_layer == 1)
	assert(identity_npc.position.distance_to(Vector3(5.6, 0.0, -4.2)) < 0.01)
	assert(nia_animation.assigned_animation == "Idle")
	main.call("_process", 1.0)
	var nia_hearth_direction := Vector3(4.3, 0.0, -5.5) - identity_npc.global_position
	assert(absf(angle_difference(nia_visual.rotation.y, atan2(nia_hearth_direction.x, nia_hearth_direction.z))) < 0.001)
	main.set("weather_override", "light_rain")
	main.call("_process", 0.0)
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("nia_routine") == "rain_shelter")
	assert(nia_animation.assigned_animation == "Walk")
	identity_npc.position = Vector3(8.6, 0.0, -4.2)
	main.call("_physics_process", 1.0 / 60.0)
	assert(nia_animation.assigned_animation == "Idle")
	main.call("_process", 1.0)
	var nia_shelter_direction := Vector3(9.0, 0.0, -8.0) - identity_npc.global_position
	assert(absf(angle_difference(nia_visual.rotation.y, atan2(nia_shelter_direction.x, nia_shelter_direction.z))) < 0.001)
	main.set("time_hour", 23.0)
	identity_npc.position = Vector3(-6.5, 0.0, 6.4)
	main.call("_physics_process", 1.0 / 60.0)
	assert(main.get("nia_routine") == "home")
	assert(not identity_npc.visible and identity_npc.collision_layer == 0 and identity_npc.collision_mask == 0)
	player.position = identity_npc.position + Vector3(0.0, 1.0, 1.0)
	main.call("_process", 0.0)
	assert(main.get("nearby_villager") != identity_npc)
	main.set("time_hour", 9.5)
	main.set("weather_override", "clear")
	player.position = Vector3(0.0, 1.0, 30.0)
	main.call("_process", 0.0)
	var nia_home_exit := identity_npc.position
	assert(main.call("_update_nia_routine", identity_npc, nia_animation) as bool)
	assert(main.get("nia_routine") == "work")
	assert(identity_npc.visible and identity_npc.collision_layer == 1 and identity_npc.collision_mask == 1)
	assert(identity_npc.position.is_equal_approx(nia_home_exit))
	assert(nia_animation.assigned_animation == "Walk")
	var nia_resume_position := identity_npc.position
	main.call("_physics_process", 1.0 / 60.0)
	var nia_resume_step := Vector2(identity_npc.position.x, identity_npc.position.z).distance_to(Vector2(nia_resume_position.x, nia_resume_position.z))
	assert(nia_resume_step > 0.001)
	assert(nia_resume_step < 0.1)
	assert(is_equal_approx(Vector2(identity_npc.velocity.x, identity_npc.velocity.z).length(), 0.46))
	assert(nia_animation.assigned_animation == "Walk")
	var smoke_puffs: Array = main.get("smoke_puffs")
	assert(smoke_puffs.size() == 12)
	assert(main.get("smoke_origins").size() == 12)
	assert(main.get("smoke_drift_scales").size() == 12)
	assert(main.get("smoke_size_scales").size() == 12)
	assert(main.get("smoke_opacity_scales").size() == 12)
	for hearth_smoke_index in range(9, 12):
		assert(is_equal_approx(main.get("smoke_drift_scales")[hearth_smoke_index], 1.6))
		assert(is_equal_approx(main.get("smoke_size_scales")[hearth_smoke_index], 1.15))
		assert(is_equal_approx(main.get("smoke_opacity_scales")[hearth_smoke_index], 1.2))
	var hearth := main.get_node_or_null("VillageHearth")
	assert(hearth != null)
	assert((hearth as Node3D).position.is_equal_approx(Vector3(4.3, 0.0, -5.5)))
	assert(hearth.get_node_or_null("FireEmber") is CSGCylinder3D)
	assert(hearth.get_node_or_null("HearthLight") is OmniLight3D)
	assert(hearth.get_node_or_null("HearthBenchEast/Seat") is CSGCylinder3D)
	assert(hearth.get_node_or_null("HearthBenchSouth/Seat") is CSGCylinder3D)
	assert(hearth.get_node_or_null("HearthWoodCrate") is Node3D)
	assert(main.get("hearth_flames").size() == 3)
	main.set("portal_time", 0.0)
	main.call("_process", 0.0)
	var first_mote: MeshInstance3D = main.get("portal_motes")[0]
	var mote_position := first_mote.position
	var first_plant := wind_nodes[0] as Node3D
	var plant_rotation := first_plant.rotation
	var first_herb_bundle := herb_bundles[0]
	var first_herb_bundle_rotation := first_herb_bundle.rotation
	var herb_left_post_transform := (drying_rack.get_node("LeftPost") as Node3D).transform
	var herb_right_post_transform := (drying_rack.get_node("RightPost") as Node3D).transform
	var herb_crossbar_transform := (drying_rack.get_node("Crossbar") as Node3D).transform
	var rain_awning_transform := rain_awning.transform
	var cloth_left_post_transform := (weaving_line.get_node("LeftPost") as Node3D).transform
	var cloth_right_post_transform := (weaving_line.get_node("RightPost") as Node3D).transform
	var cloth_crossbar_transform := (weaving_line.get_node("Crossbar") as Node3D).transform
	var first_puff := smoke_puffs[0] as MeshInstance3D
	var puff_position := first_puff.position
	var puff_transparency := first_puff.transparency
	var first_flame := main.get("hearth_flames")[0] as CSGPolygon3D
	var second_flame := main.get("hearth_flames")[1] as CSGPolygon3D
	assert(first_flame.polygon.size() == 7 and not first_flame.use_collision)
	assert(first_flame.polygon[4].y > 0.4)
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
	assert(first_herb_bundle.rotation.distance_to(first_herb_bundle_rotation) > 0.001)
	assert(first_puff.position.distance_to(puff_position) > 0.01)
	assert(not is_equal_approx(first_puff.transparency, puff_transparency))
	assert(first_flame.position.distance_to(flame_position) > 0.01)
	assert(not first_flame.scale.is_equal_approx(second_flame.scale))
	assert(not is_equal_approx((main.get("hearth_light") as OmniLight3D).light_energy, hearth_energy))
	assert(first_ripple.scale.distance_to(ripple_scale) > 0.01)
	assert(not is_equal_approx(first_ripple.transparency, ripple_transparency))
	var animation_time: float = main.get("portal_time")
	main.set("portal_time", 4.95)
	main.call("_process", 0.0)
	var ripple_before_wrap := first_ripple.transparency
	main.set("portal_time", 5.05)
	main.call("_process", 0.0)
	var ripple_after_wrap := first_ripple.transparency
	assert(ripple_before_wrap > 0.97 and ripple_after_wrap > 0.97)
	assert(absf(ripple_before_wrap - ripple_after_wrap) < 0.001)
	main.set("portal_time", 2.5)
	main.call("_process", 0.0)
	assert(first_ripple.transparency > 0.35 and first_ripple.transparency < 0.45)
	main.set("portal_time", animation_time)
	main.call("_process", 0.0)
	assert(first_villager.position.distance_to(villager_position) > 0.001)
	assert(not is_equal_approx(main.get("mistcap_material").emission_energy_multiplier, mistcap_energy))
	assert(not is_equal_approx(first_mistcap_light.light_energy, mistcap_light_energy))
	assert(first_fog.position.distance_to(fog_position) > 0.001)
	assert(not is_equal_approx(first_fog.transparency, fog_transparency))
	main.set("portal_time", 3.25)
	main.set("weather_override", "clear")
	main.call("_process", 0.0)
	var clear_cloth_sway := Vector2(cloth_rose.rotation.x, cloth_rose.rotation.z).length()
	var clear_herb_sway := Vector2(first_herb_bundle.rotation.x, first_herb_bundle.rotation.z).length()
	assert(clear_cloth_sway > 0.001 and clear_herb_sway > 0.001)
	main.set("portal_time", 3.25)
	main.set("weather_override", "light_rain")
	main.call("_process", 0.0)
	var rain_cloth_sway := Vector2(cloth_rose.rotation.x, cloth_rose.rotation.z).length()
	var rain_herb_sway := Vector2(first_herb_bundle.rotation.x, first_herb_bundle.rotation.z).length()
	assert(is_equal_approx(rain_cloth_sway, clear_cloth_sway * 1.45))
	assert(is_equal_approx(rain_herb_sway, clear_herb_sway * 1.45))
	assert((drying_rack.get_node("LeftPost") as Node3D).transform.is_equal_approx(herb_left_post_transform))
	assert((drying_rack.get_node("RightPost") as Node3D).transform.is_equal_approx(herb_right_post_transform))
	assert((drying_rack.get_node("Crossbar") as Node3D).transform.is_equal_approx(herb_crossbar_transform))
	assert(rain_awning.transform.is_equal_approx(rain_awning_transform))
	assert((weaving_line.get_node("LeftPost") as Node3D).transform.is_equal_approx(cloth_left_post_transform))
	assert((weaving_line.get_node("RightPost") as Node3D).transform.is_equal_approx(cloth_right_post_transform))
	assert((weaving_line.get_node("Crossbar") as Node3D).transform.is_equal_approx(cloth_crossbar_transform))
	main.set("weather_override", "clear")
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
	assert(portal_surface_material.get_shader_parameter("reaction_strength") > 0.99)
	assert((main.get("portal_ring") as Node3D).scale.x > near_ring_scale)
	assert(portal_light.light_energy > near_light_energy)
	main.call("_process", 0.25)
	assert(main.get("portal_reaction_time") < 1.0)
	assert(lore.visible)
	assert(lore.text.contains("异界气息"))
	assert(not prompt.visible)
	assert(main.get_child_count() > 20)
	for player_mesh_node in player.get_node("Visual").find_children("*", "MeshInstance3D", true, false):
		(player_mesh_node as MeshInstance3D).material_overlay = null
	main.free()
	print("SMOKE TEST PASSED")
	quit(0)


func _visual_height(root_node: Node3D) -> float:
	var bounds := AABB()
	var has_bounds := false
	for mesh_node in root_node.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := mesh_node as MeshInstance3D
		if mesh_instance.name == "OtherworldMark":
			continue
		var mesh_bounds: AABB = mesh_instance.global_transform * mesh_instance.get_aabb()
		bounds = bounds.merge(mesh_bounds) if has_bounds else mesh_bounds
		has_bounds = true
	assert(has_bounds)
	return bounds.size.y
