extends Node3D

const PlayerScript = preload("res://scripts/player.gd")
const MistValleyAmbience = preload("res://assets/audio/mist_valley_ambience.ogg")
const PortalHum = preload("res://assets/audio/portal_hum.ogg")
const PortalReact = preload("res://assets/audio/portal_react.ogg")
const HearthFire = preload("res://assets/audio/hearth_fire.ogg")
const MistCurtainShader = preload("res://shaders/mist_curtain.gdshader")
const PortalSurfaceShader = preload("res://shaders/portal_surface.gdshader")
const MeadowGrassShader = preload("res://shaders/meadow_grass.gdshader")
const TreeCanopyShader = preload("res://shaders/tree_canopy.gdshader")
const MeadowGrassScene = preload("res://assets/quaternius/nature/Grass_Common_Tall.gltf")
const MutedRoofTiles = preload("res://assets/quaternius/village/T_RoundTiles_BaseColor_Muted.png")
const MutedBushLeaves = preload("res://assets/quaternius/nature/Leaves_TwistedTree_C_Muted.png")
const DrifterCharacter = preload("res://scenes/player/drifter_visual.tscn")
const MiraCharacter = preload("res://scenes/npc/mira_visual.tscn")
const TorenCharacter = preload("res://scenes/npc/toren_visual.tscn")
const NiaCharacter = preload("res://scenes/npc/nia_visual.tscn")
const ValleyBoundaryScene = preload("res://scenes/world/valley_boundary.tscn")
const HERB_PLOT_POSITION := Vector3(-14.8, 0.0, -10.0)
const DAY_DURATION_SECONDS := 1800.0
const BUTTERFLY_SEED := 3131
const FIREFLY_SEED := 6262
const BUTTERFLY_COUNT := 7
const FIREFLY_COUNT := 14
const FALLING_LEAF_COUNT := 12
const FALLING_LEAF_SEED := 20260903
const FALLING_LEAF_CLUSTERS := [
	Vector2(-21.0, -24.4), Vector2(18.0, 3.0),
	Vector2(-16.0, 17.0), Vector2(8.0, 23.0),
]
const WEATHER_SEED := 20260902
const WEATHER_TRANSITION_HOURS := 0.75
const WEATHER_STATES := ["clear", "cloudy", "mist", "light_rain"]
const ROOF_FADE_ENTER_PLAYER_DISTANCE := 5.8
const ROOF_FADE_EXIT_PLAYER_DISTANCE := 6.3
const ROOF_FADE_ENTER_VIEW_DISTANCE := 3.0
const ROOF_FADE_EXIT_VIEW_DISTANCE := 3.6
const ROOF_FADE_EXIT_PROJECTION_MARGIN := 0.05
const TOREN_WATCH_ROUTE := [
	Vector3(3.0, 0.0, -15.2),
	Vector3(2.7, 0.0, -19.2),
	Vector3(4.6, 0.0, -13.3),
]
const TOREN_WATCH_TARGETS := [
	Vector3(-1.5, 0.0, -15.0),
	Vector3(0.4, 0.0, -25.0),
	Vector3(0.0, 0.0, -7.0),
]
const TOREN_WATCH_PAUSES := [4.8, 6.1, 3.7]
const TOREN_WATCH_SPEED := 0.52
const NIA_HEARTH_ROUTE := [
	Vector3(-4.0, 0.0, 5.5), Vector3(-2.0, 0.0, 2.0), Vector3(1.0, 0.0, -1.0),
	Vector3(3.5, 0.0, -3.5), Vector3(5.6, 0.0, -4.2),
]
const NIA_RAIN_ROUTE := [
	Vector3(-4.0, 0.0, 5.5), Vector3(-2.0, 0.0, 2.0), Vector3(1.0, 0.0, -1.0),
	Vector3(3.5, 0.0, -3.5), Vector3(8.6, 0.0, -4.2),
]
const NIA_HOME_ROUTE := [
	Vector3(3.5, 0.0, -3.5), Vector3(1.0, 0.0, -1.0), Vector3(-2.0, 0.0, 2.0),
	Vector3(-4.0, 0.0, 5.5), Vector3(-6.5, 0.0, 6.4),
]

var ground_material := _material(Color("6f8f65"), 0.95)
var path_material := _material(Color("9a8466"), 1.0)
var stone_material := _material(Color("66706c"), 0.9)
var plaster_material := _material(Color("c6b99a"), 0.95)
var interior_floor_material := _material(Color("736858"), 1.0)
var portal_material: StandardMaterial3D
var portal_surface_material: ShaderMaterial
var portal_ground_rune_material: StandardMaterial3D
var portal_mote_material: StandardMaterial3D
var portal_ring: CSGTorus3D
var portal_light: OmniLight3D
var portal_hum: AudioStreamPlayer3D
var portal_react_player: AudioStreamPlayer3D
var portal_reaction_time := 0.0
var portal_time := 0.0
var portal_center := Vector3.ZERO
var portal_motes: Array[MeshInstance3D] = []
var wind_nodes: Array[Node3D] = []
var seasonal_bushes: Array[Node3D] = []
var seasonal_bush_materials: Array[StandardMaterial3D] = []
var portal_prompt: Label
var portal_lore: Label
var portal_nearby := false
var portal_lore_tween: Tween
var smoke_puffs: Array[MeshInstance3D] = []
var smoke_origins: Array[Vector3] = []
var smoke_drift_scales: Array[float] = []
var smoke_size_scales: Array[float] = []
var smoke_opacity_scales: Array[float] = []
var smoke_mesh: QuadMesh
var smoke_material: StandardMaterial3D
var house_count := 0
var house_fade_materials: Array[StandardMaterial3D] = []
var house_fade_alphas: Array[float] = []
var house_fade_house_indices: Array[int] = []
var house_roofs_faded: Array[bool] = []
var houses: Array[Node3D] = []
var hearth_flames: Array[CSGPolygon3D] = []
var hearth_flame_origins: Array[Vector3] = []
var hearth_light: OmniLight3D
var hearth_ember_material: StandardMaterial3D
var hearth_flame_material: StandardMaterial3D
var pond_ripples: Array[MeshInstance3D] = []
var villager_visuals: Array[Node3D] = []
var villager_rotations: Array[float] = []
var villagers: Array[CharacterBody3D] = []
var villager_labels: Array[Label3D] = []
var villager_patrol_origins: Array[Vector3] = []
var villager_patrol_axes: Array[Vector3] = []
var villager_patrol_directions: Array[float] = []
var villager_patrol_pauses: Array[float] = []
var villager_animations: Array[AnimationPlayer] = []
var toren_watch_index := 0
var nia_routine := "work"
var nia_route_index := 0
var nearby_villager: CharacterBody3D
var mistcap_material: StandardMaterial3D
var mistcap_caps: Array[MeshInstance3D] = []
var mistcap_lights: Array[OmniLight3D] = []
var window_glows: Array[OmniLight3D] = []
var window_glass_materials: Array[StandardMaterial3D] = []
var mist_pass_lights: Array[OmniLight3D] = []
var mist_pass_rune_material: StandardMaterial3D
var meadow_roads: Array = []
var meadow_grass: MultiMeshInstance3D
var butterflies: Node3D
var fireflies: Node3D
var falling_leaves: Node3D
var butterfly_material: StandardMaterial3D
var firefly_material: StandardMaterial3D
var falling_leaf_materials: Array[StandardMaterial3D] = []
var tree_canopies: Array[MeshInstance3D] = []
var tree_canopy_materials: Array[ShaderMaterial] = []
var fog_banks: Array[MeshInstance3D] = []
var fog_bank_origins: Array[Vector3] = []
var environment_settings: Environment
var sun: DirectionalLight3D
var player_fill_light: SpotLight3D
var time_hour := 9.5
var time_running := true
var weather_seed := WEATHER_SEED
var weather_running := true
var weather_override := ""
var weather_schedule: Array = []
var weather_schedule_index := 0
var weather_segment_elapsed := 0.0
var weather_state := "clear"
var weather_target_state := "clear"
var weather_blend := 0.0
var weather_rain_amount := 0.0
var weather_wind_amount := 0.62
var rain_field: Node3D
var rain_streaks: Array[MeshInstance3D] = []
var rain_params: Array[Dictionary] = []
var rain_material: StandardMaterial3D
var day_keys := [
	[0.0, 42.0, 150.0, Color("8fa8cc"), 0.16, Color("40516b"), 0.50, Color("33445d"), 0.008, Color("26354a"), 0.28],
	[4.5, 30.0, 120.0, Color("8fa8cc"), 0.14, Color("45566f"), 0.52, Color("3b4a61"), 0.009, Color("2b3a4e"), 0.26],
	[6.0, 18.0, 62.0, Color("dfb68f"), 0.52, Color("75848b"), 0.72, Color("9aa19d"), 0.0075, Color("75858a"), 0.26],
	[7.5, 28.0, 25.0, Color("f1cca0"), 0.68, Color("a8b4b0"), 0.58, Color("b7bbb0"), 0.0075, Color("91a39f"), 0.38],
	[9.5, 52.0, -28.0, Color("fff0ce"), 0.72, Color("bfcbb8"), 0.42, Color("a9bcba"), 0.006, Color("839da3"), 0.58],
	[12.0, 60.0, -4.0, Color("fff0ce"), 0.74, Color("bfcbb8"), 0.42, Color("a9bcba"), 0.006, Color("839da3"), 0.56],
	[16.5, 34.0, -20.0, Color("ffe2b0"), 0.72, Color("bcbfae"), 0.48, Color("b3bcb0"), 0.007, Color("8fa09b"), 0.46],
	[18.2, 20.0, -48.0, Color("dca77f"), 0.56, Color("687786"), 0.68, Color("8e8c89"), 0.0085, Color("69747b"), 0.25],
	[19.5, 16.0, -60.0, Color("a891a2"), 0.24, Color("566275"), 0.56, Color("626878"), 0.0095, Color("444d5f"), 0.24],
	[21.0, 36.0, -110.0, Color("8fa8cc"), 0.15, Color("40516b"), 0.50, Color("33445d"), 0.008, Color("26354a"), 0.28],
	[24.0, 42.0, 150.0, Color("8fa8cc"), 0.16, Color("40516b"), 0.50, Color("33445d"), 0.008, Color("26354a"), 0.28],
]


func _ready() -> void:
	_build_world()
	_build_player()
	_build_weather()
	_build_villagers()
	_build_opening()
	_build_portal_interaction()
	_build_audio()
	_apply_time_of_day()


func _is_house_roof_occluding(camera_xz: Vector2, player_xz: Vector2, house_xz: Vector2, was_occluding: bool) -> bool:
	var player_distance_limit := ROOF_FADE_EXIT_PLAYER_DISTANCE if was_occluding else ROOF_FADE_ENTER_PLAYER_DISTANCE
	if house_xz.distance_to(player_xz) >= player_distance_limit:
		return false
	var camera_to_player := player_xz - camera_xz
	var segment_length_squared := camera_to_player.length_squared()
	if segment_length_squared <= 0.001:
		return false
	var projection := (house_xz - camera_xz).dot(camera_to_player) / segment_length_squared
	var projection_margin := ROOF_FADE_EXIT_PROJECTION_MARGIN if was_occluding else 0.0
	if projection <= -projection_margin or projection >= 1.0 + projection_margin:
		return false
	var closest_point := camera_xz + camera_to_player * clampf(projection, 0.0, 1.0)
	var view_distance_limit := ROOF_FADE_EXIT_VIEW_DISTANCE if was_occluding else ROOF_FADE_ENTER_VIEW_DISTANCE
	return house_xz.distance_to(closest_point) < view_distance_limit


func _process(delta: float) -> void:
	if portal_ring == null:
		return
	if time_running:
		time_hour = fposmod(time_hour + delta * 24.0 / DAY_DURATION_SECONDS, 24.0)
	_update_weather(delta)
	_apply_time_of_day()
	portal_time += delta
	_animate_ecosystem()
	_animate_tree_canopies()
	_animate_weather()
	portal_reaction_time = maxf(portal_reaction_time - delta * 1.5, 0.0)
	var pulse: float = sin(portal_time * 2.2)
	var reaction := portal_reaction_time
	var proximity := _portal_proximity()
	var night_focus := _night_focus(time_hour)
	_update_villager_interaction()
	portal_ring.scale = Vector3.ONE * (1.0 + pulse * 0.035 + reaction * 0.12)
	portal_material.emission_energy_multiplier = (0.75 + pulse * 0.12 + proximity * 0.3 + reaction * 0.65) * lerpf(0.88, 1.35, night_focus)
	portal_surface_material.set_shader_parameter("reaction_strength", clampf(reaction + proximity * 0.16, 0.0, 1.0))
	portal_surface_material.set_shader_parameter("time_glow", lerpf(0.82, 1.38, night_focus))
	portal_ground_rune_material.emission_energy_multiplier = 0.48 * lerpf(0.72, 1.35, night_focus)
	portal_mote_material.emission_energy_multiplier = 1.8 * lerpf(0.72, 1.28, night_focus)
	portal_light.light_energy = (0.65 + pulse * 0.15 + proximity * 0.45 + reaction * 0.75) * lerpf(0.82, 1.55, night_focus)
	portal_hum.volume_db = lerpf(-24.0, -11.0, proximity)
	var mote_count := portal_motes.size()
	for index in mote_count:
		var phase := portal_time * 0.45 + TAU * float(index) / float(mote_count)
		var rise := fmod(portal_time * 0.22 + float(index) * 0.31, 1.0)
		var radius := 2.1 + sin(float(index) * 1.7) * 0.55
		var mote := portal_motes[index]
		mote.position = portal_center + Vector3(cos(phase) * radius, 0.45 + rise * 2.7, sin(phase) * radius * 0.55)
		mote.scale = Vector3.ONE * (0.8 + sin(portal_time * 1.8 + float(index)) * 0.18 + reaction * 0.5)
	for index in wind_nodes.size():
		var plant := wind_nodes[index]
		var gust_wave := (sin(portal_time * 0.42 + float(index) * 0.09) + 1.0) * 0.5
		var gust_strength := 1.0 + pow(gust_wave, 6.0) * 0.85
		plant.rotation.z = sin(portal_time * 0.85 + float(index) * 0.73) * 0.027 * gust_strength
		plant.rotation.x = cos(portal_time * 0.7 + float(index) * 0.51) * 0.013 * gust_strength
	for index in smoke_puffs.size():
		var phase := fmod(portal_time * 0.12 + float(index % 3) * 0.34 + float(index / 3) * 0.13, 1.0)
		var puff := smoke_puffs[index]
		var is_hearth_smoke := index >= smoke_puffs.size() - 3
		var rain_smoke_drift := lerpf(1.0, 1.1, weather_rain_amount) if is_hearth_smoke else 1.0
		var rain_smoke_opacity := lerpf(1.0, 0.8, weather_rain_amount) if is_hearth_smoke else 1.0
		var drift_scale := smoke_drift_scales[index] * rain_smoke_drift
		puff.position = smoke_origins[index] + Vector3(
			sin(portal_time * 0.52 + index) * 0.3 * drift_scale,
			phase * 2.25,
			cos(portal_time * 0.41 + index) * 0.16 * drift_scale
		)
		puff.scale = Vector3.ONE * (0.42 + phase * 0.82) * smoke_size_scales[index]
		var smoke_fade := 0.02 + pow(phase, 1.55) * 0.92
		puff.transparency = clampf(1.0 - (1.0 - smoke_fade) * smoke_opacity_scales[index] * rain_smoke_opacity, 0.0, 1.0)
	var rain_flame_scale := lerpf(1.0, 0.88, weather_rain_amount)
	for index in hearth_flames.size():
		var primary := sin(portal_time * (4.65 + float(index) * 0.55) + float(index) * 1.8)
		var secondary := sin(portal_time * (7.2 + float(index) * 0.37) + float(index) * 0.9)
		var flicker := primary * 0.72 + secondary * 0.28
		var sway := sin(portal_time * (3.8 + float(index) * 0.33) + float(index) * 2.1)
		var flame := hearth_flames[index]
		flame.position = hearth_flame_origins[index] + Vector3(sway * 0.045, flicker * 0.075, secondary * 0.035) * rain_flame_scale
		flame.scale = Vector3(0.42 - flicker * 0.04, (0.78 + flicker * 0.1) * rain_flame_scale, 0.42 - flicker * 0.04)
	if hearth_light != null:
		hearth_light.light_energy = (0.78 + sin(portal_time * 3.4) * 0.07 + sin(portal_time * 5.7 + 1.1) * 0.05) * lerpf(1.0, 1.8, night_focus) * lerpf(1.0, 0.92, weather_rain_amount)
		hearth_ember_material.emission_energy_multiplier = 1.5 * lerpf(0.9, 1.35, night_focus) * lerpf(1.0, 0.96, weather_rain_amount)
		hearth_flame_material.emission_energy_multiplier = 2.2 * lerpf(0.92, 1.32, night_focus) * lerpf(1.0, 0.94, weather_rain_amount)
	for window_glow in window_glows:
		window_glow.light_energy = 0.14 * lerpf(0.68, 1.9, night_focus)
	for glass_material in window_glass_materials:
		glass_material.emission_energy_multiplier = 0.18 * lerpf(0.64, 1.65, night_focus)
	if player_fill_light != null:
		player_fill_light.light_energy = lerpf(0.0, 4.0, night_focus)
	for index in pond_ripples.size():
		var phase := fmod(portal_time * 0.2 + float(index) * 0.5, 1.0)
		var ripple_visibility := sin(PI * phase)
		var ripple := pond_ripples[index]
		ripple.scale = Vector3(0.45 + phase * 1.65, 1.0, 0.32 + phase * 1.1)
		ripple.transparency = 1.0 - ripple_visibility * 0.62
	if mistcap_material != null:
		mistcap_material.emission_energy_multiplier = (0.42 + sin(portal_time * 1.35) * 0.1) * lerpf(0.66, 1.55, night_focus)
	for index in mistcap_lights.size():
		mistcap_lights[index].light_energy = (0.12 + sin(portal_time * 1.35 + float(index) * 0.9) * 0.035) * lerpf(0.62, 1.85, night_focus)
	for mist_pass_light in mist_pass_lights:
		mist_pass_light.light_energy = 0.42 * lerpf(0.68, 1.55, night_focus)
	if mist_pass_rune_material != null:
		mist_pass_rune_material.emission_energy_multiplier = 1.5 * lerpf(0.7, 1.4, night_focus)
	for index in fog_banks.size():
		var fog_phase := portal_time * 0.16 + float(index) * 1.15
		fog_banks[index].position = fog_bank_origins[index] + Vector3(sin(fog_phase) * 1.1, cos(fog_phase * 0.7) * 0.08, cos(fog_phase * 0.8) * 0.35)
		fog_banks[index].transparency = 0.28 + (sin(fog_phase * 0.9) + 1.0) * 0.1
	var player := get_node_or_null("Player") as CharacterBody3D
	var camera := player.get_node_or_null("CameraRig/Camera3D") as Camera3D if player != null else null
	if player != null and camera != null:
		var player_xz := Vector2(player.global_position.x, player.global_position.z)
		var camera_xz := Vector2(camera.global_position.x, camera.global_position.z)
		for house_index in house_roofs_faded.size():
			var house_position := houses[house_index].global_position
			var house_xz := Vector2(house_position.x, house_position.z)
			house_roofs_faded[house_index] = _is_house_roof_occluding(camera_xz, player_xz, house_xz, house_roofs_faded[house_index])
	for index in house_fade_materials.size():
		var house_index := house_fade_house_indices[index]
		var target_alpha := 0.0 if house_roofs_faded[house_index] else house_fade_alphas[index]
		var house_color := house_fade_materials[index].albedo_color
		house_color.a = lerpf(house_color.a, target_alpha, minf(delta * 5.0, 1.0))
		house_fade_materials[index].albedo_color = house_color
	for index in villager_visuals.size():
		var villager := villager_visuals[index]
		var label := villager_labels[index]
		var idle_phase := portal_time * 1.15 + float(index) * 1.9
		villager.position.y = sin(idle_phase) * 0.025
		var label_alpha := 0.0
		if player != null:
			var label_distance := Vector2(player.position.x, player.position.z).distance_to(Vector2(villagers[index].position.x, villagers[index].position.z))
			label_alpha = 0.92 if label_distance < 7.0 else 0.0
		var label_color := label.modulate
		label_color.a = lerpf(label_color.a, label_alpha, minf(delta * 5.0, 1.0))
		label.modulate = label_color
		var outline_color := label.outline_modulate
		outline_color.a = label_color.a
		label.outline_modulate = outline_color
		label.visible = label_color.a > 0.01
		var target_yaw := villager_rotations[index] + sin(idle_phase * 0.55) * 0.035
		if player != null and nearby_villager == villagers[index]:
			var look_direction := player.global_position - villagers[index].global_position
			if Vector2(look_direction.x, look_direction.z).length_squared() > 0.001:
				target_yaw = atan2(look_direction.x, look_direction.z)
		elif index == 0 and villager_patrol_pauses[index] > 0.0 and villager_patrol_directions[index] < 0.0:
			var look_direction := HERB_PLOT_POSITION - villagers[index].global_position
			target_yaw = atan2(look_direction.x, look_direction.z)
		elif index == 1 and villager_patrol_pauses[index] > 0.0:
			var look_direction: Vector3 = TOREN_WATCH_TARGETS[toren_watch_index] - villagers[index].global_position
			target_yaw = atan2(look_direction.x, look_direction.z)
		elif Vector2(villagers[index].velocity.x, villagers[index].velocity.z).length_squared() > 0.001:
			target_yaw = atan2(villagers[index].velocity.x, villagers[index].velocity.z)
		elif index == 2 and nia_routine == "hearth":
			var look_direction := Vector3(4.3, 0.0, -5.5) - villagers[index].global_position
			target_yaw = atan2(look_direction.x, look_direction.z)
		elif index == 2 and nia_routine == "rain_shelter":
			var look_direction := Vector3(9.0, 0.0, -8.0) - villagers[index].global_position
			target_yaw = atan2(look_direction.x, look_direction.z)
		villager.rotation.y = lerp_angle(villager.rotation.y, target_yaw, minf(delta * 6.0, 1.0))


