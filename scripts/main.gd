extends Node3D

const PlayerScript = preload("res://scripts/player.gd")
const MistValleyAmbience = preload("res://assets/audio/mist_valley_ambience.ogg")
const PortalHum = preload("res://assets/audio/portal_hum.ogg")
const PortalReact = preload("res://assets/audio/portal_react.ogg")
const HearthFire = preload("res://assets/audio/hearth_fire.ogg")
const RangerCharacter = preload("res://assets/quaternius/characters/Ranger.gltf")
const ClericCharacter = preload("res://assets/quaternius/characters/Cleric.gltf")
const WarriorCharacter = preload("res://assets/quaternius/characters/Warrior.gltf")
const MonkCharacter = preload("res://assets/quaternius/characters/Monk.gltf")
const HERB_PLOT_POSITION := Vector3(-4.0, 0.0, -10.8)

var ground_material := _material(Color("6f8f65"), 0.95)
var path_material := _material(Color("9a8466"), 1.0)
var stone_material := _material(Color("66706c"), 0.9)
var plaster_material := _material(Color("c6b99a"), 0.95)
var portal_material: StandardMaterial3D
var portal_ring: CSGTorus3D
var portal_light: OmniLight3D
var portal_hum: AudioStreamPlayer3D
var portal_react_player: AudioStreamPlayer3D
var portal_reaction_time := 0.0
var portal_time := 0.0
var portal_center := Vector3.ZERO
var portal_motes: Array[MeshInstance3D] = []
var wind_nodes: Array[Node3D] = []
var portal_prompt: Label
var portal_lore: Label
var portal_nearby := false
var portal_lore_tween: Tween
var smoke_puffs: Array[MeshInstance3D] = []
var smoke_origins: Array[Vector3] = []
var smoke_mesh: QuadMesh
var smoke_material: StandardMaterial3D
var house_count := 0
var house_fade_materials: Array[StandardMaterial3D] = []
var house_fade_centers: Array[Vector3] = []
var hearth_flames: Array[MeshInstance3D] = []
var hearth_flame_origins: Array[Vector3] = []
var hearth_light: OmniLight3D
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
var nearby_villager: CharacterBody3D
var mistcap_material: StandardMaterial3D
var mistcap_caps: Array[MeshInstance3D] = []
var mistcap_lights: Array[OmniLight3D] = []
var fog_banks: Array[MeshInstance3D] = []
var fog_bank_origins: Array[Vector3] = []


func _ready() -> void:
	_build_world()
	_build_player()
	_build_villagers()
	_build_opening()
	_build_portal_interaction()
	_build_audio()


