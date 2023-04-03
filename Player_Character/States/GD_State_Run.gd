extends BaseState

@onready var idle_state = $"../Idle"
@onready var jump_state = $"../Jump"
@onready var fall_state = $"../Fall"
@onready var wall_run_state = $"../WallRun"
@onready var wall_climb_state = $"../WallClimb"

@onready var wall_jump_timer = $"../../WallRun/WallRunJumpTimer"

@export var SPEED:float = 2
@export var ACCEL:float = 10
@export var DIFF_ACCEL:float = 20
@export var JUMP_VELOCITY:float = 3.5



func enter() -> void:
	super()
	print("State:Run")
	wall_jump_timer.stop()
	animationState.travel("Run")
	player.is_wall_runable = true
	
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
	
	var target_direction = player.cal_direction()

	var target_velocity:Vector3
	target_velocity.x = target_direction.x*SPEED
	target_velocity.z = target_direction.z*SPEED

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
	if input_frame["just_wall_run"] and player.is_wall_runable and player.selected_wall:
		if player.selected_wall[2].dot(player.direction) < -0.9:
			return wall_climb_state
		else:
			return wall_run_state
	return null
