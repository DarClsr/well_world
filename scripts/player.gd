extends CharacterBody3D

const SPEED := 7.0
const TURN_SPEED := 2.2
const GRAVITY := 24.0
const CAMERA_MIN_HEIGHT := 10.0
const CAMERA_MAX_HEIGHT := 20.0
const CAMERA_Z_RATIO := 14.0 / 15.0
const CAMERA_ZOOM_STEP := 1.5
const CAMERA_LEAD_DISTANCE := 1.6
const CAMERA_LEAD_SPEED := 6.0
const FOOTSTEP_STREAMS: Array[AudioStream] = [
	preload("res://assets/audio/footstep_1.ogg"),
	preload("res://assets/audio/footstep_2.ogg"),
]

var camera_yaw := 0.0
var walk_time := 0.0
var camera_target_height := 15.0
var footstep_index := 0
var character_animation: AnimationPlayer


func _ready() -> void:
	character_animation = $Visual/CharacterModel.find_child("AnimationPlayer", true, false) as AnimationPlayer
	for animation_name in ["Idle", "Run"]:
		if character_animation.has_animation(animation_name):
			character_animation.get_animation(animation_name).loop_mode = Animation.LOOP_LINEAR
	character_animation.play("Idle")
	var footsteps := AudioStreamPlayer3D.new()
	footsteps.name = "Footsteps"
	footsteps.volume_db = -26.0
	footsteps.max_db = -26.0
	footsteps.max_distance = 12.0
	add_child(footsteps)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton) or not event.pressed:
		return
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		camera_target_height = maxf(camera_target_height - CAMERA_ZOOM_STEP, CAMERA_MIN_HEIGHT)
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		camera_target_height = minf(camera_target_height + CAMERA_ZOOM_STEP, CAMERA_MAX_HEIGHT)
	else:
		return
	get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	_update_camera_zoom(delta)
	camera_yaw += Input.get_axis("camera_left", "camera_right") * TURN_SPEED * delta
	$CameraRig.rotation.y = camera_yaw

	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := Vector3(input.x, 0.0, input.y).rotated(Vector3.UP, camera_yaw)
	velocity.x = move_toward(velocity.x, direction.x * SPEED, 30.0 * delta)
	velocity.z = move_toward(velocity.z, direction.z * SPEED, 30.0 * delta)
	velocity.y = -GRAVITY if not is_on_floor() else -0.5

	if direction.length_squared() > 0.01:
		$Visual.rotation.y = lerp_angle($Visual.rotation.y, atan2(direction.x, direction.z), 12.0 * delta)

	move_and_slide()
	_update_camera_lead(delta, get_real_velocity())
	var move_amount := Vector2(velocity.x, velocity.z).length() / SPEED if is_on_floor() else 0.0
	_update_walk_visual(delta, move_amount)


func _update_camera_zoom(delta: float) -> void:
	var camera := $CameraRig/Camera3D as Camera3D
	var target := Vector3(0.0, camera_target_height, camera_target_height * CAMERA_Z_RATIO)
	camera.position = camera.position.lerp(target, minf(delta * 8.0, 1.0))


func _update_camera_lead(delta: float, real_velocity: Vector3) -> void:
	var planar_velocity := Vector3(real_velocity.x, 0.0, real_velocity.z)
	var target := planar_velocity.normalized() * CAMERA_LEAD_DISTANCE if planar_velocity.length_squared() > 0.01 else Vector3.ZERO
	$CameraRig.position = $CameraRig.position.lerp(target, minf(delta * CAMERA_LEAD_SPEED, 1.0))


func _update_walk_visual(delta: float, move_amount: float) -> void:
	if move_amount > 0.05:
		var previous_step := floori(walk_time / PI)
		walk_time += delta * 10.0 * move_amount
		if floori(walk_time / PI) > previous_step:
			_play_footstep()
	var target_animation := "Run" if move_amount > 0.05 else "Idle"
	if character_animation.current_animation != target_animation:
		character_animation.play(target_animation, 0.15)


func _play_footstep() -> void:
	var footsteps := $Footsteps as AudioStreamPlayer3D
	footsteps.stream = FOOTSTEP_STREAMS[footstep_index]
	footsteps.play()
	footstep_index = (footstep_index + 1) % FOOTSTEP_STREAMS.size()