func _process(delta: float) -> void:
	if portal_ring == null:
		return
	portal_time += delta
	portal_reaction_time = maxf(portal_reaction_time - delta * 1.5, 0.0)
	var pulse: float = sin(portal_time * 2.2)
	var reaction := portal_reaction_time
	var proximity := _portal_proximity()
	_update_villager_interaction()
	portal_ring.scale = Vector3.ONE * (1.0 + pulse * 0.035 + reaction * 0.12)
	portal_material.emission_energy_multiplier = 0.75 + pulse * 0.12 + proximity * 0.3 + reaction * 0.65
	portal_light.light_energy = 0.65 + pulse * 0.15 + proximity * 0.45 + reaction * 0.75
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
		plant.rotation.z = sin(portal_time * 0.85 + float(index) * 0.73) * 0.025
		plant.rotation.x = cos(portal_time * 0.7 + float(index) * 0.51) * 0.012
	for index in smoke_puffs.size():
		var phase := fmod(portal_time * 0.12 + float(index % 3) * 0.34 + float(index / 3) * 0.13, 1.0)
		var puff := smoke_puffs[index]
		puff.position = smoke_origins[index] + Vector3(sin(portal_time * 0.45 + index) * 0.22, phase * 2.4, cos(portal_time * 0.38 + index) * 0.12)
		puff.scale = Vector3.ONE * (0.45 + phase * 0.75)
		puff.transparency = 0.05 + phase * 0.85
	for index in hearth_flames.size():
		var flicker := sin(portal_time * 5.2 + float(index) * 1.8)
		var flame := hearth_flames[index]
		flame.position = hearth_flame_origins[index] + Vector3(flicker * 0.05, flicker * 0.07, cos(portal_time * 4.4 + index) * 0.04)
		flame.scale = Vector3(0.42 - flicker * 0.04, 0.78 + flicker * 0.1, 0.42 - flicker * 0.04)
	if hearth_light != null:
		hearth_light.light_energy = 0.8 + sin(portal_time * 5.2) * 0.12
	for index in pond_ripples.size():
		var phase := fmod(portal_time * 0.2 + float(index) * 0.5, 1.0)
		var ripple := pond_ripples[index]
		ripple.scale = Vector3(0.45 + phase * 1.65, 1.0, 0.32 + phase * 1.1)
		ripple.transparency = 0.35 + phase * 0.63
	if mistcap_material != null:
		mistcap_material.emission_energy_multiplier = 0.42 + sin(portal_time * 1.35) * 0.1
	for index in mistcap_lights.size():
		mistcap_lights[index].light_energy = 0.12 + sin(portal_time * 1.35 + float(index) * 0.9) * 0.035
	for index in fog_banks.size():
		var fog_phase := portal_time * 0.16 + float(index) * 1.15
		fog_banks[index].position = fog_bank_origins[index] + Vector3(sin(fog_phase) * 1.1, cos(fog_phase * 0.7) * 0.08, cos(fog_phase * 0.8) * 0.35)
		fog_banks[index].transparency = 0.28 + (sin(fog_phase * 0.9) + 1.0) * 0.1
	var player := get_node_or_null("Player") as CharacterBody3D
	for index in house_fade_materials.size():
		var target_alpha := 1.0
		if player != null:
			var house_distance := Vector2(player.position.x, player.position.z).distance_to(Vector2(house_fade_centers[index].x, house_fade_centers[index].z))
			target_alpha = 0.08 if house_distance < 6.0 else 1.0
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
		elif Vector2(villagers[index].velocity.x, villagers[index].velocity.z).length_squared() > 0.001:
			target_yaw = atan2(villagers[index].velocity.x, villagers[index].velocity.z)
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
		elif villager_patrol_pauses[index] > 0.0:
			villager_patrol_pauses[index] = maxf(villager_patrol_pauses[index] - delta, 0.0)
			villager.velocity.x = 0.0
			villager.velocity.z = 0.0
			var pause_animation := "PickUp" if index == 0 and villager_patrol_directions[index] < 0.0 else "Idle"
			if animation_player.assigned_animation != pause_animation:
				animation_player.play(pause_animation, 0.2)
		else:
			var patrol_offset := (villager.position - villager_patrol_origins[index]).dot(villager_patrol_axes[index])
			if patrol_offset * villager_patrol_directions[index] >= 1.2:
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