func _physics_process(delta: float) -> void:
	for index in villagers.size():
		var villager := villagers[index]
		var animation_player := villager_animations[index]
		if nearby_villager == villager:
			villager.velocity.x = 0.0
			villager.velocity.z = 0.0
			if animation_player.assigned_animation != "Idle":
				animation_player.play("Idle", 0.2)
		elif index == 2 and _update_nia_routine(villager, animation_player):
			pass
		elif index == 1:
			_update_toren_watch(villager, animation_player, delta)
		elif villager_patrol_pauses[index] > 0.0:
			villager_patrol_pauses[index] = maxf(villager_patrol_pauses[index] - delta, 0.0)
			villager.velocity.x = 0.0
			villager.velocity.z = 0.0
			var pause_animation := "PickUp" if index == 0 and villager_patrol_directions[index] < 0.0 else "Idle"
			if animation_player.assigned_animation != pause_animation:
				animation_player.play(pause_animation, 0.2)
		else:
			var patrol_offset := (villager.position - villager_patrol_origins[index]).dot(villager_patrol_axes[index])
			var patrol_range := 1.2
			if patrol_offset * villager_patrol_directions[index] >= patrol_range:
				villager_patrol_directions[index] *= -1.0
				var pause_animation := "PickUp" if index == 0 and villager_patrol_directions[index] < 0.0 else "Idle"
				villager_patrol_pauses[index] = 1.2 + float(index) * 0.3
				if pause_animation == "PickUp":
					villager_patrol_pauses[index] = maxf(villager_patrol_pauses[index], animation_player.get_animation("PickUp").length + 0.1)
				villager.velocity.x = 0.0
				villager.velocity.z = 0.0
				if animation_player.assigned_animation != pause_animation:
					animation_player.play(pause_animation, 0.2)
			else:
				var patrol_velocity := villager_patrol_axes[index] * villager_patrol_directions[index] * 0.65
				villager.velocity.x = patrol_velocity.x
				villager.velocity.z = patrol_velocity.z
				if animation_player.assigned_animation != "Walk":
					animation_player.play("Walk", 0.2)
		villager.velocity.y = -1.0
		villager.move_and_slide()


func _update_toren_watch(toren: CharacterBody3D, animation_player: AnimationPlayer, delta: float) -> void:
	if villager_patrol_pauses[1] > 0.0:
		villager_patrol_pauses[1] = maxf(villager_patrol_pauses[1] - delta, 0.0)
		toren.velocity.x = 0.0
		toren.velocity.z = 0.0
		if animation_player.assigned_animation != "Idle":
			animation_player.play("Idle", 0.2)
		return
	var next_index := (toren_watch_index + 1) % TOREN_WATCH_ROUTE.size()
	var offset: Vector3 = TOREN_WATCH_ROUTE[next_index] - toren.position
	offset.y = 0.0
	if offset.length() <= 0.08:
		toren.position.x = TOREN_WATCH_ROUTE[next_index].x
		toren.position.z = TOREN_WATCH_ROUTE[next_index].z
		toren_watch_index = next_index
		villager_patrol_pauses[1] = TOREN_WATCH_PAUSES[next_index]
		toren.velocity.x = 0.0
		toren.velocity.z = 0.0
		if animation_player.assigned_animation != "Idle":
			animation_player.play("Idle", 0.2)
		return
	var patrol_velocity: Vector3 = offset.normalized() * TOREN_WATCH_SPEED
	toren.velocity.x = patrol_velocity.x
	toren.velocity.z = patrol_velocity.z
	if animation_player.assigned_animation != "Walk":
		animation_player.play("Walk", 0.2)


func _update_nia_routine(nia: CharacterBody3D, animation_player: AnimationPlayer) -> bool:
	var hour := fposmod(time_hour, 24.0)
	var next_routine := "work"
	var route: Array = []
	if hour >= 18.5 and hour < 22.5:
		next_routine = "rain_shelter" if weather_rain_amount > 0.2 else "hearth"
		route = NIA_RAIN_ROUTE if next_routine == "rain_shelter" else NIA_HEARTH_ROUTE
	elif hour >= 22.5 or hour < 6.5:
		next_routine = "home"
		route = NIA_HOME_ROUTE
	if next_routine == "work":
		if nia_routine != "work":
			nia.position = villager_patrol_origins[2]
			nia.visible = true
			nia.collision_layer = 1
			nia.collision_mask = 1
			villager_patrol_directions[2] = 1.0
			villager_patrol_pauses[2] = 0.0
		nia_routine = "work"
		nia_route_index = 0
		return false
	if nia_routine != next_routine:
		var previous_routine := nia_routine
		nia_routine = next_routine
		nia.visible = true
		nia.collision_layer = 1
		nia.collision_mask = 1
		nia_route_index = 0
		if previous_routine in ["hearth", "rain_shelter"] and next_routine in ["hearth", "rain_shelter"]:
			nia_route_index = route.size() - 1
		else:
			var nearest_distance := INF
			for route_index in route.size():
				var route_distance := nia.position.distance_squared_to(route[route_index])
				if route_distance < nearest_distance:
					nearest_distance = route_distance
					nia_route_index = route_index
	var target: Vector3 = route[mini(nia_route_index, route.size() - 1)]
	var offset := target - nia.position
	offset.y = 0.0
	if offset.length() <= 0.12:
		nia.position.x = target.x
		nia.position.z = target.z
		if nia_route_index < route.size() - 1:
			nia_route_index += 1
		else:
			nia.velocity.x = 0.0
			nia.velocity.z = 0.0
			if animation_player.assigned_animation != "Idle":
				animation_player.play("Idle", 0.2)
			if nia_routine == "home":
				nia.visible = false
				nia.collision_layer = 0
				nia.collision_mask = 0
			return true
		target = route[nia_route_index]
		offset = target - nia.position
		offset.y = 0.0
	var route_velocity := offset.normalized() * 0.72
	nia.velocity.x = route_velocity.x
	nia.velocity.z = route_velocity.z
	if animation_player.assigned_animation != "Walk":
		animation_player.play("Walk", 0.2)
	return true


func _portal_proximity() -> float:
	var player := get_node_or_null("Player") as CharacterBody3D
	if player == null:
		return 0.0
	var distance := Vector2(player.position.x, player.position.z).distance_to(Vector2(portal_center.x, portal_center.z))
	portal_nearby = distance <= 4.8
	return clampf(1.0 - (distance - 2.0) / 3.0, 0.0, 1.0)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	if nearby_villager != null:
		_show_villager_dialogue()
	elif portal_nearby:
		_show_portal_lore()
	else:
		return
	get_viewport().set_input_as_handled()


func _update_villager_interaction() -> void:
	var player := get_node_or_null("Player") as CharacterBody3D
	nearby_villager = null
	var nearest_distance := 3.0
	if player != null:
		for villager in villagers:
			if not villager.visible:
				continue
			var distance := Vector2(player.position.x, player.position.z).distance_to(Vector2(villager.position.x, villager.position.z))
			if distance < nearest_distance:
				nearest_distance = distance
				nearby_villager = villager
	if portal_prompt == null or (portal_lore != null and portal_lore.visible):
		return
	if nearby_villager != null:
		portal_prompt.text = "F  与%s交谈" % _villager_name(nearby_villager.name)
		portal_prompt.show()
	elif portal_nearby:
		portal_prompt.text = "F  调查"
		portal_prompt.show()
	else:
		portal_prompt.hide()


func _villager_name(npc_name: String) -> String:
	match npc_name:
		"HerbalistMira": return "米拉"
		"GatekeeperToren": return "托伦"
		_: return "尼娅"


func _show_villager_dialogue() -> void:
	var message := "尼娅：雾里的丝线，总会织出陌生的花纹。"
	match nearby_villager.name:
		"HerbalistMira": message = "米拉：雾起前采下的药草，效力最好。"
		"GatekeeperToren": message = "托伦：沿石路走，别踏进谷边的浓雾。"
	var model := nearby_villager.get_node("Visual/CharacterModel") as Node3D
	var model_y := model.position.y
	var nod := create_tween()
	nod.tween_property(model, "position:y", model_y - 0.06, 0.12)
	nod.tween_property(model, "position:y", model_y, 0.18)
	_show_interaction_text(message)


func _show_portal_lore() -> void:
	portal_reaction_time = 1.0
	portal_react_player.play()
	_show_interaction_text("石环残留着与你相似的异界气息。")


func _show_interaction_text(message: String) -> void:
	portal_prompt.hide()
	portal_lore.text = message
	portal_lore.modulate.a = 0.0
	portal_lore.show()
	if portal_lore_tween != null:
		portal_lore_tween.kill()
	portal_lore_tween = create_tween()
	portal_lore_tween.tween_property(portal_lore, "modulate:a", 1.0, 0.25)
	portal_lore_tween.tween_interval(2.4)
	portal_lore_tween.tween_property(portal_lore, "modulate:a", 0.0, 0.55)
	portal_lore_tween.tween_callback(portal_lore.hide)


func _apply_time_of_day() -> void:
	if environment_settings == null or sun == null:
		return
	var sample := _sample_day(time_hour)
	var weather := _sample_weather()
	sun.rotation_degrees = Vector3(-sample["elev"], sample["azim"], 0.0)
	sun.light_color = (sample["sun_color"] as Color).lerp(weather["tint"] as Color, weather["sun_tint"] as float)
	sun.light_energy = (sample["sun_energy"] as float) * (weather["sun_energy"] as float)
	sun.shadow_opacity = (sample["shadow_opacity"] as float) * (weather["shadow"] as float)
	environment_settings.ambient_light_color = (sample["amb_color"] as Color).lerp(weather["tint"] as Color, weather["ambient_tint"] as float)
	environment_settings.ambient_light_energy = maxf((sample["amb_energy"] as float) * (weather["ambient_energy"] as float), 0.35)
	environment_settings.fog_light_color = (sample["fog_color"] as Color).lerp(weather["fog_tint"] as Color, weather["fog_color_mix"] as float)
	environment_settings.fog_density = (sample["fog_density"] as float) * (weather["fog_density"] as float)
	environment_settings.background_color = (sample["bg_color"] as Color).lerp(weather["fog_tint"] as Color, weather["background_tint"] as float)
	weather_rain_amount = weather["rain"] as float
	weather_wind_amount = weather["wind"] as float


func _sample_day(hour: float) -> Dictionary:
	var h := fposmod(hour, 24.0)
	for index in range(day_keys.size() - 1):
		var from_key: Array = day_keys[index]
		var to_key: Array = day_keys[index + 1]
		if h < from_key[0] or h > to_key[0]:
			continue
		var blend := (h - (from_key[0] as float)) / ((to_key[0] as float) - (from_key[0] as float))
		blend = blend * blend * (3.0 - 2.0 * blend)
		return {
			"elev": lerpf(from_key[1], to_key[1], blend),
			"azim": rad_to_deg(lerp_angle(deg_to_rad(from_key[2]), deg_to_rad(to_key[2]), blend)),
			"sun_color": (from_key[3] as Color).lerp(to_key[3], blend),
			"sun_energy": lerpf(from_key[4], to_key[4], blend),
			"amb_color": (from_key[5] as Color).lerp(to_key[5], blend),
			"amb_energy": lerpf(from_key[6], to_key[6], blend),
			"fog_color": (from_key[7] as Color).lerp(to_key[7], blend),
			"fog_density": lerpf(from_key[8], to_key[8], blend),
			"bg_color": (from_key[9] as Color).lerp(to_key[9], blend),
			"shadow_opacity": lerpf(from_key[10], to_key[10], blend),
		}
	return {}


func _night_focus(hour: float) -> float:
	var h := fposmod(hour, 24.0)
	if h < 7.0:
		return 1.0 - _smoothstep_range(5.0, 7.0, h)
	if h >= 17.5:
		return _smoothstep_range(17.5, 19.5, h)
	return 0.0


func _smoothstep_range(from_value: float, to_value: float, value: float) -> float:
	var blend := clampf((value - from_value) / (to_value - from_value), 0.0, 1.0)
	return blend * blend * (3.0 - 2.0 * blend)


func _make_weather_schedule(seed_value: int) -> Array:
	var random := RandomNumberGenerator.new()
	random.seed = seed_value
	var schedule: Array = [{"state": "clear", "duration": random.randf_range(5.0, 8.0)}]
	var previous_state := "clear"
	for cycle in 3:
		var pool: Array = WEATHER_STATES.duplicate()
		for index in range(pool.size() - 1, 0, -1):
			var swap_index := random.randi_range(0, index)
			var temporary = pool[index]
			pool[index] = pool[swap_index]
			pool[swap_index] = temporary
		if pool[0] == previous_state:
			var temporary = pool[0]
			pool[0] = pool[1]
			pool[1] = temporary
		for state in pool:
			var duration_range := _weather_duration_range(state)
			schedule.append({
				"state": state,
				"duration": random.randf_range(duration_range.x, duration_range.y),
			})
			previous_state = state
	if schedule[-1]["state"] == schedule[0]["state"]:
		var temporary = schedule[-1]
		schedule[-1] = schedule[-2]
		schedule[-2] = temporary
	return schedule


func _weather_duration_range(state: String) -> Vector2:
	match state:
		"clear": return Vector2(5.0, 8.0)
		"cloudy": return Vector2(4.0, 7.0)
		"mist": return Vector2(3.0, 5.5)
		_: return Vector2(3.0, 5.0)


func _update_weather(delta: float) -> void:
	if not weather_running or not weather_override.is_empty() or weather_schedule.is_empty():
		return
	weather_segment_elapsed += delta * 24.0 / DAY_DURATION_SECONDS
	var segment: Dictionary = weather_schedule[weather_schedule_index]
	while weather_segment_elapsed >= (segment["duration"] as float):
		weather_segment_elapsed -= segment["duration"] as float
		weather_schedule_index = (weather_schedule_index + 1) % weather_schedule.size()
		segment = weather_schedule[weather_schedule_index]


func _sample_weather() -> Dictionary:
	if not weather_override.is_empty():
		var locked_state := weather_override if weather_override in WEATHER_STATES else "clear"
		weather_state = locked_state
		weather_target_state = locked_state
		weather_blend = 0.0
		return _weather_profile(locked_state)
	if weather_schedule.is_empty():
		return _weather_profile("clear")
	var segment: Dictionary = weather_schedule[weather_schedule_index]
	var next_segment: Dictionary = weather_schedule[(weather_schedule_index + 1) % weather_schedule.size()]
	var duration := segment["duration"] as float
	weather_blend = _smoothstep_range(duration - WEATHER_TRANSITION_HOURS, duration, weather_segment_elapsed)
	weather_state = segment["state"]
	weather_target_state = next_segment["state"]
	return _blend_weather_profiles(
		_weather_profile(weather_state),
		_weather_profile(weather_target_state),
		weather_blend
	)


func _weather_profile(state: String) -> Dictionary:
	match state:
		"cloudy":
			return {
				"sun_energy": 0.78, "sun_tint": 0.20, "ambient_energy": 1.02,
				"ambient_tint": 0.16, "shadow": 0.78, "fog_density": 1.22,
				"fog_color_mix": 0.18, "background_tint": 0.20, "rain": 0.0, "wind": 0.86,
				"tint": Color("b5c2c1"), "fog_tint": Color("899d9f"),
			}
		"mist":
			return {
				"sun_energy": 0.84, "sun_tint": 0.24, "ambient_energy": 1.04,
				"ambient_tint": 0.20, "shadow": 0.66, "fog_density": 2.0,
				"fog_color_mix": 0.34, "background_tint": 0.32, "rain": 0.0, "wind": 0.48,
				"tint": Color("b9c5bd"), "fog_tint": Color("94a8a3"),
			}
		"light_rain":
			return {
				"sun_energy": 0.66, "sun_tint": 0.30, "ambient_energy": 1.0,
				"ambient_tint": 0.24, "shadow": 0.56, "fog_density": 1.48,
				"fog_color_mix": 0.28, "background_tint": 0.30, "rain": 1.0, "wind": 1.12,
				"tint": Color("aab9bb"), "fog_tint": Color("778f95"),
			}
		_:
			return {
				"sun_energy": 1.0, "sun_tint": 0.0, "ambient_energy": 1.0,
				"ambient_tint": 0.0, "shadow": 1.0, "fog_density": 1.0,
				"fog_color_mix": 0.0, "background_tint": 0.0, "rain": 0.0, "wind": 0.62,
				"tint": Color.WHITE, "fog_tint": Color.WHITE,
			}


