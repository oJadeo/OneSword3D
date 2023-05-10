extends BaseState

@onready var idle_state = $"../Run"
@onready var run_state = $"../Run"
@onready var jump_state = $"../Jump"
@onready var wall_run_state = $"../WallRun"
@onready var wall_climb_state = $"../WallClimb"
@onready var ledge_state = $"../Ledge"

@onready var wall_jump_timer = $"../../WallRun/WallRunJumpTimer"

@export var SPEED:float = 1
@export var JUMP_VELOCITY:float = 3.5
@export var GRAVITY:float = 9.8
@export var DOUBLE_JUMP_VELOCITY:float = 3.5



func enter() -> void:
	super()
	print("State:Fall")
	animationState.travel("Fall")
func exit() -> void:
	wall_jump_timer.stop()
	
func process(delta: float,input_frame:Dictionary) -> BaseState:
	var new_state = handle_input(delta,input_frame)
	if new_state:
		return new_state
	
	if player.is_on_floor():
		#Check jump Buffer first
		if not player.jump_buffer.is_stopped():
			player.velocity.y = JUMP_VELOCITY
			return jump_state
		return idle_state if input_frame["direction"] == Vector2.ZERO else run_state
	
	player.velocity.y -= GRAVITY * delta 
	
	if player.check_ledge():
		return ledge_state
	
	var target_direction = player.cal_direction(input_frame["direction"])

	player.velocity.x = target_direction.x*SPEED
	player.velocity.z = target_direction.z*SPEED

	if not wall_jump_timer.is_stopped():
		player.velocity += player.wall_run_jumping
		
	player.move_and_slide()
	
	return null

func handle_input(delta: float,input_frame:Dictionary) -> BaseState:
	if input_frame['just_jump'] and not player.coyote_timer.is_stopped():
		player.velocity.y = JUMP_VELOCITY
		return jump_state
		#Double Jump
		
	if input_frame['just_jump'] and player.can_double_jump:
		player.can_double_jump = false
		player.velocity.y = DOUBLE_JUMP_VELOCITY
		return jump_state
		
		#JumpBuffer
	if input_frame['just_jump']:
		player.jump_buffer.start()
		
	
	if input_frame["just_wall_run"] and player.is_wall_runable and player.selected_wall:
		if player.selected_wall[2].dot(player.direction) < -0.9:
			return wall_climb_state
		else:
			return wall_run_state
	return null