func _build_world() -> void:
	ground_material.albedo_texture = _surface_texture(true)
	ground_material.uv1_scale = Vector3.ONE * 7.0
	ground_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	path_material.albedo_texture = _surface_texture(false)
	path_material.uv1_scale = Vector3.ONE * 4.0
	path_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC

	var environment := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("839da3")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("bfcbb8")
	settings.ambient_light_energy = 0.42
	settings.fog_enabled = true
	settings.fog_light_color = Color("a9bcba")
	settings.fog_density = 0.006
	settings.fog_height = 2.0
	settings.fog_height_density = 0.08
	environment.environment = settings
	add_child(environment)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52.0, -28.0, 0.0)
	sun.light_color = Color("fff0ce")
	sun.light_energy = 0.72
	sun.shadow_enabled = true
	add_child(sun)

	_add_box("ValleyFloor", Vector3(70.0, 1.0, 70.0), Vector3(0.0, -0.5, 0.0), ground_material, true)
	_add_ground_patch("GrassShadeWest", Vector3(-15, 0, -8), 8.5, Vector2(1.25, 0.8), Color("66835f"))
	_add_ground_patch("GrassLightEast", Vector3(15, 0, -7), 8.0, Vector2(1.15, 0.75), Color("78956d"))
	_add_ground_patch("GrassShadeSouth", Vector3(-13, 0, 17), 7.5, Vector2(1.35, 0.75), Color("66835f"))
	_add_ground_patch("GrassLightSouth", Vector3(14, 0, 19), 7.0, Vector2(1.25, 0.8), Color("78956d"))
	_add_ground_patch("GrassShadeNorth", Vector3(0, 0, -23), 9.0, Vector2(1.45, 0.65), Color("66835f"))
	_add_box("NorthCliff", Vector3(60.0, 8.0, 5.0), Vector3(0.0, 3.0, -27.0), stone_material, true)
	_add_box("SouthCliff", Vector3(60.0, 7.0, 5.0), Vector3(0.0, 2.5, 32.0), stone_material, true)
	_add_box("WestCliff", Vector3(5.0, 7.0, 59.0), Vector3(-27.0, 2.5, 2.5), stone_material, true)
	_add_box("EastCliff", Vector3(5.0, 7.0, 59.0), Vector3(27.0, 2.5, 2.5), stone_material, true)
	_add_boundary_scenery()
	_add_fog_banks()
	_add_path("VillagePath", PackedVector2Array([
		Vector2(-2.6, -28), Vector2(2.7, -28), Vector2(2.9, -21), Vector2(2.5, -14),
		Vector2(3.2, -7), Vector2(2.7, 0), Vector2(3.1, 7), Vector2(2.5, 14),
		Vector2(2.9, 21), Vector2(2.4, 31), Vector2(-2.5, 31), Vector2(-2.8, 23),
		Vector2(-2.4, 15), Vector2(-3.0, 8), Vector2(-2.6, 1), Vector2(-3.1, -6),
		Vector2(-2.5, -14), Vector2(-2.9, -21),
	]))
	_add_path("VillageSquare", PackedVector2Array([
		Vector2(-9, -15), Vector2(0, -16), Vector2(9, -14), Vector2(10, -9),
		Vector2(8.5, -2.5), Vector2(3, 0), Vector2(-3, 0.5), Vector2(-9, -2),
		Vector2(-10, -8),
	]), 0.07)
	_add_path("PortalPath", PackedVector2Array([
		Vector2(2, 9.2), Vector2(6, 9.5), Vector2(10, 8.8), Vector2(13, 9.8),
		Vector2(13, 12.5), Vector2(10, 13.1), Vector2(6, 12.4), Vector2(2, 12.8),
	]), 0.06)
	var track_material := _material(Color("78644a"), 1.0)
	_add_cart_tracks("NorthCartTrack", PackedVector2Array([
		Vector2(0.0, -27.5), Vector2(0.1, -23.0), Vector2(0.2, -19.0), Vector2(0.0, -14.5),
	]), track_material)
	_add_cart_tracks("SouthCartTrack", PackedVector2Array([
		Vector2(0.0, 0.5), Vector2(0.15, 6.0), Vector2(0.0, 12.0),
		Vector2(0.2, 18.0), Vector2(-0.1, 24.0), Vector2(0.0, 30.5),
	]), track_material)
	var village_wear := [
		["VillageWearHearth", Vector3(4.8, 0.0, -3.8), 2.8, Vector2(1.1, 0.72), Color("6f5d48")],
		["VillageWearHerbs", Vector3(-4.3, 0.0, -10.3), 2.1, Vector2(1.15, 0.68), Color("75624b")],
		["VillageWearWagon", Vector3(-5.3, 0.0, -2.0), 2.4, Vector2(1.2, 0.7), Color("705e49")],
		["VillageWearEastDoor", Vector3(6.3, 0.0, -7.2), 2.0, Vector2(0.9, 0.68), Color("75624b")],
	]
	for wear in village_wear:
		_add_ground_patch(wear[0], wear[1], wear[2], wear[3], wear[4], 0.12, 0.34)

	_add_house(Vector3(-9.0, 0.0, -10.0), 0.15)
	_add_house(Vector3(9.0, 0.0, -8.0), -0.2)
	_add_house(Vector3(-10.0, 0.0, 5.0), 0.05)
	_add_village_hearth()
	_add_village_props()
	_add_herb_plot()
	_add_ruin(Vector3(10.0, 0.0, 13.0))
	_add_pond(Vector3(-10.0, 0.0, 12.0))
	_add_mistcaps()

	var trees := [
		["CommonTree_1", Vector3(-17, 0, -17), 0.2, 1.05],
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
	player.position = Vector3(0.0, 1.0, 14.0)
	player.set_script(PlayerScript)

	var collider := CollisionShape3D.new()
	collider.name = "CollisionShape3D"
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.8
	collider.shape = capsule
	player.add_child(collider)

	var visual := Node3D.new()
	visual.name = "Visual"
	player.add_child(visual)
	_attach_character_model(visual, RangerCharacter, 0.64, -0.95)

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
	var listener := AudioListener3D.new()
	listener.name = "AudioListener3D"
	player.add_child(listener)
	listener.make_current()
	add_child(player)
	_build_arrival(player, camera)


func _build_villagers() -> void:
	_add_villager("HerbalistMira", Vector3(-4.8, 0.0, -9.3), 2.55, ClericCharacter, Vector3.RIGHT)
	_add_villager("GatekeeperToren", Vector3(5.0, 0.0, -7.0), -2.35, WarriorCharacter, Vector3.BACK)
	_add_villager("WeaverNia", Vector3(-5.5, 0.0, 6.5), 1.15, MonkCharacter, Vector3.BACK)


func _add_villager(npc_name: String, npc_position: Vector3, facing: float, character_scene: PackedScene, patrol_axis: Vector3) -> void:
	var npc := CharacterBody3D.new()
	npc.name = npc_name
	npc.position = npc_position
	add_child(npc)
	villagers.append(npc)
	villager_patrol_origins.append(npc_position)
	villager_patrol_axes.append(patrol_axis)
	villager_patrol_directions.append(1.0)
	villager_patrol_pauses.append(0.0)

	var collider := CollisionShape3D.new()
	collider.name = "CollisionShape3D"
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.36
	capsule.height = 1.65
	collider.shape = capsule
	collider.position.y = 0.83
	npc.add_child(collider)

	var visual := Node3D.new()
	visual.name = "Visual"
	visual.rotation.y = facing
	npc.add_child(visual)
	villager_visuals.append(visual)
	villager_rotations.append(facing)
	var animation_player := _attach_character_model(visual, character_scene, 0.62, 0.0)
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
	label.position.y = 2.25
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.fixed_size = false
	label.pixel_size = 0.012
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
	var shell_material := plaster_material.duplicate() as StandardMaterial3D
	shell_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_add_box("HouseCollision", Vector3(6.0, 3.1, 6.0), Vector3(0.0, 1.55, 0.0), shell_material, true, house)
	house_fade_materials.append(shell_material)
	house_fade_centers.append(position)
	var roof := _add_model("res://assets/quaternius/village/Roof_RoundTiles_6x8.gltf", Vector3(0.0, 3.05, 0.0), 0.0, 0.82, house)
	roof.name = "Roof"
	_add_model("res://assets/quaternius/village/Wall_Plaster_Straight.gltf", Vector3(-2.0, 0.0, 3.03), 0.0, 1.0, house)
	_add_model("res://assets/quaternius/village/Wall_Plaster_Door_Round.gltf", Vector3(0.0, 0.0, 3.03), 0.0, 1.0, house)
	_add_model("res://assets/quaternius/village/Wall_Plaster_Window_Wide_Round.gltf", Vector3(2.0, 0.0, 3.03), 0.0, 1.0, house)
	_add_model("res://assets/quaternius/village/Door_1_Round.gltf", Vector3(0.0, 0.0, 3.16), 0.0, 1.0, house)
	_add_model("res://assets/quaternius/village/Window_Wide_Round1.gltf", Vector3(2.0, 0.8, 3.16), 0.0, 1.0, house)
	_add_model("res://assets/quaternius/village/Prop_Crate.gltf", Vector3(-2.2, 0.0, 3.8), 0.25, 0.85, house)
	_add_model("res://assets/quaternius/village/Prop_Vine1.gltf", Vector3(-1.55, 0.35, 3.2), 0.0, 0.78, house)
	_add_model("res://assets/quaternius/village/Prop_Chimney.gltf", Vector3(-2.45, 3.1, 0.8), 0.0, 1.0, house)
	for house_mesh in house.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := house_mesh as MeshInstance3D
		for surface_index in mesh_instance.mesh.get_surface_count():
			var source_material := mesh_instance.mesh.surface_get_material(surface_index) as StandardMaterial3D
			if source_material == null:
				continue
			var fade_material := source_material.duplicate() as StandardMaterial3D
			fade_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mesh_instance.set_surface_override_material(surface_index, fade_material)
			house_fade_materials.append(fade_material)
			house_fade_centers.append(position)
	var window_glow := OmniLight3D.new()
	window_glow.name = "WindowGlow"
	window_glow.position = Vector3(2.0, 1.2, 3.55)
	window_glow.light_color = Color("ffc276")
	window_glow.light_energy = 0.14
	window_glow.omni_range = 2.6
	window_glow.shadow_enabled = false
	house.add_child(window_glow)
	_add_smoke(house, Vector3(-2.45, 6.45, 0.8))


func _add_smoke(parent: Node3D, origin: Vector3) -> void:
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


func _add_village_hearth() -> void:
	var hearth := Node3D.new()
	hearth.name = "VillageHearth"
	hearth.position = Vector3(4.8, 0.0, -3.8)
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
	var ember_material := _material(Color("d85a28"), 0.5)
	ember_material.emission_enabled = true
	ember_material.emission = Color("ff792f")
	ember_material.emission_energy_multiplier = 1.5
	var ember := CSGCylinder3D.new()
	ember.name = "FireEmber"
	ember.radius = 0.5
	ember.height = 0.08
	ember.sides = 16
	ember.position.y = 0.14
	ember.material = ember_material
	ember.use_collision = true
	hearth.add_child(ember)
	var flame_material := _material(Color(1.0, 0.44, 0.12, 0.82), 0.4)
	flame_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	flame_material.emission_enabled = true
	flame_material.emission = Color("ff6f24")
	flame_material.emission_energy_multiplier = 2.2
	flame_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var flame_mesh := SphereMesh.new()
	flame_mesh.radius = 0.32
	flame_mesh.height = 0.72
	flame_mesh.radial_segments = 10
	flame_mesh.rings = 5
	for flame_index in 3:
		var flame := MeshInstance3D.new()
		flame.name = "Flame%d" % flame_index
		flame.mesh = flame_mesh
		flame.material_override = flame_material
		var origin := Vector3((float(flame_index) - 1.0) * 0.23, 0.64 + float(flame_index % 2) * 0.12, 0.0)
		flame.position = origin
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
	_add_smoke(hearth, Vector3(0.0, 1.25, 0.0))


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
	ripple_mesh.rings = 12
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
	add_child(plot)
	_add_box("Soil", Vector3(2.2, 0.08, 1.0), Vector3(0.0, 0.04, 0.0), _material(Color("4e3b2b"), 1.0), false, plot)
	var edging_material := _material(Color("6b4b2d"), 0.9)
	_add_box("NorthEdge", Vector3(2.4, 0.14, 0.12), Vector3(0.0, 0.1, -0.56), edging_material, false, plot)
	_add_box("SouthEdge", Vector3(2.4, 0.14, 0.12), Vector3(0.0, 0.1, 0.56), edging_material, false, plot)
	_add_box("WestEdge", Vector3(0.12, 0.14, 1.0), Vector3(-1.14, 0.1, 0.0), edging_material, false, plot)
	_add_box("EastEdge", Vector3(0.12, 0.14, 1.0), Vector3(1.14, 0.1, 0.0), edging_material, false, plot)
	var plants := [
		["Fern_1", Vector3(-0.75, 0.08, -0.14), -0.3, 0.18],
		["Grass_Common_Tall", Vector3(-0.35, 0.08, 0.16), 0.5, 0.28],
		["Bush_Common_Flowers", Vector3(0.05, 0.08, -0.1), 1.1, 0.22],
		["Fern_1", Vector3(0.45, 0.08, 0.16), 2.0, 0.16],
		["Grass_Common_Tall", Vector3(0.8, 0.08, -0.14), 2.6, 0.24],
	]
	for plant_data in plants:
		var plant := _add_model("res://assets/quaternius/nature/%s.gltf" % plant_data[0], plant_data[1], plant_data[2], plant_data[3], plot)
		if plant != null:
			wind_nodes.append(plant)


func _add_village_props() -> void:
	var props := Node3D.new()
	props.name = "VillageProps"
	add_child(props)
	_add_model("res://assets/quaternius/village/Prop_Wagon.gltf", Vector3(-5.8, 0.0, -2.7), -0.25, 0.9, props)
	_add_model("res://assets/quaternius/village/Prop_Crate.gltf", Vector3(-4.2, 0.0, -1.1), 0.1, 0.75, props)
	_add_model("res://assets/quaternius/village/Prop_Crate.gltf", Vector3(-4.8, 0.0, -0.8), 0.4, 0.55, props)
	_add_model("res://assets/quaternius/village/Prop_WoodenFence_Single.gltf", Vector3(6.4, 0.0, -1.6), -0.18, 1.0, props)
	_add_model("res://assets/quaternius/village/Prop_WoodenFence_Extension1.gltf", Vector3(8.4, 0.0, -1.95), -0.18, 1.0, props)
	_add_model("res://assets/quaternius/village/Prop_WoodenFence_Extension1.gltf", Vector3(10.4, 0.0, -2.3), -0.18, 1.0, props)
	var wagon_collision := _add_box("WagonCollision", Vector3(2.0, 1.5, 4.0), Vector3(-5.8, 0.75, -2.7), stone_material, true, props)
	wagon_collision.rotation.y = -0.25
	wagon_collision.visible = false
	var fence_collision := _add_box("FenceCollision", Vector3(6.1, 0.9, 0.25), Vector3(8.4, 0.45, -1.95), stone_material, true, props)
	fence_collision.rotation.y = -0.18
	fence_collision.visible = false


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
		[Vector3(0, 0, -24.7), 2.1, 1.9], [Vector3(10, 0, -24.3), 2.8, 2.3],
		[Vector3(20, 0, -24.5), 0.7, 2.0], [Vector3(-20, 0, 29.5), 2.5, 2.2],
		[Vector3(-10, 0, 29.2), 1.5, 1.9], [Vector3(0, 0, 29.7), 0.4, 2.3],
		[Vector3(10, 0, 29.3), 2.0, 2.0], [Vector3(20, 0, 29.5), 1.0, 2.2],
	]
	for index in rocks.size():
		var model := "Rock_Medium_1" if index % 2 == 0 else "Rock_Medium_2"
		_add_model("res://assets/quaternius/nature/%s.gltf" % model, rocks[index][0], rocks[index][1], rocks[index][2], boundary)
	var trees := [
		["Pine_2", Vector3(-22, 0, -17), 0.4, 1.1], ["CommonTree_1", Vector3(-22, 0, 14), 1.5, 1.0],
		["CommonTree_3", Vector3(22, 0, -16), 2.2, 0.95], ["Pine_2", Vector3(22, 0, 15), 0.9, 1.15],
		["CommonTree_1", Vector3(-15, 0, -22), 1.9, 1.0], ["CommonTree_3", Vector3(15, 0, -22), 0.5, 0.92],
		["Pine_2", Vector3(-14, 0, 27), 2.7, 1.1], ["CommonTree_1", Vector3(14, 0, 27), 1.2, 1.05],
	]
	for tree in trees:
		_add_model("res://assets/quaternius/nature/%s.gltf" % tree[0], tree[1], tree[2], tree[3], boundary)


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
	]
	for index in positions.size():
		var fog := MeshInstance3D.new()
		fog.name = "FogBank%d" % index
		fog.mesh = fog_mesh
		fog.material_override = fog_material
		fog.position = positions[index]
		fog.scale = Vector3(1.0 + float(index % 3) * 0.16, 0.85 + float(index % 2) * 0.18, 1.0)
		fog.transparency = 0.34
		fog.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(fog)
		fog_banks.append(fog)
		fog_bank_origins.append(fog.position)