func _blend_weather_profiles(from_profile: Dictionary, to_profile: Dictionary, blend: float) -> Dictionary:
	return {
		"sun_energy": lerpf(from_profile["sun_energy"], to_profile["sun_energy"], blend),
		"sun_tint": lerpf(from_profile["sun_tint"], to_profile["sun_tint"], blend),
		"ambient_energy": lerpf(from_profile["ambient_energy"], to_profile["ambient_energy"], blend),
		"ambient_tint": lerpf(from_profile["ambient_tint"], to_profile["ambient_tint"], blend),
		"shadow": lerpf(from_profile["shadow"], to_profile["shadow"], blend),
		"fog_density": lerpf(from_profile["fog_density"], to_profile["fog_density"], blend),
		"fog_color_mix": lerpf(from_profile["fog_color_mix"], to_profile["fog_color_mix"], blend),
		"background_tint": lerpf(from_profile["background_tint"], to_profile["background_tint"], blend),
		"rain": lerpf(from_profile["rain"], to_profile["rain"], blend),
		"wind": lerpf(from_profile["wind"], to_profile["wind"], blend),
		"tint": (from_profile["tint"] as Color).lerp(to_profile["tint"], blend),
		"fog_tint": (from_profile["fog_tint"] as Color).lerp(to_profile["fog_tint"], blend),
	}


func _animate_weather() -> void:
	if rain_field == null or rain_material == null:
		return
	var player := get_node_or_null("Player") as CharacterBody3D
	if player != null:
		rain_field.position = Vector3(player.position.x, 0.0, player.position.z)
	rain_field.visible = weather_rain_amount > 0.01
	var rain_color := Color(0.55, 0.68, 0.71, weather_rain_amount * 0.30)
	rain_material.albedo_color = rain_color
	for index in rain_streaks.size():
		var params := rain_params[index]
		var fall := fposmod((params["start_y"] as float) - portal_time * (params["speed"] as float), 9.0)
		var streak := rain_streaks[index]
		streak.position = Vector3(
			(params["x"] as float) + sin(portal_time * 0.35 + (params["phase"] as float)) * 0.12,
			1.0 + fall,
			params["z"] as float
		)
		var rain_world_position := rain_field.to_global(streak.position)
		var shelter_alpha := 0.0
		for house in houses:
			var house_local := house.to_local(rain_world_position)
			var distance_inside := minf(3.15 - absf(house_local.x), 3.15 - absf(house_local.z))
			if distance_inside > 0.0:
				shelter_alpha = maxf(shelter_alpha, _smoothstep_range(0.0, 0.55, distance_inside))
		streak.transparency = shelter_alpha


func _butterfly_alpha(hour: float) -> float:
	var h := fposmod(hour, 24.0)
	return _smoothstep_range(7.0, 8.0, h) * (1.0 - _smoothstep_range(18.0, 19.0, h))


func _firefly_alpha(hour: float) -> float:
	var h := fposmod(hour, 24.0)
	return maxf(_smoothstep_range(19.5, 20.5, h), 1.0 - _smoothstep_range(4.5, 5.5, h))


func _animate_ecosystem() -> void:
	if butterflies == null or fireflies == null:
		return
	var butterfly_alpha := _butterfly_alpha(time_hour)
	butterflies.visible = butterfly_alpha > 0.01
	butterfly_material.albedo_color = Color(0.95, 0.91, 0.78, butterfly_alpha)
	for fly in butterflies.get_children():
		var params: Dictionary = fly.get_meta("params")
		var phase := portal_time * (params["speed"] as float) + (params["phase"] as float)
		var home: Vector2 = params["home"]
		fly.position = Vector3(
			home.x + sin(phase) * (params["radius_x"] as float),
			(params["height"] as float) + sin(phase * 2.3) * 0.12,
			home.y + cos(phase * 0.8) * (params["radius_z"] as float)
		)
		var flap := 0.72 + 0.28 * absf(sin(portal_time * 11.0 + (params["phase"] as float) * 2.7))
		fly.scale = Vector3(flap, 1.0, 1.0)

	var firefly_alpha := _firefly_alpha(time_hour)
	fireflies.visible = firefly_alpha > 0.01
	firefly_material.albedo_color = Color(0.48, 0.72, 0.60, firefly_alpha)
	for fly in fireflies.get_children():
		var params: Dictionary = fly.get_meta("params")
		var phase := portal_time * (params["speed"] as float) + (params["phase"] as float)
		var home: Vector2 = params["home"]
		fly.position = Vector3(
			home.x + sin(phase) * (params["radius_x"] as float),
			(params["height"] as float) + sin(phase * 1.7) * 0.10,
			home.y + cos(phase * 0.65) * (params["radius_z"] as float)
		)
		var pulse := 0.72 + 0.24 * sin(portal_time * 2.0 + (params["phase"] as float) * 4.0)
		fly.scale = Vector3.ONE * pulse
	_animate_falling_leaves()


func _animate_tree_canopies() -> void:
	for material in tree_canopy_materials:
		material.set_shader_parameter("motion_time", portal_time)
		material.set_shader_parameter("wind_strength", weather_wind_amount)


func _animate_falling_leaves() -> void:
	if falling_leaves == null:
		return
	for leaf_node in falling_leaves.get_children():
		var leaf := leaf_node as MeshInstance3D
		var params: Dictionary = leaf.get_meta("params")
		var cycle := fposmod(portal_time * (params["speed"] as float) + (params["offset"] as float), 1.0)
		var phase := cycle * TAU + (params["phase"] as float)
		var home: Vector2 = params["home"]
		var drift := (params["drift"] as float) * weather_wind_amount
		leaf.position = Vector3(
			home.x + sin(phase * 1.35) * drift + cycle * weather_wind_amount * 0.32,
			lerpf(params["height"] as float, 0.16, cycle),
			home.y + cos(phase * 0.82) * drift * 0.55
		)
		leaf.rotation = Vector3(
			0.22 + sin(phase * 1.7) * 0.42,
			phase * (params["spin"] as float),
			cos(phase * 1.15) * 0.32
		)
		leaf.transparency = 1.0 - sin(PI * cycle) * 0.90


func _build_world() -> void:
	ground_material.albedo_texture = _ground_texture()
	ground_material.uv1_scale = Vector3.ONE * 24.0
	ground_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	path_material.albedo_texture = _road_texture()
	path_material.uv1_scale = Vector3.ONE
	path_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	path_material.vertex_color_use_as_albedo = true
	path_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC

	var world_environment := WorldEnvironment.new()
	world_environment.name = "WorldEnvironment"
	environment_settings = Environment.new()
	environment_settings.background_mode = Environment.BG_COLOR
	environment_settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment_settings.fog_enabled = true
	environment_settings.fog_height = 2.0
	environment_settings.fog_height_density = 0.08
	world_environment.environment = environment_settings
	add_child(world_environment)

	sun = DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-52.0, -28.0, 0.0)
	sun.light_color = Color("fff0ce")
	sun.light_energy = 0.72
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	sun.directional_shadow_max_distance = 55.0
	sun.shadow_blur = 1.4
	add_child(sun)

	_add_box("ValleyFloor", Vector3(70.0, 1.0, 70.0), Vector3(0.0, -0.5, 0.0), ground_material, true)
	_add_ground_patch("GrassShadeWest", Vector3(-15, 0, -8), 8.5, Vector2(1.25, 0.8), Color("66835f"))
	_add_ground_patch("GrassLightEast", Vector3(15, 0, -7), 8.0, Vector2(1.15, 0.75), Color("78956d"))
	_add_ground_patch("GrassShadeSouth", Vector3(-13, 0, 17), 7.5, Vector2(1.35, 0.75), Color("66835f"))
	_add_ground_patch("GrassLightSouth", Vector3(14, 0, 19), 7.0, Vector2(1.25, 0.8), Color("78956d"))
	_add_ground_patch("GrassShadeNorth", Vector3(0, 0, -23), 9.0, Vector2(1.45, 0.65), Color("66835f"))
	var valley_boundary := ValleyBoundaryScene.instantiate() as Node3D
	assert(valley_boundary != null)
	add_child(valley_boundary)
	valley_boundary.call("build", stone_material)
	_add_boundary_scenery()
	_add_fog_banks()
	_add_road("VillagePath", PackedVector2Array([
		Vector2(0.0, -28.0), Vector2(0.4, -23.0), Vector2(0.8, -17.0),
		Vector2(0.15, -11.0), Vector2(-0.75, -5.0), Vector2(-0.35, 2.0),
		Vector2(0.55, 9.0), Vector2(0.2, 16.0), Vector2(-0.7, 23.0),
		Vector2(-1.2, 31.0),
	]), PackedFloat32Array([2.1, 2.0, 1.85, 1.42, 1.28, 1.32, 1.48, 1.85, 2.0, 2.0]))
	_add_road("VillageWestLane", PackedVector2Array([
		Vector2(-1.35, -6.85), Vector2(-2.7, -7.12), Vector2(-6.4, -7.0), Vector2(-9.3, -6.9),
	]), PackedFloat32Array([0.62, 0.82, 0.82, 0.58]), 0.06, 0.3, true)
	_add_road("VillageHearthLane", PackedVector2Array([
		Vector2(1.3, -4.55), Vector2(1.9, -4.3), Vector2(3.3, -4.2),
		Vector2(5.8, -4.6), Vector2(8.6, -5.0),
	]), PackedFloat32Array([0.62, 0.82, 1.2, 1.02, 0.76]), 0.06, 0.32, true)
	_add_road("VillageWagonLane", PackedVector2Array([
		Vector2(-1.35, -1.9), Vector2(-2.7, -2.05), Vector2(-4.8, -2.45),
		Vector2(-6.9, -2.75),
	]), PackedFloat32Array([0.58, 0.72, 1.0, 1.25]), 0.06, 0.28, true)
	_add_road("VillageSouthLane", PackedVector2Array([
		Vector2(-0.8, 7.4), Vector2(-3.2, 7.6), Vector2(-5.4, 7.6), Vector2(-9.6, 8.0),
	]), PackedFloat32Array([0.72, 0.82, 0.84, 0.66]), 0.06, 0.3, true)
	_add_road("PortalPath", PackedVector2Array([
		Vector2(0.6, 10.8), Vector2(3.4, 10.9), Vector2(6.5, 10.7),
		Vector2(9.2, 10.9), Vector2(11.3, 11.0),
	]), PackedFloat32Array([1.45, 1.35, 1.45, 1.65, 1.9]), 0.06, 0.48, true)
	_add_road("PondPath", PackedVector2Array([
		Vector2(0.2, 11.3), Vector2(-1.4, 11.8), Vector2(-3.0, 12.4),
		Vector2(-3.9, 12.5),
	]), PackedFloat32Array([1.35, 1.3, 1.4, 1.55]), 0.065, 0.45, true)
	_add_road("MistPassPath", PackedVector2Array([
		Vector2(0.0, -27.2), Vector2(0.0, -29.2), Vector2(0.0, -31.5),
	]), PackedFloat32Array([2.05, 2.35, 3.1]))
	_add_ground_patch("MistPassTone", Vector3(0.0, 0.0, -29.0), 4.2, Vector2(0.65, 0.8), Color("666b62"), 0.105, 0.32)
	_add_mist_pass()
	var track_material := _material(Color("78644a"), 1.0)
	track_material.albedo_color.a = 0.42
	track_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	track_material.vertex_color_use_as_albedo = true
	_add_cart_tracks("NorthCartTrack", PackedVector2Array([
		Vector2(0.0, -27.5), Vector2(0.4, -23.0), Vector2(0.8, -19.0),
		Vector2(0.7, -16.0), Vector2(0.3, -14.5),
	]), track_material)
	_add_cart_tracks("SouthCartTrack", PackedVector2Array([
		Vector2(-0.2, 0.5), Vector2(0.4, 6.0), Vector2(0.7, 10.0),
		Vector2(0.3, 14.0), Vector2(-0.1, 18.0), Vector2(-0.7, 23.0),
		Vector2(-1.1, 28.0), Vector2(-1.2, 30.5),
	]), track_material)
	var village_wear := [
		["VillageWearHearth", Vector3(4.3, 0.0, -5.5), 3.1, Vector2(1.05, 0.72), Color("6f5d48")],
		["VillageWearHerbs", Vector3(-14.0, 0.0, -8.8), 3.5, Vector2(1.1, 0.72), Color("75624b")],
		["VillageWearWagon", Vector3(-6.25, 0.0, -2.65), 2.5, Vector2(1.25, 0.72), Color("705e49")],
		["VillageWearEastDoor", Vector3(6.3, 0.0, -7.2), 2.0, Vector2(0.9, 0.68), Color("75624b")],
	]
	for wear in village_wear:
		_add_ground_patch(wear[0], wear[1], wear[2], wear[3], wear[4], 0.12, 0.34)
	var village_grass_insets := [
		["VillageGrassNorthWest", Vector3(-5.8, 0.0, -12.7), 3.2, Vector2(1.05, 0.72), Color("536f51")],
		["VillageGrassWest", Vector3(-7.0, 0.0, -4.3), 3.0, Vector2(0.85, 1.0), Color("5e7b56")],
		["VillageGrassNorthEast", Vector3(6.3, 0.0, -11.8), 2.8, Vector2(0.9, 0.75), Color("557252")],
		["VillageGrassSouthEast", Vector3(6.6, 0.0, -1.8), 2.6, Vector2(0.95, 0.72), Color("607c58")],
	]
	for inset in village_grass_insets:
		_add_ground_patch(inset[0], inset[1], inset[2], inset[3], inset[4], 0.115, 0.62)
	var road_wear := [
		["RoadWearNorth", Vector3(0.2, 0.0, -20.5), 3.7, Vector2(0.62, 1.0), Color("756651")],
		["RoadWearFork", Vector3(0.0, 0.0, 11.2), 3.4, Vector2(0.8, 0.75), Color("7a664c")],
		["RoadWearSouth", Vector3(0.25, 0.0, 23.0), 4.2, Vector2(0.58, 1.0), Color("725f49")],
	]
	for wear in road_wear:
		_add_ground_patch(wear[0], wear[1], wear[2], wear[3], wear[4], 0.11, 0.28)
	_add_ground_patch("PortalPathBlend", Vector3(2.4, 0.0, 11.1), 2.4, Vector2(0.72, 0.9), Color("8a7458"), 0.105, 0.24)
	_add_ground_patch("PondPathBlend", Vector3(-2.3, 0.0, 11.8), 2.1, Vector2(0.72, 0.9), Color("846f55"), 0.105, 0.22)
	_add_ground_patch("PondLookout", Vector3(-3.9, 0.0, 12.4), 1.5, Vector2(0.68, 0.95), Color("75624b"), 0.058, 0.28)
	_add_ground_patch("HerbYardGrass", Vector3(-14.6, 0.0, -9.8), 4.6, Vector2(1.0, 0.78), Color("587451"), 0.035, 0.28)
	_add_road("HerbYardPath", PackedVector2Array([
		Vector2(-9.4, -6.9), Vector2(-11.2, -7.0), Vector2(-12.9, -7.6), Vector2(-14.4, -8.5),
	]), PackedFloat32Array([0.72, 0.7, 0.78, 0.9]), 0.055, 0.25, true)

	_add_house(Vector3(-9.0, 0.0, -10.0), 0.15)
	_add_house(Vector3(9.0, 0.0, -8.0), -0.2)
	_add_house(Vector3(-10.0, 0.0, 5.0), 0.05)
	_add_village_hearth()
	_add_village_props()
	_add_herb_plot()
	_add_ruin(Vector3(10.0, 0.0, 13.0))
	_add_pond(Vector3(-7.8, 0.0, 12.0))
	_add_mistcaps()
	_add_meadow_grass()
	_add_ecosystem()

	var trees := [
		["CommonTree_1", Vector3(-21, 0, -24.8), 0.2, 1.05],
		["CommonTree_3", Vector3(17, 0, -18), 2.1, 0.9],
		["Pine_2", Vector3(-19, 0, 1), 1.4, 1.15],
		["CommonTree_1", Vector3(18, 0, 3), 2.8, 1.0],
		["TwistedTree_1", Vector3(-16, 0, 17), 0.8, 0.68],
		["Pine_2", Vector3(19, 0, 18), 2.5, 1.2],
		["CommonTree_3", Vector3(-7, 0, 23), 0.1, 0.92],
		["CommonTree_1", Vector3(8, 0, 23), 1.8, 1.05],
	]
	for tree in trees:
		_add_nature(tree[0], tree[1], tree[2], tree[3])
	_add_falling_leaves()

	var undergrowth := [
		["Bush_Common_Flowers", Vector3(-13, 0, -17), 0.3, 1.0],
		["Bush_Common", Vector3(13, 0, -16), 1.4, 1.2],
		["Bush_Common", Vector3(-18, 0, 8), 2.1, 0.9],
		["Fern_1", Vector3(20, 0, 9), 0.6, 0.35],
		["Fern_1", Vector3(-14, 0, 20), 2.6, 0.28],
		["Grass_Common_Tall", Vector3(5, 0, 17), 0.2, 0.8],
		["Grass_Common_Tall", Vector3(-5, 0, 16), 1.0, 0.7],
		["Mushroom_Common", Vector3(-14, 0, 13), 2.4, 1.8],
		["Mushroom_Common", Vector3(14, 0, 19), 0.8, 1.5],
		["Rock_Medium_1", Vector3(-21, 0, -10), 0.5, 0.8],
		["Rock_Medium_2", Vector3(21, 0, -7), 1.9, 1.0],
	]
	for item in undergrowth:
		_add_nature(item[0], item[1], item[2], item[3], false)

	var road_stones := [
		["Rock_Medium_1", Vector3(-2.8, 0, 19), 0.2, 0.18],
		["Rock_Medium_2", Vector3(2.8, 0, 16), 1.3, 0.16],
		["Rock_Medium_2", Vector3(-2.9, 0, 8), 2.4, 0.2],
		["Rock_Medium_1", Vector3(2.9, 0, 2), 0.8, 0.17],
		["Rock_Medium_1", Vector3(3.8, 0, 9.1), 1.9, 0.16],
		["Rock_Medium_2", Vector3(7.2, 0, 12.9), 0.4, 0.19],
	]
	for stone in road_stones:
		_add_nature(stone[0], stone[1], stone[2], stone[3], false)

	var entrance_details := [
		["Rock_Medium_1", Vector3(-4.3, 0, 1.2), 0.3, 0.55],
		["Rock_Medium_2", Vector3(4.3, 0, 1.0), 1.7, 0.6],
		["Bush_Common_Flowers", Vector3(-5.4, 0, 0.3), 0.7, 0.75],
		["Bush_Common", Vector3(5.3, 0, 0.4), 2.4, 0.8],
		["Fern_1", Vector3(-4.9, 0, 2.8), 1.2, 0.2],
		["Mushroom_Common", Vector3(5.0, 0, 2.6), 2.1, 1.1],
	]
	for detail in entrance_details:
		_add_nature(detail[0], detail[1], detail[2], detail[3], false)


