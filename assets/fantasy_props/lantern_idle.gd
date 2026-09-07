extends Node3D
## Enable hanging mode when placing the lantern above the ground.

@export var hanging := false
@export var lit := true
@export_range(0.0, 3.0) var light_energy := 0.65
var elapsed := 0.0
@onready var lamp: OmniLight3D = $WarmLight


func _ready() -> void:
	var player := find_child("AnimationPlayer", true, false) as AnimationPlayer
	if hanging and player:
		for clip in player.get_animation_list():
			if clip != "RESET":
				player.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
				player.play(clip)
				break
	for mesh: MeshInstance3D in find_children("*", "MeshInstance3D", true, false):
		for i in mesh.mesh.get_surface_count():
			var material := mesh.mesh.surface_get_material(i) as StandardMaterial3D
			if material and material.emission_enabled:
				var local := material.duplicate() as StandardMaterial3D
				local.emission_enabled = lit
				mesh.set_surface_override_material(i, local)
	lamp.visible = lit


func _process(delta: float) -> void:
	elapsed += delta
	lamp.light_energy = light_energy * (1.0 + 0.045 * sin(elapsed * 4.7) + 0.025 * sin(elapsed * 9.2))