func _add_nature(model: String, position: Vector3, rotation_y: float, scale: float, collision := true) -> void:
	var instance := _add_model("res://assets/quaternius/nature/%s.gltf" % model, position, rotation_y, scale)
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


func _add_ruin(position: Vector3) -> void:
	var center := position + Vector3(0.0, 0.0, -2.0)
	portal_center = center
	var platform := CSGCylinder3D.new()
	platform.name = "PortalPlatform"
	platform.radius = 4.1
	platform.height = 0.22
	platform.sides = 32
	platform.position = center + Vector3.UP * 0.08
	platform.material = stone_material
	platform.use_collision = true
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
	var left_collision := _add_box("LeftArchCollision", Vector3(1.25, 3.2, 1.5), Vector3(-2.0, 1.6, 0.0), stone_material, true, ruin)
	left_collision.visible = false
	var right_collision := _add_box("RightArchCollision", Vector3(1.25, 3.2, 1.5), Vector3(2.0, 1.6, 0.0), stone_material, true, ruin)
	right_collision.visible = false

	portal_material = _material(Color("67b8aa"), 0.25)
	portal_material.emission_enabled = true
	portal_material.emission = Color("6fe7ce")
	portal_material.emission_energy_multiplier = 0.8
	var ground_ring := CSGTorus3D.new()
	ground_ring.name = "PortalGroundRing"
	ground_ring.inner_radius = 3.05
	ground_ring.outer_radius = 3.18
	ground_ring.position = center + Vector3.UP * 0.2
	ground_ring.material = portal_material
	add_child(ground_ring)
	portal_ring = CSGTorus3D.new()
	portal_ring.name = "PortalRing"
	portal_ring.inner_radius = 1.45
	portal_ring.outer_radius = 1.8
	portal_ring.rotation_degrees.x = 90.0
	portal_ring.position = center + Vector3.UP * 1.85
	portal_ring.material = portal_material
	add_child(portal_ring)
	var portal := CSGCylinder3D.new()
	portal.name = "PortalSurface"
	portal.radius = 1.4
	portal.height = 0.08
	portal.rotation_degrees.x = 90.0
	portal.position = center + Vector3.UP * 1.85
	portal.material = portal_material
	add_child(portal)
	portal_light = OmniLight3D.new()
	portal_light.name = "PortalLight"
	portal_light.position = center + Vector3(0.0, 1.85, 0.7)
	portal_light.light_color = Color("72dac6")
	portal_light.light_energy = 0.7
	portal_light.omni_range = 8.0
	add_child(portal_light)
	var mote_material := _material(Color("9df4de"), 0.2)
	mote_material.emission_enabled = true
	mote_material.emission = Color("7ae8d0")
	mote_material.emission_energy_multiplier = 1.8
	var mote_mesh := SphereMesh.new()
	mote_mesh.radius = 0.07
	mote_mesh.height = 0.14
	mote_mesh.radial_segments = 8
	mote_mesh.rings = 4
	for index in 8:
		var mote := MeshInstance3D.new()
		mote.name = "PortalMote%d" % index
		mote.mesh = mote_mesh
		mote.material_override = mote_material
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