func _build_player() -> void:
	var player := CharacterBody3D.new()
	player.name = "Player"
	player.position = portal_center + Vector3(0.0, 0.0, 3.0)
	player.set_script(PlayerScript)

	var collider := CollisionShape3D.new()
	collider.name = "CollisionShape3D"
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.38
	capsule.height = 1.6
	collider.shape = capsule
	collider.position.y = 0.8
	player.add_child(collider)

	var visual := Node3D.new()
	visual.name = "Visual"
	player.add_child(visual)
	_attach_character_model(visual, DrifterCharacter, 0.78, 0.0)
	for mesh_node in visual.find_children("*", "MeshInstance3D", true, false):
		(mesh_node as MeshInstance3D).layers |= 2

	var rig := Node3D.new()
	rig.name = "CameraRig"
	player.add_child(rig)
	var camera := Camera3D.new()
	camera.name = "Camera3D"
	camera.position = Vector3(0.0, 15.0, 14.0)
	camera.rotation_degrees.x = -47.0
	camera.fov = 36.5
	camera.current = true
	rig.add_child(camera)
	player_fill_light = SpotLight3D.new()
	player_fill_light.name = "PlayerFill"
	player_fill_light.light_color = Color("c1cbc6")
	player_fill_light.light_energy = 0.0
	player_fill_light.light_cull_mask = 2
	player_fill_light.spot_range = 35.0
	player_fill_light.spot_angle = 10.0
	player_fill_light.spot_attenuation = 0.8
	player_fill_light.shadow_enabled = false
	camera.add_child(player_fill_light)
	var listener := AudioListener3D.new()
	listener.name = "AudioListener3D"
	player.add_child(listener)
	listener.make_current()
	add_child(player)
	_build_arrival(player, camera)


func _build_villagers() -> void:
	_add_villager("HerbalistMira", Vector3(-12.0, 0.0, -7.0), -2.4, MiraCharacter, Vector3(-0.65, 0.0, -0.75), 0.64)
	_add_villager("GatekeeperToren", Vector3(3.0, 0.0, -15.2), 2.95, TorenCharacter, Vector3.BACK, 0.67)
	_add_villager("WeaverNia", Vector3(-5.5, 0.0, 6.5), 1.15, NiaCharacter, Vector3.BACK, 0.78)
	villager_patrol_pauses[1] = 2.8


func _add_villager(npc_name: String, npc_position: Vector3, facing: float, character_scene: PackedScene, patrol_axis: Vector3, visual_scale: float) -> void:
	var npc := CharacterBody3D.new()
	npc.name = npc_name
	npc.position = npc_position
	add_child(npc)
	villagers.append(npc)
	villager_patrol_origins.append(npc_position)
	villager_patrol_axes.append(patrol_axis.normalized())
	villager_patrol_directions.append(1.0)
	villager_patrol_pauses.append(0.0)

	var collider := CollisionShape3D.new()
	collider.name = "CollisionShape3D"
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.32
	capsule.height = 1.6
	collider.shape = capsule
	collider.position.y = 0.8
	npc.add_child(collider)

	var visual := Node3D.new()
	visual.name = "Visual"
	visual.rotation.y = facing
	npc.add_child(visual)
	villager_visuals.append(visual)
	villager_rotations.append(facing)
	var animation_player := _attach_character_model(visual, character_scene, visual_scale, 0.0)
	animation_player.get_animation("Walk").loop_mode = Animation.LOOP_LINEAR
	if npc_name == "HerbalistMira":
		animation_player.get_animation("PickUp").loop_mode = Animation.LOOP_NONE
	villager_animations.append(animation_player)

	var label := Label3D.new()
	label.name = "IdentityLabel"
	match npc_name:
		"HerbalistMira": label.text = "米拉 · 药草师"
		"GatekeeperToren": label.text = "托伦 · 守门人"
		_: label.text = "尼娅 · 织工"
	var npc_model := visual.get_node("CharacterModel") as Node3D
	label.position.y = _visual_height(npc_model) + 0.28
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.fixed_size = false
	label.pixel_size = 0.009
	label.font_size = 26
	label.outline_size = 7
	label.modulate = Color(0.96, 0.94, 0.84, 0.0)
	label.outline_modulate = Color(0.06, 0.08, 0.08, 0.0)
	label.visible = false
	npc.add_child(label)
	villager_labels.append(label)


func _attach_character_model(visual: Node3D, character_scene: PackedScene, scale_factor: float, y_offset: float) -> AnimationPlayer:
	var model := character_scene.instantiate() as Node3D
	model.name = "CharacterModel"
	model.position.y = y_offset
	model.scale = Vector3.ONE * scale_factor
	visual.add_child(model)
	var animation_player := model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if animation_player != null and animation_player.has_animation("Idle"):
		animation_player.get_animation("Idle").loop_mode = Animation.LOOP_LINEAR
		animation_player.play("Idle")
	return animation_player


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
	assert(has_bounds, "Character visual has no mesh bounds")
	return bounds.size.y


func _build_arrival(player: CharacterBody3D, camera: Camera3D) -> void:
	var glow := _material(Color(0.5, 0.93, 0.82, 0.45), 0.25)
	glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow.emission_enabled = true
	glow.emission = Color("79e5cd")
	glow.emission_energy_multiplier = 0.8
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 0.61
	ring_mesh.outer_radius = 0.71
	var ring := MeshInstance3D.new()
	ring.name = "ArrivalRing"
	ring.mesh = ring_mesh
	ring.material_override = glow
	ring.position = Vector3(player.position.x, 0.04, player.position.z)
	ring.scale = Vector3.ONE * 0.2
	add_child(ring)
	var ring_tween := create_tween()
	ring_tween.set_parallel(true)
	ring_tween.set_trans(Tween.TRANS_CUBIC)
	ring_tween.set_ease(Tween.EASE_OUT)
	ring_tween.tween_property(ring, "scale", Vector3.ONE * 2.6, 1.5)
	ring_tween.tween_property(ring, "transparency", 1.0, 1.5)
	ring_tween.chain().tween_callback(ring.queue_free)
	var camera_tween := create_tween()
	camera_tween.set_trans(Tween.TRANS_CUBIC)
	camera_tween.set_ease(Tween.EASE_OUT)
	camera_tween.tween_property(camera, "fov", 42.0, 2.2)


func _build_opening() -> void:
	var layer := CanvasLayer.new()
	layer.name = "Opening"
	add_child(layer)

	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color.BLACK
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(shade)

	var titles := VBoxContainer.new()
	titles.position = Vector2(42.0, 36.0)
	titles.modulate.a = 0.0
	layer.add_child(titles)
	var title := Label.new()
	title.text = "雾谷"
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color("f4ead1"))
	title.add_theme_color_override("font_outline_color", Color(0.08, 0.1, 0.09, 0.9))
	title.add_theme_constant_override("outline_size", 8)
	titles.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "世界夹缝 · 漂泊者营地"
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.add_theme_color_override("font_color", Color("c8d5c7"))
	subtitle.add_theme_color_override("font_outline_color", Color(0.08, 0.1, 0.09, 0.9))
	subtitle.add_theme_constant_override("outline_size", 6)
	titles.add_child(subtitle)

	var shade_tween := create_tween()
	shade_tween.tween_property(shade, "color:a", 0.0, 1.25)
	shade_tween.tween_callback(shade.queue_free)
	var title_tween := create_tween()
	title_tween.tween_interval(0.35)
	title_tween.tween_property(titles, "modulate:a", 1.0, 0.65)
	title_tween.tween_interval(2.1)
	title_tween.tween_property(titles, "modulate:a", 0.0, 0.8)
	title_tween.tween_callback(titles.queue_free)


func _build_portal_interaction() -> void:
	var layer := CanvasLayer.new()
	layer.name = "PortalInteraction"
	add_child(layer)
	var stack := VBoxContainer.new()
	stack.name = "PromptStack"
	stack.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	stack.position = Vector2(-230.0, -118.0)
	stack.size = Vector2(460.0, 84.0)
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	layer.add_child(stack)
	portal_lore = Label.new()
	portal_lore.name = "PortalLore"
	portal_lore.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	portal_lore.add_theme_font_size_override("font_size", 18)
	portal_lore.add_theme_color_override("font_color", Color("d9f3e7"))
	portal_lore.add_theme_color_override("font_outline_color", Color(0.04, 0.08, 0.07, 0.9))
	portal_lore.add_theme_constant_override("outline_size", 7)
	portal_lore.hide()
	stack.add_child(portal_lore)
	portal_prompt = Label.new()
	portal_prompt.name = "PortalPrompt"
	portal_prompt.text = "F  调查"
	portal_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	portal_prompt.add_theme_font_size_override("font_size", 17)
	portal_prompt.add_theme_color_override("font_color", Color("edf4e8"))
	portal_prompt.add_theme_color_override("font_outline_color", Color(0.04, 0.07, 0.06, 0.92))
	portal_prompt.add_theme_constant_override("outline_size", 7)
	portal_prompt.hide()
	stack.add_child(portal_prompt)


func _build_audio() -> void:
	var ambience_stream := MistValleyAmbience.duplicate() as AudioStreamOggVorbis
	ambience_stream.loop = true
	var ambience := AudioStreamPlayer.new()
	ambience.name = "MistValleyAmbience"
	ambience.stream = ambience_stream
	ambience.volume_db = -17.0
	add_child(ambience)
	ambience.play()

	var hearth_stream := HearthFire.duplicate() as AudioStreamOggVorbis
	hearth_stream.loop = true
	var hearth_audio := AudioStreamPlayer3D.new()
	hearth_audio.name = "HearthFire"
	hearth_audio.stream = hearth_stream
	hearth_audio.position = (get_node("VillageHearth") as Node3D).position + Vector3.UP * 0.65
	hearth_audio.volume_db = -15.0
	hearth_audio.max_db = -20.0
	hearth_audio.unit_size = 2.5
	hearth_audio.max_distance = 14.0
	add_child(hearth_audio)
	hearth_audio.play()

	var hum_stream := PortalHum.duplicate() as AudioStreamOggVorbis
	hum_stream.loop = true
	portal_hum = AudioStreamPlayer3D.new()
	portal_hum.name = "PortalHum"
	portal_hum.stream = hum_stream
	portal_hum.position = portal_center + Vector3.UP * 1.8
	portal_hum.volume_db = -24.0
	portal_hum.unit_size = 4.0
	portal_hum.max_distance = 22.0
	add_child(portal_hum)
	portal_hum.play()

	var react_stream := PortalReact.duplicate() as AudioStreamOggVorbis
	react_stream.loop = false
	portal_react_player = AudioStreamPlayer3D.new()
	portal_react_player.name = "PortalReact"
	portal_react_player.stream = react_stream
	portal_react_player.position = portal_center + Vector3.UP * 1.8
	portal_react_player.volume_db = -7.0
	portal_react_player.unit_size = 4.0
	portal_react_player.max_distance = 18.0
	add_child(portal_react_player)

func _add_house(position: Vector3, rotation_y: float) -> void:
	var house := Node3D.new()
	house_count += 1
	house.name = "VillageHouse%d" % house_count
	house.position = position
	house.rotation.y = rotation_y
	add_child(house)
	houses.append(house)
	house_roofs_faded.append(false)
	var shell_material := plaster_material.duplicate() as StandardMaterial3D
	var trim_material := _material(Color("6f4c32"), 0.95)
	var interior_index := house_count - 1
	var interior_identities: Array[String] = ["herbalist", "hearth", "weaver"]
	var rug_colors: Array[Color] = [Color("697563"), Color("806552"), Color("755f66")]
	house.set_meta("interior_identity", interior_identities[interior_index])
	var rug_material := _material(rug_colors[interior_index], 0.98)
	var house_collision := _add_box("HouseCollision", Vector3(6.0, 3.1, 6.0), Vector3(0.0, 1.55, 0.0), shell_material, true, house)
	house_collision.visible = false
	_add_box("HouseWallLeft", Vector3(0.18, 3.1, 5.8), Vector3(-2.91, 1.55, 0.0), shell_material, false, house)
	_add_box("HouseWallRight", Vector3(0.18, 3.1, 5.8), Vector3(2.91, 1.55, 0.0), shell_material, false, house)
	_add_box("HouseWallBack", Vector3(5.8, 3.1, 0.18), Vector3(0.0, 1.55, -2.91), shell_material, false, house)
	_add_box("HouseInteriorFloor", Vector3(5.55, 0.06, 5.55), Vector3(0.0, 0.05, 0.0), interior_floor_material, false, house)
	_add_box("HouseStoneBaseLeft", Vector3(0.14, 0.42, 5.7), Vector3(-3.02, 0.21, 0.0), stone_material, false, house)
	_add_box("HouseStoneBaseRight", Vector3(0.14, 0.42, 5.7), Vector3(3.02, 0.21, 0.0), stone_material, false, house)
	_add_box("HouseStoneBaseBack", Vector3(5.7, 0.42, 0.14), Vector3(0.0, 0.21, -3.02), stone_material, false, house)
	for trim_data in [
		["HouseTrimLeftFront", Vector3(0.16, 3.0, 0.16), Vector3(-3.03, 1.5, 2.55)],
		["HouseTrimLeftMiddle", Vector3(0.16, 3.0, 0.16), Vector3(-3.03, 1.5, 0.0)],
		["HouseTrimLeftBack", Vector3(0.16, 3.0, 0.16), Vector3(-3.03, 1.5, -2.55)],
		["HouseTrimRightFront", Vector3(0.16, 3.0, 0.16), Vector3(3.03, 1.5, 2.55)],
		["HouseTrimRightMiddle", Vector3(0.16, 3.0, 0.16), Vector3(3.03, 1.5, 0.0)],
		["HouseTrimRightBack", Vector3(0.16, 3.0, 0.16), Vector3(3.03, 1.5, -2.55)],
		["HouseTrimBackMiddle", Vector3(0.16, 3.0, 0.16), Vector3(0.0, 1.5, -3.03)],
		["HouseTrimLeftTop", Vector3(0.16, 0.16, 5.7), Vector3(-3.03, 2.92, 0.0)],
		["HouseTrimRightTop", Vector3(0.16, 0.16, 5.7), Vector3(3.03, 2.92, 0.0)],
		["HouseTrimBackTop", Vector3(5.7, 0.16, 0.16), Vector3(0.0, 2.92, -3.03)],
	]:
		_add_box(trim_data[0], trim_data[1], trim_data[2], trim_material, false, house)
	var back_window := _add_model("res://assets/quaternius/village/Window_Wide_Round1.gltf", Vector3(0.0, 0.0, -3.0), PI, 0.86, house)
	back_window.name = "BackWindow"
	var rug_sizes: Array[Vector3] = [Vector3(2.1, 0.03, 1.0), Vector3(2.3, 0.03, 1.5), Vector3(1.8, 0.03, 1.4)]
	var rug_positions: Array[Vector3] = [Vector3(1.2, 0.085, 0.6), Vector3(0.9, 0.085, 0.55), Vector3(1.2, 0.085, 0.65)]
	var rug_yaws: Array[float] = [0.08, -0.08, 0.05]
	var rug := _add_box("InteriorRug", rug_sizes[interior_index], rug_positions[interior_index], rug_material, false, house)
	rug.rotation.y = rug_yaws[interior_index]
	var bench_centers: Array[Vector3] = [Vector3(1.45, 0.58, -1.75), Vector3(-1.55, 0.58, -1.15), Vector3(1.55, 0.58, -1.65)]
	var bench_yaws: Array[float] = [0.0, PI * 0.5, 0.0]
	var bench_center := bench_centers[interior_index]
	var bench_yaw := bench_yaws[interior_index]
	var bench_axis := Vector3.RIGHT.rotated(Vector3.UP, bench_yaw)
	var bench_seat := _add_box("InteriorBenchSeat", Vector3(1.55, 0.18, 0.48), bench_center, trim_material, false, house)
	bench_seat.rotation.y = bench_yaw
	var bench_left_leg := _add_box("InteriorBenchLeftLeg", Vector3(0.16, 0.5, 0.38), bench_center - bench_axis * 0.55 + Vector3.DOWN * 0.28, trim_material, false, house)
	bench_left_leg.rotation.y = bench_yaw
	var bench_right_leg := _add_box("InteriorBenchRightLeg", Vector3(0.16, 0.5, 0.38), bench_center + bench_axis * 0.55 + Vector3.DOWN * 0.28, trim_material, false, house)
	bench_right_leg.rotation.y = bench_yaw
	var crate_positions: Array[Vector3] = [Vector3(-1.9, 0.0, -1.35), Vector3(1.85, 0.0, -1.75), Vector3(-1.9, 0.0, -1.65)]
	var crate_yaws: Array[float] = [-0.35, 0.25, -0.2]
	var crate_scales: Array[float] = [0.55, 0.6, 0.55]
	var interior_crate := _add_model("res://assets/quaternius/village/Prop_Crate.gltf", crate_positions[interior_index], crate_yaws[interior_index], crate_scales[interior_index], house)
	interior_crate.name = "InteriorCrate"
	# One readable work center per home keeps the cutaway sparse but identifiable.
	match interior_index:
		0:
			var herb_table_material := _material(Color("6f5941"), 0.96)
			_add_box("InteriorHerbTableTop", Vector3(1.8, 0.14, 0.58), Vector3(1.2, 0.82, 0.6), herb_table_material, false, house)
			_add_box("InteriorHerbTableLeftLeg", Vector3(0.12, 0.75, 0.4), Vector3(0.6, 0.42, 0.6), herb_table_material, false, house)
			_add_box("InteriorHerbTableRightLeg", Vector3(0.12, 0.75, 0.4), Vector3(1.8, 0.42, 0.6), herb_table_material, false, house)
			var herb_bundle_colors: Array[Color] = [Color("718066"), Color("847b59"), Color("667369")]
			for bundle_index in 3:
				_add_box("InteriorHerbBundle%d" % bundle_index, Vector3(0.28, 0.1, 0.16), Vector3(0.75 + float(bundle_index) * 0.45, 0.94, 0.6), _material(herb_bundle_colors[bundle_index], 1.0), false, house)
		1:
			_add_box("InteriorHearthTableTop", Vector3(1.15, 0.18, 0.85), Vector3(0.9, 0.48, 0.55), trim_material, false, house)
			_add_box("InteriorHearthTableBase", Vector3(0.36, 0.45, 0.36), Vector3(0.9, 0.25, 0.55), trim_material, false, house)
			_add_box("InteriorHearthStool", Vector3(0.65, 0.34, 0.65), Vector3(1.9, 0.25, 0.55), trim_material, false, house)
		2:
			var loom_material := _material(Color("624b38"), 0.96)
			_add_box("InteriorLoomLeftPost", Vector3(0.12, 1.7, 0.14), Vector3(0.5, 0.9, 0.65), loom_material, false, house)
			_add_box("InteriorLoomRightPost", Vector3(0.12, 1.7, 0.14), Vector3(1.9, 0.9, 0.65), loom_material, false, house)
			_add_box("InteriorLoomTopBeam", Vector3(1.6, 0.12, 0.14), Vector3(1.2, 1.7, 0.65), loom_material, false, house)
			_add_box("InteriorLoomBottomBeam", Vector3(1.6, 0.12, 0.14), Vector3(1.2, 0.18, 0.65), loom_material, false, house)
			var cloth_colors: Array[Color] = [Color("785d66"), Color("88745a"), Color("667469")]
			for cloth_index in 3:
				_add_box("InteriorLoomCloth%d" % cloth_index, Vector3(0.38, 1.15, 0.04), Vector3(0.8 + float(cloth_index) * 0.4, 0.92, 0.75), _material(cloth_colors[cloth_index], 1.0), false, house)
	var roof := _add_model("res://assets/quaternius/village/Roof_RoundTiles_6x8.gltf", Vector3(0.0, 3.05, 0.0), 0.0, 0.82, house)
	roof.name = "Roof"
	_add_model("res://assets/quaternius/village/Wall_Plaster_Straight.gltf", Vector3(-2.0, 0.0, 3.03), 0.0, 1.0, house)
	_add_model("res://assets/quaternius/village/Wall_Plaster_Door_Round.gltf", Vector3(0.0, 0.0, 3.03), 0.0, 1.0, house)
	_add_model("res://assets/quaternius/village/Wall_Plaster_Window_Wide_Round.gltf", Vector3(2.0, 0.0, 3.03), 0.0, 1.0, house)
	var door := _add_model("res://assets/quaternius/village/Door_1_Round.gltf", Vector3(-0.515, 0.0, 3.09), 0.0, 1.0, house)
	door.name = "Door"
	var window := _add_model("res://assets/quaternius/village/Window_Wide_Round1.gltf", Vector3(2.0, 0.0, 2.875), 0.0, 1.0, house)
	window.name = "Window"
	_add_model("res://assets/quaternius/village/Prop_Crate.gltf", Vector3(-2.2, 0.0, 3.8), 0.25, 0.85, house)
	_add_model("res://assets/quaternius/village/Prop_Vine1.gltf", Vector3(-1.55, 0.35, 3.2), 0.0, 0.78, house)
	var chimney := _add_model("res://assets/quaternius/village/Prop_Chimney.gltf", Vector3(-2.45, 3.1, 0.8), 0.0, 1.0, house)
	chimney.name = "Chimney"
	chimney.reparent(roof, true)
	for house_mesh in house.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := house_mesh as MeshInstance3D
		for surface_index in mesh_instance.mesh.get_surface_count():
			var source_material := mesh_instance.mesh.surface_get_material(surface_index) as StandardMaterial3D
			if source_material == null:
				continue
			if source_material.resource_name == "MI_WindowGlass":
				var glass_material := source_material.duplicate() as StandardMaterial3D
				glass_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				glass_material.albedo_color = Color(0.52, 0.30, 0.13, 0.66)
				glass_material.roughness = 0.72
				glass_material.emission_enabled = true
				glass_material.emission = Color(0.64, 0.34, 0.13)
				glass_material.emission_energy_multiplier = 0.18
				mesh_instance.set_surface_override_material(surface_index, glass_material)
				window_glass_materials.append(glass_material)
			elif mesh_instance == roof or roof.is_ancestor_of(mesh_instance):
				var roof_material := source_material.duplicate() as StandardMaterial3D
				if source_material.resource_name == "MI_WoodTrim":
					roof_material.albedo_color = Color("c6b99a")
				elif source_material.resource_name == "MI_RoundTiles":
					roof_material.albedo_texture = MutedRoofTiles
					roof_material.render_priority = 1
				roof_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				mesh_instance.set_surface_override_material(surface_index, roof_material)
				house_fade_materials.append(roof_material)
				house_fade_alphas.append(roof_material.albedo_color.a)
				house_fade_house_indices.append(interior_index)
	var window_glow := OmniLight3D.new()
	window_glow.name = "WindowGlow"
	window_glow.position = Vector3(2.0, 1.85, 3.18)
	window_glow.light_color = Color("ffc276")
	window_glow.light_energy = 0.14
	window_glow.omni_range = 2.6
	window_glow.shadow_enabled = false
	house.add_child(window_glow)
	window_glows.append(window_glow)
	_add_smoke(house, Vector3(-2.45, 6.45, 0.8))


