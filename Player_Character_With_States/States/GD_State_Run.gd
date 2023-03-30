extends BaseState

@onready var idle_state = $"../Idle"
@onready var jump_state = $"../Jump"
@onready var fall_state = $"../Fall"
@onready var wall_run = $"../WallRun"
@onready var wall_climb = $"../WallClimb"

@export var SPEED = 2
@export var ACCEL = 10
@export var DIFF_ACCEL = 20
@export var JUMP_VELOCITY = 3.5
func enter() -> void:
	super()
	animationState.travel("Run")
	
func exit() -> void:
	pass
func process(delta: float,input_frame:Dictionary) -> BaseState:
	var new_state = handle_input(delta,input_frame)
	if new_state:
		return new_state
	
	if not player.is_on_floor():
		return jump_state if player.velocity.y > 0 else fall_state
	else:
		player.velocity.y = 0
	
	var direction:Vector3 = (transform.basis * Vector3(input_frame["direction"] .x,0, input_frame["direction"] .y)).normalized()
	var character_rotation:Vector3 = player.get_rotation()
	var cam_dir = Global.cal_camera_direction(rad_to_deg(character_rotation[1]))

	var target_velocity:Vector3
	target_velocity.x = direction.dot(cam_dir[0])*SPEED
	target_velocity.z = direction.dot(cam_dir[1])*SPEED
		
		
	var speed_dif = target_velocity-player.velocity
	var acceleration = Vector3.ZERO
	acceleration.x = DIFF_ACCEL if abs(speed_dif.x) > 1 else ACCEL
	acceleration.z = DIFF_ACCEL if abs(speed_dif.z) > 1 else ACCEL
	
	player.velocity.x = lerp(player.velocity.x,target_velocity.x,acceleration.x*delta)
	player.velocity.z = lerp(player.velocity.z,target_velocity.z,acceleration.z*delta)
	var was_on_floor = player.is_on_floor()
	player.move_and_slide()
	if not player.is_on_floor() and was_on_floor:
		player.coyote_timer.start()
	return null
	
func handle_input(delta: float,input_frame:Dictionary) -> BaseState:
	if input_frame['direction'] == Vector2.ZERO:
		return idle_state
	if input_frame['just_jump']:
		player.velocity.y = JUMP_VELOCITY
		return jump_state
	return null