func _add_path(
	name: String,
	points: PackedVector2Array,
	elevation := 0.05,
	material_override: Material = null,
	depth := 0.08
) -> CSGPolygon3D:
	var path := CSGPolygon3D.new()
	path.name = name
	path.polygon = points
	path.depth = depth
	path.position.y = elevation
	path.rotation_degrees.x = 90.0
	path.material = material_override if material_override != null else path_material
	path.use_collision = false
	add_child(path)
	return path


func _add_cart_tracks(name_prefix: String, centerline: PackedVector2Array, material: Material) -> void:
	for side in [-1.0, 1.0]:
		var points := PackedVector2Array()
		for center in centerline:
			points.append(Vector2(center.x + side * 0.95 - 0.13, center.y))
		for index in range(centerline.size() - 1, -1, -1):
			var center := centerline[index]
			points.append(Vector2(center.x + side * 0.95 + 0.13, center.y))
		var suffix := "Left" if side < 0.0 else "Right"
		_add_path(name_prefix + suffix, points, 0.12, material, 0.01)


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


func _surface_texture(grass: bool) -> ImageTexture:
	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	for y in 64:
		for x in 64:
			var broad := sin(TAU * float(x) / 64.0) * 0.035 + cos(TAU * float(y) / 64.0) * 0.03
			var fine := sin(TAU * float(x * 5 + y * 3) / 64.0) * 0.025
			var value := clampf(0.91 + broad + fine, 0.82, 0.98)
			image.set_pixel(x, y, Color(value, value, value, 1.0))

	var random := RandomNumberGenerator.new()
	random.seed = 731 if grass else 1451
	var detail_count := 28 if grass else 24
	for index in detail_count:
		var x := random.randi_range(2, 61)
		var y := random.randi_range(3, 60)
		var shade := random.randf_range(0.72, 0.84) if grass else random.randf_range(0.78, 0.9)
		image.set_pixel(x, y, Color(shade, shade, shade, 1.0))
		if grass:
			image.set_pixel(x, y - 1, Color(shade + 0.04, shade + 0.04, shade + 0.04, 1.0))
			image.set_pixel(x + (-1 if index % 2 == 0 else 1), y - 2, Color(shade + 0.09, shade + 0.09, shade + 0.09, 1.0))
		else:
			var direction := Vector2i(1, 0) if index % 3 == 0 else Vector2i(0, 1)
			image.set_pixel(x + direction.x, y + direction.y, Color(shade + 0.05, shade + 0.05, shade + 0.05, 1.0))
			if index % 4 == 0:
				image.set_pixel(x - 1, y + 1, Color(0.96, 0.96, 0.96, 1.0))

	for index in 64:
		image.set_pixel(63, index, image.get_pixel(0, index))
		image.set_pixel(index, 63, image.get_pixel(index, 0))
	image.generate_mipmaps()
	return ImageTexture.create_from_image(image)