func _add_smoke(parent: Node3D, origin: Vector3, drift_scale := 1.0, size_scale := 1.0, opacity_scale := 1.0) -> void:
	if smoke_mesh == null:
		var smoke_gradient := Gradient.new()
		smoke_gradient.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
		smoke_gradient.colors = PackedColorArray([
			Color(0.56, 0.61, 0.58, 0.46),
			Color(0.62, 0.66, 0.63, 0.24),
			Color(0.68, 0.72, 0.69, 0.0),
		])
		var smoke_texture := GradientTexture2D.new()
		smoke_texture.gradient = smoke_gradient
		smoke_texture.width = 64
		smoke_texture.height = 64
		smoke_texture.fill = GradientTexture2D.FILL_RADIAL
		smoke_texture.fill_from = Vector2(0.5, 0.5)
		smoke_texture.fill_to = Vector2(1.0, 0.5)
		smoke_mesh = QuadMesh.new()
		smoke_mesh.size = Vector2(0.9, 0.9)
		smoke_material = StandardMaterial3D.new()
		smoke_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		smoke_material.albedo_texture = smoke_texture
		smoke_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		smoke_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	for puff_index in 3:
		var puff := MeshInstance3D.new()
		puff.name = "SmokePuff%d" % puff_index
		puff.mesh = smoke_mesh
		puff.material_override = smoke_material
		puff.position = origin
		parent.add_child(puff)
		smoke_puffs.append(puff)
		smoke_origins.append(origin)
		smoke_drift_scales.append(drift_scale)
		smoke_size_scales.append(size_scale)
		smoke_opacity_scales.append(opacity_scale)


func _add_village_hearth() -> void:
	var hearth := Node3D.new()
	hearth.name = "VillageHearth"
	hearth.position = Vector3(4.3, 0.0, -5.5)
	add_child(hearth)
	for stone_index in 7:
		var angle := TAU * float(stone_index) / 7.0
		_add_model("res://assets/quaternius/nature/Rock_Medium_1.gltf", Vector3(cos(angle) * 0.72, 0.05, sin(angle) * 0.72), angle, 0.13, hearth)
	var wood_material := _material(Color("513424"), 0.9)
	for log_rotation in [-0.55, 0.55]:
		var log := CSGCylinder3D.new()
		log.name = "FireLog"
		log.radius = 0.13
		log.height = 1.15
		log.sides = 8
		log.position.y = 0.28
		log.rotation = Vector3(0.0, log_rotation, PI * 0.5)
		log.material = wood_material
		hearth.add_child(log)
	for bench_data in [
		["HearthBenchEast", Vector3(1.45, 0.0, 0.15), PI * 0.5],
		["HearthBenchSouth", Vector3(0.0, 0.0, -1.4), 0.0],
	]:
		var bench := Node3D.new()
		bench.name = bench_data[0]
		bench.position = bench_data[1]
		bench.rotation.y = bench_data[2]
		hearth.add_child(bench)
		var seat := CSGCylinder3D.new()
		seat.name = "Seat"
		seat.radius = 0.22
		seat.height = 1.65
		seat.sides = 8
		seat.position.y = 0.46
		seat.rotation.z = PI * 0.5
		seat.material = wood_material
		seat.use_collision = true
		bench.add_child(seat)
		for leg_data in [["LeftLeg", -0.58], ["RightLeg", 0.58]]:
			var leg := CSGCylinder3D.new()
			leg.name = leg_data[0]
			leg.radius = 0.13
			leg.height = 0.42
			leg.sides = 8
			leg.position = Vector3(leg_data[1], 0.2, 0.0)
			leg.material = wood_material
			leg.use_collision = false
			bench.add_child(leg)
	var wood_crate := _add_model("res://assets/quaternius/village/Prop_Crate.gltf", Vector3(1.35, 0.0, -1.25), -0.2, 0.52, hearth)
	wood_crate.name = "HearthWoodCrate"
	hearth_ember_material = _material(Color("d85a28"), 0.5)
	hearth_ember_material.emission_enabled = true
	hearth_ember_material.emission = Color("ff792f")
	hearth_ember_material.emission_energy_multiplier = 1.5
	var ember := CSGCylinder3D.new()
	ember.name = "FireEmber"
	ember.radius = 0.5
	ember.height = 0.08
	ember.sides = 16
	ember.position.y = 0.14
	ember.material = hearth_ember_material
	ember.use_collision = true
	hearth.add_child(ember)
	hearth_flame_material = _material(Color(1.0, 0.44, 0.12, 0.82), 0.4)
	hearth_flame_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	hearth_flame_material.emission_enabled = true
	hearth_flame_material.emission = Color("ff6f24")
	hearth_flame_material.emission_energy_multiplier = 2.2
	hearth_flame_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for flame_index in 3:
		var flame := CSGPolygon3D.new()
		flame.name = "Flame%d" % flame_index
		var tip_offset := -0.06 + float(flame_index) * 0.06
		flame.polygon = PackedVector2Array([
			Vector2(-0.28, -0.36),
			Vector2(0.28, -0.36),
			Vector2(0.23, -0.08),
			Vector2(0.14, 0.16),
			Vector2(tip_offset, 0.46),
			Vector2(-0.08, 0.24),
			Vector2(-0.2, 0.04),
		])
		flame.depth = 0.24
		flame.material = hearth_flame_material
		flame.use_collision = false
		var origin := Vector3(
			(float(flame_index) - 1.0) * 0.23,
			0.56 + float(flame_index % 2) * 0.1,
			-0.08 + float(flame_index % 2) * 0.16
		)
		flame.position = origin
		flame.rotation.y = -0.18 + float(flame_index) * 0.18
		flame.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		hearth.add_child(flame)
		hearth_flames.append(flame)
		hearth_flame_origins.append(origin)
	hearth_light = OmniLight3D.new()
	hearth_light.name = "HearthLight"
	hearth_light.position.y = 0.75
	hearth_light.light_color = Color("ff9a4d")
	hearth_light.light_energy = 0.8
	hearth_light.omni_range = 5.0
	hearth_light.shadow_enabled = false
	hearth.add_child(hearth_light)
	_add_smoke(hearth, Vector3(0.0, 1.15, 0.0), 1.6, 1.15, 1.2)


func _add_pond(position: Vector3) -> void:
	var pond := Node3D.new()
	pond.name = "MistPond"
	pond.position = position
	add_child(pond)
	var water_gradient := Gradient.new()
	water_gradient.offsets = PackedFloat32Array([0.0, 0.78, 1.0])
	water_gradient.colors = PackedColorArray([
		Color(0.18, 0.4, 0.42, 0.82),
		Color(0.25, 0.48, 0.46, 0.75),
		Color(0.31, 0.5, 0.44, 0.0),
	])
	var water_texture := GradientTexture2D.new()
	water_texture.gradient = water_gradient
	water_texture.width = 128
	water_texture.height = 128
	water_texture.fill = GradientTexture2D.FILL_RADIAL
	water_texture.fill_from = Vector2(0.5, 0.5)
	water_texture.fill_to = Vector2(1.0, 0.5)
	var water_material := StandardMaterial3D.new()
	water_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	water_material.albedo_texture = water_texture
	water_material.roughness = 0.25
	water_material.emission_enabled = true
	water_material.emission = Color("2d5757")
	water_material.emission_energy_multiplier = 0.07
	var water_mesh := PlaneMesh.new()
	water_mesh.size = Vector2(8.0, 5.2)
	var water := MeshInstance3D.new()
	water.name = "Water"
	water.mesh = water_mesh
	water.material_override = water_material
	water.position.y = 0.055
	pond.add_child(water)
	var collision := CSGCylinder3D.new()
	collision.name = "PondCollision"
	collision.radius = 2.25
	collision.height = 0.9
	collision.sides = 24
	collision.position.y = 0.4
	collision.scale.x = 1.55
	collision.use_collision = true
	collision.visible = false
	pond.add_child(collision)
	var shore_positions := [
		Vector3(-3.5, 0.0, -0.7), Vector3(-2.5, 0.0, -2.15),
		Vector3(-0.5, 0.0, -2.55), Vector3(1.8, 0.0, -2.25),
		Vector3(3.55, 0.0, -0.65), Vector3(3.25, 0.0, 1.55),
		Vector3(1.0, 0.0, 2.45), Vector3(-2.75, 0.0, 1.75),
	]
	for index in shore_positions.size():
		var rock_name := "Rock_Medium_%d" % (index % 2 + 1)
		_add_model("res://assets/quaternius/nature/%s.gltf" % rock_name, shore_positions[index], float(index) * 0.7, 0.14 + float(index % 3) * 0.025, pond)
	var plant_data := [
		["Grass_Common_Tall", Vector3(-3.2, 0.0, 0.65), 0.5, 0.62],
		["Grass_Common_Tall", Vector3(2.85, 0.0, -1.45), 1.8, 0.55],
		["Fern_1", Vector3(-1.85, 0.0, 2.1), 2.2, 0.28],
		["Fern_1", Vector3(2.45, 0.0, 1.75), 0.8, 0.26],
		["Bush_Common_Flowers", Vector3(-3.45, 0.0, -1.45), 1.2, 0.48],
	]
	for plant_data_item in plant_data:
		var plant := _add_model("res://assets/quaternius/nature/%s.gltf" % plant_data_item[0], plant_data_item[1], plant_data_item[2], plant_data_item[3], pond)
		if plant != null:
			wind_nodes.append(plant)
	var ripple_material := _material(Color(0.58, 0.74, 0.7, 0.3), 0.25)
	ripple_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ripple_material.emission_enabled = true
	ripple_material.emission = Color("82bdb4")
	ripple_material.emission_energy_multiplier = 0.1
	var ripple_mesh := TorusMesh.new()
	ripple_mesh.inner_radius = 0.52
	ripple_mesh.outer_radius = 0.58
	ripple_mesh.rings = 32
	ripple_mesh.ring_segments = 16
	for index in 2:
		var ripple := MeshInstance3D.new()
		ripple.name = "Ripple%d" % index
		ripple.mesh = ripple_mesh
		ripple.material_override = ripple_material
		ripple.position = Vector3(-0.8 + float(index) * 1.6, 0.075, -0.35 + float(index) * 0.7)
		pond.add_child(ripple)
		pond_ripples.append(ripple)


func _add_mistcaps() -> void:
	var stem_mesh := CylinderMesh.new()
	stem_mesh.top_radius = 0.035
	stem_mesh.bottom_radius = 0.055
	stem_mesh.height = 0.22
	stem_mesh.radial_segments = 7
	var cap_mesh := SphereMesh.new()
	cap_mesh.radius = 0.18
	cap_mesh.height = 0.18
	cap_mesh.radial_segments = 10
	cap_mesh.rings = 4
	var stem_material := _material(Color("d2d7c6"), 0.85)
	mistcap_material = _material(Color("8ec8ad"), 0.48)
	mistcap_material.emission_enabled = true
	mistcap_material.emission = Color("76bda5")
	mistcap_material.emission_energy_multiplier = 0.42
	var cluster_positions := [
		Vector3(-13.7, 0.0, 14.6),
		Vector3(-6.8, 0.0, 10.2),
		Vector3(-17.2, 0.0, 6.8),
		Vector3(17.0, 0.0, 17.5),
	]
	var offsets := [Vector3(-0.28, 0.0, 0.08), Vector3(0.12, 0.0, -0.18), Vector3(0.34, 0.0, 0.22)]
	for cluster_index in cluster_positions.size():
		var cluster := Node3D.new()
		cluster.name = "MistcapCluster%d" % (cluster_index + 1)
		cluster.position = cluster_positions[cluster_index]
		add_child(cluster)
		for mushroom_index in offsets.size():
			var size := 0.75 + float((cluster_index + mushroom_index) % 3) * 0.15
			var stem := MeshInstance3D.new()
			stem.name = "Stem%d" % mushroom_index
			stem.mesh = stem_mesh
			stem.position = offsets[mushroom_index] + Vector3.UP * 0.11 * size
			stem.scale = Vector3.ONE * size
			stem.material_override = stem_material
			cluster.add_child(stem)
			var cap := MeshInstance3D.new()
			cap.name = "Cap%d" % mushroom_index
			cap.mesh = cap_mesh
			cap.position = offsets[mushroom_index] + Vector3.UP * 0.25 * size
			cap.scale = Vector3(size, size * 0.72, size)
			cap.material_override = mistcap_material
			cluster.add_child(cap)
			mistcap_caps.append(cap)
		var glow := OmniLight3D.new()
		glow.name = "MistcapGlow"
		glow.position = Vector3(0.05, 0.32, 0.02)
		glow.light_color = Color("8bcab4")
		glow.light_energy = 0.12
		glow.omni_range = 2.2
		glow.shadow_enabled = false
		cluster.add_child(glow)
		mistcap_lights.append(glow)


func _add_herb_plot() -> void:
	var plot := Node3D.new()
	plot.name = "HerbPlot"
	plot.position = HERB_PLOT_POSITION
	plot.rotation.y = PI * 0.5
	add_child(plot)
	_add_box("Soil", Vector3(4.6, 0.08, 2.8), Vector3(0.0, 0.04, 0.0), _material(Color("4e3b2b"), 1.0), false, plot)
	var edging_material := _material(Color("6b4b2d"), 0.9)
	_add_box("NorthEdge", Vector3(4.8, 0.14, 0.12), Vector3(0.0, 0.1, -1.46), edging_material, false, plot)
	_add_box("SouthEdge", Vector3(4.8, 0.14, 0.12), Vector3(0.0, 0.1, 1.46), edging_material, false, plot)
	_add_box("MiddleEdge", Vector3(4.5, 0.1, 0.1), Vector3(0.0, 0.085, 0.0), edging_material, false, plot)
	_add_box("WestEdge", Vector3(0.12, 0.14, 2.8), Vector3(-2.36, 0.1, 0.0), edging_material, false, plot)
	_add_box("EastEdge", Vector3(0.12, 0.14, 2.8), Vector3(2.36, 0.1, 0.0), edging_material, false, plot)
	var plants := [
		["Fern_1", Vector3(-1.65, 0.08, -0.58), -0.3, 0.24],
		["Grass_Common_Tall", Vector3(-0.82, 0.08, -0.62), 0.5, 0.34],
		["Bush_Common_Flowers", Vector3(0.02, 0.08, -0.56), 1.1, 0.28],
		["Fern_1", Vector3(0.85, 0.08, -0.62), 2.0, 0.22],
		["Grass_Common_Tall", Vector3(1.62, 0.08, -0.54), 2.6, 0.3],
		["Bush_Common_Flowers", Vector3(-1.55, 0.08, 0.58), 0.2, 0.26],
		["Fern_1", Vector3(-0.72, 0.08, 0.62), 1.8, 0.22],
		["Grass_Common_Tall", Vector3(0.08, 0.08, 0.56), 2.4, 0.32],
		["Bush_Common_Flowers", Vector3(0.88, 0.08, 0.62), 0.9, 0.24],
		["Fern_1", Vector3(1.58, 0.08, 0.54), 2.9, 0.22],
	]
	for plant_data in plants:
		var plant := _add_model("res://assets/quaternius/nature/%s.gltf" % plant_data[0], plant_data[1], plant_data[2], plant_data[3], plot)
		if plant != null:
			wind_nodes.append(plant)


func _add_village_props() -> void:
	var props := Node3D.new()
	props.name = "VillageProps"
	add_child(props)
	var wagon := _add_model("res://assets/quaternius/village/Prop_Wagon.gltf", Vector3(-5.8, 0.0, -2.7), 1.37, 0.9, props)
	wagon.name = "VillageWagon"
	var wagon_crate_large := _add_model("res://assets/quaternius/village/Prop_Crate.gltf", Vector3(-7.4, 0.0, -2.1), 0.16, 0.75, props)
	wagon_crate_large.name = "WagonUnloadCrateLarge"
	var wagon_crate_small := _add_model("res://assets/quaternius/village/Prop_Crate.gltf", Vector3(-7.45, 0.0, -3.0), 0.42, 0.55, props)
	wagon_crate_small.name = "WagonUnloadCrateSmall"
	_add_model("res://assets/quaternius/village/Prop_WoodenFence_Single.gltf", Vector3(6.4, 0.0, -1.6), -0.18, 1.0, props)
	_add_model("res://assets/quaternius/village/Prop_WoodenFence_Extension1.gltf", Vector3(8.4, 0.0, -1.95), -0.18, 1.0, props)
	_add_model("res://assets/quaternius/village/Prop_WoodenFence_Extension1.gltf", Vector3(10.4, 0.0, -2.3), -0.18, 1.0, props)
	var work_wood_material := _material(Color("6f4c32"), 0.95)
	var village_marker := Node3D.new()
	village_marker.name = "VillageBoundaryMarker"
	village_marker.position = Vector3(3.35, 0.0, 5.1)
	village_marker.rotation.y = -0.08
	props.add_child(village_marker)
	var marker_stone := _add_model("res://assets/quaternius/nature/Rock_Medium_1.gltf", Vector3.ZERO, 0.45, 0.16, village_marker)
	marker_stone.name = "BoundaryFooting"
	var boundary_stone := CSGPolygon3D.new()
	boundary_stone.name = "BoundaryStone"
	boundary_stone.polygon = PackedVector2Array([
		Vector2(-0.22, 0.0), Vector2(0.2, 0.0), Vector2(0.17, 0.5),
		Vector2(0.07, 0.72), Vector2(-0.13, 0.65), Vector2(-0.2, 0.38),
	])
	boundary_stone.depth = 0.3
	boundary_stone.position = Vector3(0.0, 0.03, 0.0)
	boundary_stone.rotation.z = -0.055
	boundary_stone.material = stone_material
	boundary_stone.use_collision = false
	village_marker.add_child(boundary_stone)
	var village_wedge := _add_box("VillageWedge", Vector3(0.12, 0.11, 0.32), Vector3(0.03, 0.52, -0.2), work_wood_material, false, village_marker)
	village_wedge.rotation.y = -0.12
	village_wedge.rotation.x = -0.05
	var herb_rack := Node3D.new()
	herb_rack.name = "HerbDryingRack"
	herb_rack.position = Vector3(-15.6, 0.0, -12.6)
	herb_rack.rotation.y = 0.16
	props.add_child(herb_rack)
	var herb_left_post := _add_box("LeftPost", Vector3(0.1, 1.45, 0.1), Vector3(-0.72, 0.72, 0.0), work_wood_material, false, herb_rack)
	herb_left_post.rotation.z = -0.025
	var herb_right_post := _add_box("RightPost", Vector3(0.11, 1.4, 0.1), Vector3(0.72, 0.7, 0.0), work_wood_material, false, herb_rack)
	herb_right_post.rotation.z = 0.018
	var herb_crossbar := _add_box("Crossbar", Vector3(1.55, 0.09, 0.09), Vector3(0.0, 1.38, 0.0), work_wood_material, false, herb_rack)
	herb_crossbar.rotation.z = 0.012
	_add_box("DryingLine", Vector3(1.42, 0.035, 0.035), Vector3(0.0, 1.2, 0.0), _material(Color("4f3b2c"), 1.0), false, herb_rack)
	for bundle_index in 4:
		var bundle := _add_model(
			"res://assets/quaternius/nature/Grass_Common_Tall.gltf",
			Vector3(-0.54 + float(bundle_index) * 0.36, 1.08 - float(bundle_index % 2) * 0.08, 0.0),
			0.0,
			0.22 + float(bundle_index % 3) * 0.025,
			herb_rack
		)
		bundle.name = "HerbBundle%d" % bundle_index
		bundle.rotation.z = PI + (-0.1 + float(bundle_index) * 0.065)
	var herb_crate := _add_model("res://assets/quaternius/village/Prop_Crate.gltf", Vector3(-14.35, 0.0, -12.55), 0.2, 0.48, props)
	herb_crate.name = "HerbHarvestCrate"
	var weaving_line := Node3D.new()
	weaving_line.name = "WeaverDryingLine"
	weaving_line.position = Vector3(-4.7, 0.0, 5.25)
	weaving_line.rotation.y = 0.04
	props.add_child(weaving_line)
	var cloth_left_post := _add_box("LeftPost", Vector3(0.12, 1.65, 0.12), Vector3(-1.35, 0.82, 0.0), work_wood_material, false, weaving_line)
	cloth_left_post.rotation.z = -0.028
	var cloth_right_post := _add_box("RightPost", Vector3(0.1, 1.58, 0.11), Vector3(1.35, 0.79, 0.0), work_wood_material, false, weaving_line)
	cloth_right_post.rotation.z = 0.02
	var cloth_crossbar := _add_box("Crossbar", Vector3(2.82, 0.1, 0.1), Vector3(0.0, 1.58, 0.0), work_wood_material, false, weaving_line)
	cloth_crossbar.rotation.z = 0.01
	for cloth_data in [
		["ClothRose", Vector3(-0.78, 1.15, 0.0), Color("8e5c60"), 0.58, 0.72, 0.03],
		["ClothMoss", Vector3(0.0, 1.08, 0.0), Color("737b58"), 0.64, 0.86, -0.02],
		["ClothOchre", Vector3(0.78, 1.17, 0.0), Color("98744e"), 0.54, 0.68, 0.05],
	]:
		var width: float = cloth_data[3]
		var height: float = cloth_data[4]
		var cloth := CSGPolygon3D.new()
		cloth.name = cloth_data[0]
		cloth.polygon = PackedVector2Array([
			Vector2(-width * 0.5, height * 0.5),
			Vector2(0.0, height * 0.45),
			Vector2(width * 0.5, height * 0.5),
			Vector2(width * 0.44, -height * 0.38),
			Vector2(width * 0.08, -height * 0.52),
			Vector2(-width * 0.46, -height * 0.43),
		])
		cloth.depth = 0.035
		cloth.position = cloth_data[1]
		cloth.rotation.z = cloth_data[5]
		cloth.material = _material(cloth_data[2], 1.0)
		cloth.use_collision = false
		weaving_line.add_child(cloth)
		wind_nodes.append(cloth)
	var wagon_collision := _add_box("WagonCollision", Vector3(1.9, 1.5, 2.6), Vector3(-5.8, 0.75, -2.7), stone_material, true, props)
	wagon_collision.rotation.y = 1.37
	wagon_collision.visible = false
	var fence_collision := _add_box("FenceCollision", Vector3(6.1, 0.9, 0.25), Vector3(8.4, 0.45, -1.95), stone_material, true, props)
	fence_collision.rotation.y = -0.18
	fence_collision.visible = false


func _add_mist_pass() -> void:
	var pass_root := Node3D.new()
	pass_root.name = "MistPass"
	add_child(pass_root)

	var boundary := _add_box(
		"MistPassBoundary",
		Vector3(8.0, 4.0, 0.8),
		Vector3(0.0, 2.0, -31.2),
		stone_material,
		true,
		pass_root
	)
	boundary.visible = false

	for pillar_data in [
		["MistPillarLeft", Vector3(-3.65, 1.55, -26.5), -0.12],
		["MistPillarRight", Vector3(3.65, 1.55, -26.5), 0.1],
	]:
		var pillar := CSGCylinder3D.new()
		pillar.name = pillar_data[0]
		pillar.radius = 0.72
		pillar.height = 3.1
		pillar.sides = 8
		pillar.position = pillar_data[1]
		pillar.rotation.z = pillar_data[2]
		pillar.material = stone_material
		pillar.use_collision = true
		pass_root.add_child(pillar)

	var step_material := path_material.duplicate() as StandardMaterial3D
	step_material.albedo_color = Color("686b60")
	step_material.roughness = 0.98
	step_material.uv1_scale = Vector3.ONE * 3.5
	for step_index in 3:
		_add_box(
			"MistStep%d" % step_index,
			Vector3(5.6 - float(step_index) * 0.35, 0.12, 1.75),
			Vector3(0.0, 0.06 + float(step_index) * 0.055, -23.0 - float(step_index) * 1.8),
			step_material,
			false,
			pass_root
		)

	var mist_material := ShaderMaterial.new()
	mist_material.shader = MistCurtainShader
	var mist_mesh := QuadMesh.new()
	mist_mesh.size = Vector2(8.0, 5.0)
	var mist_curtain := MeshInstance3D.new()
	mist_curtain.name = "MistCurtain"
	mist_curtain.mesh = mist_mesh
	mist_curtain.material_override = mist_material
	mist_curtain.position = Vector3(0.0, 2.4, -29.4)
	mist_curtain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	pass_root.add_child(mist_curtain)

	mist_pass_rune_material = _material(Color("79c9bd"), 0.25)
	mist_pass_rune_material.emission_enabled = true
	mist_pass_rune_material.emission = Color("78d6c8")
	mist_pass_rune_material.emission_energy_multiplier = 1.5
	var rune_mesh := SphereMesh.new()
	rune_mesh.radius = 0.11
	rune_mesh.height = 0.22
	rune_mesh.radial_segments = 10
	rune_mesh.rings = 5
	for rune_data in [
		["MistRuneLeft", Vector3(-2.8, 1.1, -27.0)],
		["MistRuneRight", Vector3(2.8, 1.1, -27.0)],
	]:
		var rune := MeshInstance3D.new()
		rune.name = rune_data[0]
		rune.mesh = rune_mesh
		rune.material_override = mist_pass_rune_material
		rune.position = rune_data[1]
		pass_root.add_child(rune)

	for rock_data in [
		["Rock_Medium_1", Vector3(-4.7, 0.0, -25.7), 0.3, 1.45],
		["Rock_Medium_2", Vector3(4.8, 0.0, -25.8), 2.1, 1.5],
		["Rock_Medium_2", Vector3(-3.9, 0.0, -28.5), 1.2, 1.15],
		["Rock_Medium_1", Vector3(4.0, 0.0, -28.6), 2.7, 1.1],
	]:
		_add_model(
			"res://assets/quaternius/nature/%s.gltf" % rock_data[0],
			rock_data[1],
			rock_data[2],
			rock_data[3],
			pass_root
		)

	for light_data in [
		["MistPassLightLeft", Vector3(-2.8, 1.15, -27.0)],
		["MistPassLightRight", Vector3(2.8, 1.15, -27.0)],
	]:
		var light := OmniLight3D.new()
		light.name = light_data[0]
		light.position = light_data[1]
		light.light_color = Color("8fb9b2")
		light.light_energy = 0.42
		light.omni_range = 4.0
		pass_root.add_child(light)
		mist_pass_lights.append(light)


func _add_boundary_scenery() -> void:
	var boundary := Node3D.new()
	boundary.name = "BoundaryScenery"
	add_child(boundary)
	var rocks := [
		[Vector3(-24.5, 0, -22), 0.2, 2.1], [Vector3(-24.2, 0, -12), 1.4, 1.8],
		[Vector3(-24.7, 0, -2), 2.5, 2.2], [Vector3(-24.3, 0, 8), 0.8, 1.9],
		[Vector3(-24.6, 0, 18), 1.9, 2.3], [Vector3(-24.1, 0, 28), 2.9, 1.9],
		[Vector3(24.5, 0, -22), 2.7, 2.0], [Vector3(24.2, 0, -12), 0.5, 2.2],
		[Vector3(24.7, 0, -2), 1.6, 1.8], [Vector3(24.3, 0, 8), 2.3, 2.1],
		[Vector3(24.6, 0, 18), 0.9, 1.9], [Vector3(24.1, 0, 28), 1.8, 2.3],
		[Vector3(-20, 0, -24.5), 0.3, 2.0], [Vector3(-10, 0, -24.2), 1.2, 2.2],
		[Vector3(10, 0, -24.3), 2.8, 2.3],
		[Vector3(20, 0, -24.5), 0.7, 2.0], [Vector3(-20, 0, 29.5), 2.5, 2.2],
		[Vector3(-10, 0, 29.2), 1.5, 1.9], [Vector3(0, 0, 29.7), 0.4, 2.3],
		[Vector3(10, 0, 29.3), 2.0, 2.0], [Vector3(20, 0, 29.5), 1.0, 2.2],
	]
	for index in rocks.size():
		var model := "Rock_Medium_1" if index % 2 == 0 else "Rock_Medium_2"
		_add_model("res://assets/quaternius/nature/%s.gltf" % model, rocks[index][0], rocks[index][1], rocks[index][2], boundary)
	var trees := [
		["Pine_2", Vector3(-24.8, 0, -12.5), 0.4, 1.1], ["CommonTree_1", Vector3(-22, 0, 14), 1.5, 1.0],
		["CommonTree_3", Vector3(22, 0, -16), 2.2, 0.95], ["Pine_2", Vector3(22, 0, 15), 0.9, 1.15],
		["CommonTree_1", Vector3(-15, 0, -22), 1.9, 1.0], ["CommonTree_3", Vector3(15, 0, -22), 0.5, 0.92],
		["Pine_2", Vector3(-14, 0, 27), 2.7, 1.1], ["CommonTree_1", Vector3(14, 0, 27), 1.2, 1.05],
	]
	for tree in trees:
		var instance := _add_model("res://assets/quaternius/nature/%s.gltf" % tree[0], tree[1], tree[2], tree[3], boundary)
		_apply_tree_canopy_wind(instance)


func _add_fog_banks() -> void:
	var fog_gradient := Gradient.new()
	fog_gradient.offsets = PackedFloat32Array([0.0, 0.58, 1.0])
	fog_gradient.colors = PackedColorArray([
		Color(0.76, 0.84, 0.81, 0.2),
		Color(0.72, 0.82, 0.8, 0.1),
		Color(0.68, 0.78, 0.77, 0.0),
	])
	var fog_texture := GradientTexture2D.new()
	fog_texture.gradient = fog_gradient
	fog_texture.width = 128
	fog_texture.height = 64
	fog_texture.fill = GradientTexture2D.FILL_RADIAL
	fog_texture.fill_from = Vector2(0.5, 0.5)
	fog_texture.fill_to = Vector2(1.0, 0.5)
	var fog_material := StandardMaterial3D.new()
	fog_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fog_material.albedo_texture = fog_texture
	fog_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fog_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	var fog_mesh := QuadMesh.new()
	fog_mesh.size = Vector2(7.5, 3.2)
	var positions := [
		Vector3(-20.0, 1.4, -12.0),
		Vector3(20.0, 1.3, -7.0),
		Vector3(-18.5, 1.2, 12.0),
		Vector3(19.0, 1.4, 18.0),
		Vector3(-7.0, 1.6, -23.0),
		Vector3(8.0, 1.1, 27.0),
		Vector3(0.0, 1.55, -28.0),
	]
	for index in positions.size():
		var fog := MeshInstance3D.new()
		fog.name = "FogBank%d" % index
		fog.mesh = fog_mesh
		fog.material_override = fog_material
		fog.position = positions[index]
		fog.scale = Vector3(1.0 + float(index % 3) * 0.16, 0.85 + float(index % 2) * 0.18, 1.0)
		if index == 6:
			fog.scale = Vector3(1.8, 1.4, 1.0)
		fog.transparency = 0.34
		fog.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(fog)
		fog_banks.append(fog)
		fog_bank_origins.append(fog.position)


func _add_nature(model: String, position: Vector3, rotation_y: float, scale: float, collision := true) -> void:
	var instance := _add_model("res://assets/quaternius/nature/%s.gltf" % model, position, rotation_y, scale)
	if instance != null and ("Tree" in model or model.begins_with("Pine")):
		_apply_tree_canopy_wind(instance)
	if instance != null and model == "Bush_Common":
		instance.name = "SeasonalBush%d" % seasonal_bushes.size()
		for mesh_node in instance.find_children("*", "MeshInstance3D", true, false):
			var mesh_instance := mesh_node as MeshInstance3D
			for surface_index in mesh_instance.mesh.get_surface_count():
				var source_material := mesh_instance.mesh.surface_get_material(surface_index) as StandardMaterial3D
				if source_material == null:
					continue
				var bush_material := source_material.duplicate() as StandardMaterial3D
				bush_material.resource_name = "SeasonalBushLeaves"
				bush_material.albedo_texture = MutedBushLeaves
				mesh_instance.set_surface_override_material(surface_index, bush_material)
				seasonal_bush_materials.append(bush_material)
		seasonal_bushes.append(instance)
	if instance != null and (model.begins_with("Bush") or model.begins_with("Fern") or model.begins_with("Grass")):
		wind_nodes.append(instance)
	if collision:
		var trunk := CSGCylinder3D.new()
		trunk.name = "%sCollision" % model
		trunk.radius = 0.45 * scale
		trunk.height = 3.5 * scale
		trunk.position = position + Vector3.UP * trunk.height * 0.5
		trunk.use_collision = true
		trunk.visible = false
		add_child(trunk)


func _apply_tree_canopy_wind(instance: Node3D) -> void:
	if instance == null:
		return
	for mesh_node in instance.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := mesh_node as MeshInstance3D
		for surface_index in mesh_instance.mesh.get_surface_count():
			var source_material := mesh_instance.mesh.surface_get_material(surface_index) as StandardMaterial3D
			if source_material == null or not source_material.resource_name.begins_with("Leaves_"):
				continue
			var arrays := mesh_instance.mesh.surface_get_arrays(surface_index)
			var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
			var canopy_min_y := INF
			var canopy_max_y := -INF
			for vertex in vertices:
				canopy_min_y = minf(canopy_min_y, vertex.y)
				canopy_max_y = maxf(canopy_max_y, vertex.y)
			var material := ShaderMaterial.new()
			material.resource_name = "Wind%s" % source_material.resource_name
			material.shader = TreeCanopyShader
			material.set_shader_parameter("albedo_tex", source_material.albedo_texture)
			material.set_shader_parameter("canopy_min_y", canopy_min_y)
			material.set_shader_parameter("canopy_max_y", canopy_max_y)
			material.set_shader_parameter("wind_strength", weather_wind_amount)
			material.set_shader_parameter("motion_time", portal_time)
			mesh_instance.set_surface_override_material(surface_index, material)
			tree_canopies.append(mesh_instance)
			tree_canopy_materials.append(material)


func _add_falling_leaves() -> void:
	falling_leaves = Node3D.new()
	falling_leaves.name = "FallingLeaves"
	falling_leaves.set_meta("seed", FALLING_LEAF_SEED)
	falling_leaves.set_meta("clusters", FALLING_LEAF_CLUSTERS)
	add_child(falling_leaves)
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array([
		Vector3(-0.14, 0.0, -0.01), Vector3(-0.025, 0.025, -0.075),
		Vector3(0.16, 0.0, 0.02), Vector3(-0.03, -0.018, 0.07),
	])
	arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array([Vector3.UP, Vector3.UP, Vector3.UP, Vector3.UP])
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array([0, 1, 2, 0, 2, 3])
	var leaf_mesh := ArrayMesh.new()
	leaf_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	for color in [Color("88758e"), Color("ad925e"), Color("70948c")]:
		var material := _material(color, 0.94)
		material.resource_name = "OtherworldLeaf"
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		material.emission_enabled = true
		material.emission = color.lerp(Color("6eaaa0"), 0.22)
		material.emission_energy_multiplier = 0.08
		falling_leaf_materials.append(material)
	var random := RandomNumberGenerator.new()
	random.seed = FALLING_LEAF_SEED
	for index in FALLING_LEAF_COUNT:
		var cluster: Vector2 = FALLING_LEAF_CLUSTERS[index % FALLING_LEAF_CLUSTERS.size()]
		var angle := random.randf_range(0.0, TAU)
		var radius := random.randf_range(1.8, 3.0)
		var leaf := MeshInstance3D.new()
		leaf.name = "OtherworldLeaf%02d" % index
		leaf.mesh = leaf_mesh
		leaf.material_override = falling_leaf_materials[index % falling_leaf_materials.size()]
		leaf.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		leaf.set_meta("params", {
			"home": cluster + Vector2(cos(angle), sin(angle)) * radius,
			"height": random.randf_range(4.2, 6.8),
			"speed": random.randf_range(0.075, 0.115),
			"offset": random.randf(),
			"phase": random.randf_range(0.0, TAU),
			"drift": random.randf_range(0.28, 0.62),
			"spin": random.randf_range(0.75, 1.35),
		})
		falling_leaves.add_child(leaf)
	_animate_falling_leaves()


func _add_ruin(position: Vector3) -> void:
	var center := position + Vector3(0.0, 0.0, -2.0)
	portal_center = center
	_add_ground_patch("PortalStoneBed", center, 4.7, Vector2(1.0, 0.82), Color("536b62"), 0.032, 0.28)
	_add_ground_patch("PortalArrivalWear", center + Vector3(0.0, 0.0, 1.75), 3.1, Vector2(0.86, 0.62), Color("776a54"), 0.042, 0.24)
	var platform := CSGCylinder3D.new()
	platform.name = "PortalPlatform"
	platform.radius = 3.7
	platform.height = 0.08
	platform.sides = 32
	platform.position = center + Vector3.UP * 0.02
	platform.material = stone_material
	platform.use_collision = true
	platform.visible = false
	add_child(platform)

	var ruin := Node3D.new()
	ruin.name = "PortalRuin"
	ruin.position = center
	add_child(ruin)
	var stones := [
		["Rock_Medium_1", Vector3(-2.1, 0.15, 0), 0.2, 0.9],
		["Rock_Medium_2", Vector3(-1.95, 1.35, 0), 1.1, 0.76],
		["Rock_Medium_1", Vector3(-1.5, 2.45, 0), 2.0, 0.65],
		["Rock_Medium_2", Vector3(-0.75, 3.15, 0), 0.5, 0.58],
		["Rock_Medium_1", Vector3(0, 3.45, 0), 1.6, 0.56],
		["Rock_Medium_2", Vector3(0.75, 3.15, 0), 2.7, 0.58],
		["Rock_Medium_1", Vector3(1.5, 2.45, 0), 0.9, 0.65],
		["Rock_Medium_2", Vector3(1.95, 1.35, 0), 2.2, 0.76],
		["Rock_Medium_1", Vector3(2.1, 0.15, 0), 2.9, 0.9],
	]
	for stone in stones:
		_add_model("res://assets/quaternius/nature/%s.gltf" % stone[0], stone[1], stone[2], stone[3], ruin)
	var edge_details := [
		["Rock_Medium_1", Vector3(-3.45, 0.02, -1.45), 0.6, 0.28],
		["Rock_Medium_2", Vector3(-3.25, 0.02, 1.4), 2.2, 0.2],
		["Rock_Medium_1", Vector3(3.35, 0.02, -1.15), 1.7, 0.25],
		["Rock_Medium_2", Vector3(3.15, 0.02, 1.55), 0.3, 0.18],
	]
	for detail in edge_details:
		_add_model("res://assets/quaternius/nature/%s.gltf" % detail[0], detail[1], detail[2], detail[3], ruin)
	var fern := _add_model("res://assets/quaternius/nature/Fern_1.gltf", Vector3(-3.6, 0.0, 0.45), 1.1, 0.2, ruin)
	fern.name = "PortalFern"
	wind_nodes.append(fern)
	var grass := _add_model("res://assets/quaternius/nature/Grass_Common_Tall.gltf", Vector3(3.55, 0.0, 0.8), 2.4, 0.48, ruin)
	grass.name = "PortalGrass"
	wind_nodes.append(grass)
	var left_collision := _add_box("LeftArchCollision", Vector3(1.25, 3.2, 1.5), Vector3(-2.0, 1.6, 0.0), stone_material, true, ruin)
	left_collision.visible = false
	var right_collision := _add_box("RightArchCollision", Vector3(1.25, 3.2, 1.5), Vector3(2.0, 1.6, 0.0), stone_material, true, ruin)
	right_collision.visible = false

	portal_material = _material(Color("67b8aa"), 0.25)
	portal_material.emission_enabled = true
	portal_material.emission = Color("6fe7ce")
	portal_material.emission_energy_multiplier = 0.8
	var ground_ring := Node3D.new()
	ground_ring.name = "PortalGroundRing"
	ground_ring.position = center + Vector3.UP * 0.075
	add_child(ground_ring)
	portal_ground_rune_material = portal_material.duplicate() as StandardMaterial3D
	portal_ground_rune_material.albedo_color = Color("4f8c82")
	portal_ground_rune_material.emission = Color("55b8a8")
	portal_ground_rune_material.emission_energy_multiplier = 0.48
	var rune_angles := [-2.85, -2.05, -1.3, -0.48, 0.48, 1.35, 2.35]
	for index in rune_angles.size():
		var angle: float = rune_angles[index]
		var rune := CSGBox3D.new()
		rune.name = "GroundRune%d" % index
		rune.size = Vector3(0.48 + float(index % 3) * 0.1, 0.02, 0.075)
		rune.position = Vector3(cos(angle) * 2.9, 0.0, sin(angle) * 2.9)
		rune.rotation.y = -angle - PI * 0.5
		rune.material = portal_ground_rune_material
		rune.use_collision = false
		ground_ring.add_child(rune)
	portal_ring = CSGTorus3D.new()
	portal_ring.name = "PortalRing"
	portal_ring.inner_radius = 1.45
	portal_ring.outer_radius = 1.8
	portal_ring.rotation_degrees.x = 90.0
	portal_ring.position = center + Vector3.UP * 1.85
	portal_ring.material = portal_material
	add_child(portal_ring)
	var portal_mesh := QuadMesh.new()
	portal_mesh.size = Vector2(2.8, 2.8)
	portal_surface_material = ShaderMaterial.new()
	portal_surface_material.shader = PortalSurfaceShader
	portal_surface_material.set_shader_parameter("reaction_strength", 0.0)
	portal_surface_material.set_shader_parameter("time_glow", 1.0)
	var portal := MeshInstance3D.new()
	portal.name = "PortalSurface"
	portal.mesh = portal_mesh
	portal.position = center + Vector3.UP * 1.85
	portal.material_override = portal_surface_material
	portal.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(portal)
	portal_light = OmniLight3D.new()
	portal_light.name = "PortalLight"
	portal_light.position = center + Vector3(0.0, 1.85, 0.7)
	portal_light.light_color = Color("72dac6")
	portal_light.light_energy = 0.7
	portal_light.omni_range = 8.0
	add_child(portal_light)
	portal_mote_material = _material(Color("9df4de"), 0.2)
	portal_mote_material.emission_enabled = true
	portal_mote_material.emission = Color("7ae8d0")
	portal_mote_material.emission_energy_multiplier = 1.8
	var mote_mesh := SphereMesh.new()
	mote_mesh.radius = 0.07
	mote_mesh.height = 0.14
	mote_mesh.radial_segments = 8
	mote_mesh.rings = 4
	for index in 8:
		var mote := MeshInstance3D.new()
		mote.name = "PortalMote%d" % index
		mote.mesh = mote_mesh
		mote.material_override = portal_mote_material
		add_child(mote)
		portal_motes.append(mote)


func _add_box(name: String, size: Vector3, position: Vector3, material: Material, collision: bool, parent: Node = self) -> CSGBox3D:
	var box := CSGBox3D.new()
	box.name = name
	box.size = size
	box.position = position
	box.material = material
	box.use_collision = collision
	parent.add_child(box)
	return box


func _add_road(
	name: String,
	centerline: PackedVector2Array,
	half_widths: PackedFloat32Array,
	elevation := 0.05,
	shoulder_width := 0.65,
	fade_ends := false
) -> MeshInstance3D:
	assert(centerline.size() >= 2 and centerline.size() == half_widths.size())
	var sampled := _sample_road(centerline, half_widths)
	meadow_roads.append({"name": name, "points": sampled[0], "widths": sampled[1]})
	var road := MeshInstance3D.new()
	road.name = name
	road.mesh = _road_mesh(sampled[0], sampled[1], elevation, false, shoulder_width, fade_ends, 0.07)
	road.material_override = path_material
	road.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(road)
	var shoulder_material := _material(Color("806f55"), 1.0)
	shoulder_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shoulder_material.vertex_color_use_as_albedo = true
	var shoulder := MeshInstance3D.new()
	shoulder.name = "Shoulder"
	shoulder.mesh = _road_mesh(sampled[0], sampled[1], elevation - 0.006, true, shoulder_width, fade_ends)
	shoulder.material_override = shoulder_material
	shoulder.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	road.add_child(shoulder)
	_add_road_edge_stones(road, name, sampled[0], sampled[1], shoulder_width)
	return road


func _build_weather() -> void:
	weather_schedule = _make_weather_schedule(weather_seed)
	weather_schedule_index = 0
	weather_segment_elapsed = 0.0
	rain_field = Node3D.new()
	rain_field.name = "LightRain"
	rain_field.set_meta("weather_seed", weather_seed)
	rain_field.set_meta("rain_seed", weather_seed + 701)
	rain_field.set_meta("schedule", weather_schedule.duplicate(true))
	add_child(rain_field)
	rain_material = StandardMaterial3D.new()
	rain_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rain_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rain_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	rain_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	var rain_mesh := QuadMesh.new()
	rain_mesh.size = Vector2(0.025, 0.55)
	var random := RandomNumberGenerator.new()
	random.seed = weather_seed + 701
	for index in 28:
		var streak := MeshInstance3D.new()
		streak.name = "RainStreak%02d" % index
		streak.mesh = rain_mesh
		streak.material_override = rain_material
		streak.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		rain_field.add_child(streak)
		rain_streaks.append(streak)
		rain_params.append({
			"x": random.randf_range(-9.0, 9.0),
			"z": random.randf_range(-7.0, 7.0),
			"start_y": random.randf_range(1.0, 10.0),
			"speed": random.randf_range(7.5, 11.0),
			"phase": random.randf_range(0.0, TAU),
		})
	_sample_weather()
	_animate_weather()


func _add_ecosystem() -> void:
	butterflies = Node3D.new()
	butterflies.name = "Butterflies"
	butterflies.set_meta("seed", BUTTERFLY_SEED)
	butterflies.set_meta("active_hours", Vector2(7.0, 19.0))
	add_child(butterflies)
	butterfly_material = StandardMaterial3D.new()
	butterfly_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	butterfly_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	butterfly_material.albedo_texture = _butterfly_texture()
	butterfly_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	butterfly_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	butterfly_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	var butterfly_mesh := QuadMesh.new()
	butterfly_mesh.size = Vector2(0.32, 0.22)
	var butterfly_meadows := PackedVector2Array([
		Vector2(-5.8, -15.2), Vector2(6.4, -13.6),
		Vector2(7.0, -1.8),
	])
	var butterfly_random := RandomNumberGenerator.new()
	butterfly_random.seed = BUTTERFLY_SEED
	for index in BUTTERFLY_COUNT:
		var home := butterfly_meadows[index % butterfly_meadows.size()] + Vector2(
			butterfly_random.randf_range(-0.55, 0.55),
			butterfly_random.randf_range(-0.55, 0.55)
		)
		var fly := MeshInstance3D.new()
		fly.name = "Butterfly%02d" % index
		fly.mesh = butterfly_mesh
		fly.material_override = butterfly_material
		fly.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		fly.set_meta("params", {
			"home": home,
			"radius_x": butterfly_random.randf_range(0.45, 0.80),
			"radius_z": butterfly_random.randf_range(0.35, 0.65),
			"speed": butterfly_random.randf_range(0.28, 0.44),
			"phase": butterfly_random.randf_range(0.0, TAU),
			"height": butterfly_random.randf_range(0.70, 1.15),
		})
		butterflies.add_child(fly)

	fireflies = Node3D.new()
	fireflies.name = "Fireflies"
	fireflies.set_meta("seed", FIREFLY_SEED)
	fireflies.set_meta("active_hours", Vector2(19.5, 5.5))
	add_child(fireflies)
	firefly_material = StandardMaterial3D.new()
	firefly_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	firefly_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	firefly_material.albedo_texture = _ecosystem_glow_texture()
	firefly_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	var firefly_mesh := QuadMesh.new()
	firefly_mesh.size = Vector2(0.12, 0.12)
	var forest_edges := PackedVector2Array([
		Vector2(-16.5, -2.0), Vector2(-17.5, 15.0),
		Vector2(16.5, 2.5), Vector2(17.5, 13.0),
	])
	var firefly_random := RandomNumberGenerator.new()
	firefly_random.seed = FIREFLY_SEED
	for index in FIREFLY_COUNT:
		var home := forest_edges[index % forest_edges.size()] + Vector2(
			firefly_random.randf_range(-0.35, 0.35),
			firefly_random.randf_range(-0.35, 0.35)
		)
		var fly := MeshInstance3D.new()
		fly.name = "Firefly%02d" % index
		fly.mesh = firefly_mesh
		fly.material_override = firefly_material
		fly.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		fly.set_meta("params", {
			"home": home,
			"radius_x": firefly_random.randf_range(0.35, 0.75),
			"radius_z": firefly_random.randf_range(0.30, 0.65),
			"speed": firefly_random.randf_range(0.16, 0.28),
			"phase": firefly_random.randf_range(0.0, TAU),
			"height": firefly_random.randf_range(0.30, 0.72),
		})
		fireflies.add_child(fly)
	_animate_ecosystem()


func _butterfly_texture() -> ImageTexture:
	const SIZE := 32
	var image := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	for y in SIZE:
		for x in SIZE:
			var point := Vector2(float(x) + 0.5, float(y) + 0.5)
			for side in [-1.0, 1.0]:
				var upper := Vector2((point.x - (16.0 + side * 6.2)) / 6.3, (point.y - 12.0) / 8.0)
				var lower := Vector2((point.x - (16.0 + side * 5.1)) / 5.2, (point.y - 19.0) / 5.5)
				if upper.length_squared() < 1.0:
					var upper_shade := 0.88 if upper.length_squared() > 0.74 else 1.0
					image.set_pixel(x, y, Color(0.94, 0.91, 0.81, 1.0) * upper_shade)
				elif point.y > 12.0 and lower.length_squared() < 1.0:
					var lower_shade := 0.80 if lower.length_squared() > 0.70 else 0.88
					image.set_pixel(x, y, Color(0.94, 0.91, 0.81, 1.0) * lower_shade)
			if absf(point.y - 16.0) < 1.1 and absf(point.x - 16.0) > 2.0 and image.get_pixel(x, y).a > 0.0:
				image.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
			if absf(point.x - 16.0) < 1.8 and point.y > 7.0 and point.y < 26.0:
				image.set_pixel(x, y, Color(0.18, 0.16, 0.13, 1.0))
	return ImageTexture.create_from_image(image)


func _ecosystem_glow_texture() -> ImageTexture:
	const SIZE := 32
	var image := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	for y in SIZE:
		for x in SIZE:
			var offset := (Vector2(float(x), float(y)) + Vector2.ONE * 0.5 - Vector2.ONE * 16.0) / 15.0
			var alpha := pow(clampf(1.0 - offset.length(), 0.0, 1.0), 2.4)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	image.generate_mipmaps()
	return ImageTexture.create_from_image(image)


func _add_meadow_grass() -> void:
	var source := MeadowGrassScene.instantiate()
	var mesh_nodes := source.find_children("*", "MeshInstance3D", true, false)
	assert(mesh_nodes.size() == 1)
	var source_mesh := (mesh_nodes[0] as MeshInstance3D).mesh
	var source_material := source_mesh.surface_get_material(0) as StandardMaterial3D
	assert(source_material != null and source_material.albedo_texture != null)

	var noise := FastNoiseLite.new()
	noise.seed = 20260901
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.075
	var random := RandomNumberGenerator.new()
	random.seed = 20260901
	var transforms: Array[Transform3D] = []
	var positions := PackedVector3Array()
	var brightness_values := PackedFloat32Array()
	for cell_z in range(-23, 29):
		for cell_x in range(-22, 22):
			var cell_center := Vector2(float(cell_x) + 0.5, float(cell_z) + 0.5)
			var density := _meadow_density(cell_center, noise)
			var instance_total := floori(density)
			if random.randf() < density - float(instance_total):
				instance_total += 1
			for instance_index in instance_total:
				var point := Vector2(
					float(cell_x) + random.randf(),
					float(cell_z) + random.randf()
				)
				if _is_meadow_excluded(point):
					continue
				var scale_value := random.randf_range(0.20, 0.34)
				var basis := Basis(Vector3.UP, random.randf_range(0.0, TAU)).scaled(Vector3.ONE * scale_value)
				var origin := Vector3(point.x, 0.01, point.y)
				transforms.append(Transform3D(basis, origin))
				positions.append(origin)
				var brightness := random.randf_range(0.94, 1.06)
				brightness_values.append(brightness)

	var multimesh := MultiMesh.new()
	assert(not transforms.is_empty())
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_custom_data = true
	multimesh.mesh = source_mesh
	multimesh.instance_count = transforms.size()
	for index in transforms.size():
		multimesh.set_instance_transform(index, transforms[index])
		multimesh.set_instance_custom_data(index, Color(brightness_values[index], 0.0, 0.0, 1.0))

	var material := ShaderMaterial.new()
	material.shader = MeadowGrassShader
	material.set_shader_parameter("albedo_tex", source_material.albedo_texture)
	meadow_grass = MultiMeshInstance3D.new()
	meadow_grass.name = "MeadowGrass"
	meadow_grass.multimesh = multimesh
	meadow_grass.material_override = material
	meadow_grass.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	meadow_grass.custom_aabb = AABB(Vector3(-22.5, -0.1, -23.5), Vector3(45.0, 1.3, 53.0))
	meadow_grass.set_meta("seed", 20260901)
	meadow_grass.set_meta("positions", positions)
	meadow_grass.set_meta("brightness_values", brightness_values)
	add_child(meadow_grass)


func _meadow_density(point: Vector2, noise: FastNoiseLite) -> float:
	if _is_meadow_excluded(point):
		return 0.0
	var cluster := clampf((noise.get_noise_2d(point.x, point.y) + 1.0) * 0.5, 0.0, 1.0)
	var cluster_gate := smoothstep(0.48, 0.68, cluster)
	var density := 0.10 + cluster_gate * 1.6
	if point.x > -20.0 and point.x < 18.0 and point.y > -19.0 and point.y < 9.5:
		density = maxf(density, 0.18 + pow(cluster_gate, 1.35) * 7.0)
	var road_edge := _meadow_road_edge_distance(point, "VillagePath")
	if road_edge < 2.2:
		var road_cluster := clampf((noise.get_noise_2d(point.x * 0.58 + 31.0, point.y * 0.58 - 19.0) + 1.0) * 0.5, 0.0, 1.0)
		var roadside_gate := smoothstep(0.50, 0.66, road_cluster)
		var roadside_profile := lerpf(1.0, 0.68, smoothstep(0.24, 2.2, road_edge))
		var roadside_density := roadside_gate * lerpf(6.0, 8.0, road_cluster) * roadside_profile
		density = maxf(density, roadside_density)
	var portal_distance := point.distance_to(Vector2(portal_center.x, portal_center.z))
	if portal_distance < 8.5:
		density *= smoothstep(4.8, 8.5, portal_distance)
	if point.y < -18.0:
		density *= 0.42
	return clampf(density, 0.0, 9.0)


func _is_meadow_excluded(point: Vector2) -> bool:
	if _meadow_road_edge_distance(point) <= 0.24:
		return true
	if point.distance_to(Vector2(portal_center.x, portal_center.z)) < 4.8:
		return true
	var pond_offset := point - Vector2(-7.8, 12.0)
	if pow(pond_offset.x / 4.55, 2.0) + pow(pond_offset.y / 3.15, 2.0) < 1.0:
		return true
	if absf(point.x - HERB_PLOT_POSITION.x) < 2.7 and absf(point.y - HERB_PLOT_POSITION.z) < 3.6:
		return true
	if point.distance_to(Vector2(4.3, -5.5)) < 3.25:
		return true
	if absf(point.x + 5.8) < 2.2 and absf(point.y + 2.7) < 1.8:
		return true
	# Preserve visibly trampled space around the weaver and gatekeeper routines.
	if absf(point.x + 4.9) < 2.1 and absf(point.y - 5.9) < 2.2:
		return true
	if absf(point.x - 3.0) < 1.4 and absf(point.y + 15.2) < 1.7:
		return true
	for house_center in [Vector2(-9.0, -10.0), Vector2(9.0, -8.0), Vector2(-10.0, 5.0)]:
		if absf(point.x - house_center.x) < 3.45 and absf(point.y - house_center.y) < 3.45:
			return true
	if point.y < -22.0 and absf(point.x) < 7.5:
		return true
	return false


func _meadow_road_edge_distance(point: Vector2, only_name := "") -> float:
	var closest := INF
	for road in meadow_roads:
		if not only_name.is_empty() and road["name"] != only_name:
			continue
		var points: PackedVector2Array = road["points"]
		var widths: PackedFloat32Array = road["widths"]
		for index in points.size() - 1:
			var start := points[index]
			var segment := points[index + 1] - start
			var length_squared := segment.length_squared()
			var t := 0.0 if is_zero_approx(length_squared) else clampf((point - start).dot(segment) / length_squared, 0.0, 1.0)
			var width := lerpf(widths[index], widths[index + 1], t)
			closest = minf(closest, point.distance_to(start + segment * t) - width)
	return closest


func _sample_road(centerline: PackedVector2Array, half_widths: PackedFloat32Array) -> Array:
	var points := PackedVector2Array()
	var widths := PackedFloat32Array()
	for segment_index in centerline.size() - 1:
		var p0 := centerline[maxi(segment_index - 1, 0)]
		var p1 := centerline[segment_index]
		var p2 := centerline[segment_index + 1]
		var p3 := centerline[mini(segment_index + 2, centerline.size() - 1)]
		for step in 5:
			var t := float(step) / 5.0
			var t2 := t * t
			var t3 := t2 * t
			points.append(0.5 * ((2.0 * p1) + (-p0 + p2) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 + (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3))
			widths.append(lerpf(half_widths[segment_index], half_widths[segment_index + 1], t))
	points.append(centerline[-1])
	widths.append(half_widths[-1])
	return [points, widths]


func _road_mesh(
	points: PackedVector2Array,
	half_widths: PackedFloat32Array,
	elevation: float,
	feathered: bool,
	feather_width := 0.65,
	fade_ends := false,
	center_wear := 0.0,
	broken_wear := false,
	wear_offset := 0.0
) -> ArrayMesh:
	var has_center_wear := not feathered and center_wear > 0.0
	var lane_count := 4 if feathered else (3 if has_center_wear else 2)
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var colors := PackedColorArray()
	var indices := PackedInt32Array()
	var total_distance := 0.0
	for distance_index in points.size() - 1:
		total_distance += points[distance_index].distance_to(points[distance_index + 1])
	var distance := 0.0
	for point_index in points.size():
		if point_index > 0:
			distance += points[point_index].distance_to(points[point_index - 1])
		var previous := points[maxi(point_index - 1, 0)]
		var following := points[mini(point_index + 1, points.size() - 1)]
		var tangent := (following - previous).normalized()
		var normal := Vector2(-tangent.y, tangent.x)
		var width := half_widths[point_index]
		var offsets := (
			[-width - feather_width, -width, width, width + feather_width]
			if feathered
			else ([-width, 0.0, width] if has_center_wear else [-width, width])
		)
		var end_fade := 1.0
		if fade_ends:
			var edge_distance := mini(point_index, points.size() - 1 - point_index)
			end_fade = smoothstep(0.0, 5.0, float(edge_distance))
		for lane_index in lane_count:
			var offset: float = offsets[lane_index]
			var vertex := points[point_index] + normal * offset
			vertices.append(Vector3(vertex.x, elevation, vertex.y))
			normals.append(Vector3.UP)
			var u := float(lane_index) / float(lane_count - 1)
			uvs.append(Vector2(u, distance / 3.0))
			var alpha := 0.0 if feathered and (lane_index == 0 or lane_index == lane_count - 1) else 0.48
			var shade := 1.0 - center_wear * (1.0 - absf(2.0 * u - 1.0)) if has_center_wear else 1.0
			var vertex_alpha := alpha * end_fade if feathered else end_fade
			if broken_wear:
				var wear_progress := distance / maxf(total_distance, 0.001)
				for gap in [Vector2(0.24 + wear_offset, 0.055), Vector2(0.53 + wear_offset, 0.075), Vector2(0.79 + wear_offset, 0.05)]:
					vertex_alpha *= smoothstep(0.0, 1.0, absf(wear_progress - gap.x) / gap.y)
			colors.append(Color(shade, shade, shade, vertex_alpha))
	for point_index in points.size() - 1:
		for lane_index in lane_count - 1:
			var current := point_index * lane_count + lane_index
			var next := current + lane_count
			indices.append_array(PackedInt32Array([current, next, current + 1, current + 1, next, next + 1]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


func _add_road_edge_stones(
	road: MeshInstance3D,
	road_name: String,
	points: PackedVector2Array,
	half_widths: PackedFloat32Array,
	shoulder_width: float
) -> void:
	var group := Node3D.new()
	group.name = "EdgeStones"
	var seed_value := 490031 + absi(road_name.hash() % 100000)
	group.set_meta("seed", seed_value)
	road.add_child(group)
	var random := RandomNumberGenerator.new()
	random.seed = seed_value
	var point_index := random.randi_range(3, mini(6, points.size() - 4))
	var stone_index := 0
	while point_index < points.size() - 3:
		var previous := points[point_index - 1]
		var following := points[point_index + 1]
		var tangent := (following - previous).normalized()
		var normal := Vector2(-tangent.y, tangent.x)
		var side := -1.0 if random.randf() < 0.5 else 1.0
		var offset := half_widths[point_index] + random.randf_range(0.10, maxf(0.16, shoulder_width * 0.78))
		var point := points[point_index] + normal * offset * side
		var asset_name := "Rock_Medium_1" if random.randf() < 0.55 else "Rock_Medium_2"
		var asset_path := "res://assets/quaternius/nature/%s.gltf" % asset_name
		var stone := _add_model(
			asset_path,
			Vector3(point.x, 0.0, point.y),
			random.randf_range(0.0, TAU),
			random.randf_range(0.055, 0.095),
			group
		)
		stone.name = "EdgeStone%02d" % stone_index
		stone.set_meta("source_asset", asset_path)
		stone_index += 1
		point_index += random.randi_range(7, 11)


func _add_cart_tracks(name_prefix: String, centerline: PackedVector2Array, material: Material) -> void:
	for side in [-1.0, 1.0]:
		var points := PackedVector2Array()
		var widths := PackedFloat32Array()
		for center in centerline:
			points.append(Vector2(center.x + side * 0.92, center.y))
			widths.append(0.14)
		var suffix := "Left" if side < 0.0 else "Right"
		var sampled := _sample_road(points, widths)
		var track := MeshInstance3D.new()
		track.name = name_prefix + suffix
		var wear_offset := -0.025 if side < 0.0 else 0.035
		track.mesh = _road_mesh(sampled[0], sampled[1], 0.12, false, 0.65, true, 0.0, true, wear_offset)
		track.material_override = material
		track.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(track)


func _add_ground_patch(
	name: String,
	position: Vector3,
	radius: float,
	shape: Vector2,
	color: Color,
	elevation := 0.025,
	opacity := 0.24
) -> MeshInstance3D:
	var gradient := Gradient.new()
	var center := color
	center.a = opacity
	var edge := color
	edge.a = 0.0
	gradient.offsets = PackedFloat32Array([0.0, 1.0])
	gradient.colors = PackedColorArray([center, edge])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 128
	texture.height = 128
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	var patch_material := StandardMaterial3D.new()
	patch_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	patch_material.albedo_texture = texture
	patch_material.roughness = 1.0
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(radius * 2.0 * shape.x, radius * 2.0 * shape.y)
	var patch := MeshInstance3D.new()
	patch.name = name
	patch.mesh = mesh
	patch.material_override = patch_material
	patch.position = position + Vector3.UP * elevation
	add_child(patch)
	return patch


func _add_model(path: String, position: Vector3, rotation_y: float, scale: float, parent: Node = self) -> Node3D:
	var scene := load(path) as PackedScene
	if scene == null:
		push_error("Cannot load model: %s" % path)
		return null
	var model := scene.instantiate()
	model.position = position
	model.rotation.y = rotation_y
	model.scale = Vector3.ONE * scale
	parent.add_child(model)
	return model


func _material(color: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material


func _ground_texture() -> ImageTexture:
	const SIZE := 128
	var image := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	var random := RandomNumberGenerator.new()
	random.seed = 9001
	var patches: Array = []
	for patch_index in 14:
		patches.append({
			"x": random.randf_range(0.0, float(SIZE)),
			"y": random.randf_range(0.0, float(SIZE)),
			"radius": random.randf_range(12.0, 36.0),
			"brightness": random.randf_range(0.02, 0.05) * (1.0 if patch_index % 2 == 0 else -1.0),
			"warmth": random.randf_range(0.02, 0.03) * (1.0 if patch_index % 4 < 2 else -1.0),
		})

	for y in SIZE:
		for x in SIZE:
			var value := 0.94
			var warmth := 0.0
			for patch in patches:
				var dx := absf(float(x) - (patch["x"] as float))
				dx = minf(dx, float(SIZE) - dx)
				var dy := absf(float(y) - (patch["y"] as float))
				dy = minf(dy, float(SIZE) - dy)
				var distance := sqrt(dx * dx + dy * dy)
				var radius := patch["radius"] as float
				if distance >= radius:
					continue
				var falloff := 1.0 - distance / radius
				falloff = falloff * falloff * (3.0 - 2.0 * falloff)
				value += falloff * (patch["brightness"] as float)
				warmth += falloff * (patch["warmth"] as float)
			value = clampf(value, 0.88, 0.99)
			warmth = clampf(warmth, -0.03, 0.03)
			image.set_pixel(x, y, Color(
				minf(value * (1.0 + warmth), 0.995),
				minf(value * (1.0 + warmth * 0.12), 0.995),
				minf(value * (1.0 - warmth), 0.995),
				1.0
			))

	var plot_stroke := func(px: int, py: int, shade: float) -> void:
		var x := posmod(px, SIZE)
		var y := posmod(py, SIZE)
		var base := image.get_pixel(x, y)
		image.set_pixel(x, y, Color(
			clampf(base.r * shade, 0.82, 0.995),
			clampf(base.g * shade, 0.82, 0.995),
			clampf(base.b * shade, 0.82, 0.995),
			1.0
		))
	for stroke_index in 430:
		var x := random.randi_range(0, SIZE - 1)
		var y := random.randi_range(0, SIZE - 1)
		var height := random.randi_range(2, 4)
		var lean := random.randi_range(-1, 1)
		var shade := random.randf_range(0.92, 0.97) if random.randf() < 0.72 else random.randf_range(1.01, 1.04)
		for step in height:
			plot_stroke.call(x + lean * step, y - step, shade)

	for edge in SIZE:
		image.set_pixel(SIZE - 1, edge, image.get_pixel(0, edge))
		image.set_pixel(edge, SIZE - 1, image.get_pixel(edge, 0))
	image.generate_mipmaps()
	return ImageTexture.create_from_image(image)


func _road_texture() -> ImageTexture:
	const SIZE := 128
	var image := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	var random := RandomNumberGenerator.new()
	random.seed = 4903
	var patches: Array = []
	for patch_index in 16:
		patches.append({
			"x": random.randf_range(0.0, float(SIZE)),
			"y": random.randf_range(0.0, float(SIZE)),
			"radius_x": random.randf_range(12.0, 30.0),
			"radius_y": random.randf_range(8.0, 22.0),
			"brightness": random.randf_range(0.022, 0.052) * (-1.0 if random.randf() < 0.62 else 1.0),
			"warmth": random.randf_range(-1.0, 1.0),
		})
	for y in SIZE:
		for x in SIZE:
			var value := 1.0
			var warmth := 0.0
			for patch in patches:
				var dx := absf(float(x) - (patch["x"] as float))
				dx = minf(dx, float(SIZE) - dx) / (patch["radius_x"] as float)
				var dy := absf(float(y) - (patch["y"] as float))
				dy = minf(dy, float(SIZE) - dy) / (patch["radius_y"] as float)
				var distance := sqrt(dx * dx + dy * dy)
				if distance >= 1.0:
					continue
				var falloff := 1.0 - distance
				falloff = falloff * falloff * (3.0 - 2.0 * falloff)
				value += falloff * (patch["brightness"] as float)
				warmth += falloff * (patch["warmth"] as float)
			value = clampf(value, 0.88, 1.06)
			warmth = clampf(warmth, -1.0, 1.0)
			image.set_pixel(x, y, Color(
				value * (1.0 + warmth * 0.014),
				value * (1.0 + warmth * 0.002),
				value * (1.0 - warmth * 0.012),
				1.0
			))

	for mark_index in 96:
		var mark_x := random.randi_range(0, SIZE - 1)
		var mark_y := random.randi_range(0, SIZE - 1)
		var mark_length := random.randi_range(2, 5)
		var lean := random.randi_range(-1, 1)
		var shade := random.randf_range(0.80, 0.93) if random.randf() < 0.82 else random.randf_range(1.02, 1.055)
		for step in mark_length:
			var px := posmod(mark_x + roundi(float(lean * step) / float(maxi(mark_length - 1, 1))), SIZE)
			var py := posmod(mark_y + step, SIZE)
			var base := image.get_pixel(px, py)
			image.set_pixel(px, py, Color(base.r * shade, base.g * shade, base.b * shade, 1.0))

	for pebble_index in 34:
		var pebble_x := random.randi_range(1, SIZE - 2)
		var pebble_y := random.randi_range(1, SIZE - 2)
		var base := image.get_pixel(pebble_x, pebble_y)
		var pebble_shade := random.randf_range(0.68, 0.82)
		image.set_pixel(pebble_x, pebble_y, Color(base.r * pebble_shade, base.g * pebble_shade, base.b * pebble_shade, 1.0))
		if pebble_index % 3 == 0:
			var highlight := image.get_pixel(pebble_x + 1, pebble_y - 1)
			image.set_pixel(pebble_x + 1, pebble_y - 1, Color(highlight.r * 1.025, highlight.g * 1.025, highlight.b * 1.025, 1.0))

	for edge in SIZE:
		image.set_pixel(SIZE - 1, edge, image.get_pixel(0, edge))
		image.set_pixel(edge, SIZE - 1, image.get_pixel(edge, 0))
	image.generate_mipmaps()
	return ImageTexture.create_from_image(image)
