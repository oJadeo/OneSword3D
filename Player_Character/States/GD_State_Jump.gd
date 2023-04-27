extends BaseState

@onready var idle_state = $"../Idle"
@onready var run_state = $"../Run"
@onready var fall_state = $"../Fall"
@onready var wall_run_state = $"../WallRun"
@onready var wall_climb_state = $"../WallClimb"
@onready var ledge_state = $"../Ledge"
@onready var hook_state = $"../Hook"

@onready var wall_jump_timer = $"../../WallRun/WallRunJumpTimer"

@export var SPEED:float = 1
@export var DOUBLE_JUMP_VELOCITY:float = 3.5
@export var GRAVITY:float = 9.8
@export var HOLDJUMPFORCE:float = 3

var just_enter = false
func enter() -> void:
	super()
	player.coyote_timer.stop()
	player.jump_buffer.stop()
	player.is_wall_runable = true
	just_enter = true
	animationState.travel("Jump")
func exit() -> void:
	wall_jump_timer.stop()
	
func process(delta: float,input_frame:Dictionary) -> BaseState:
	var new_state = handle_input(delta,input_frame)
	if new_state:
		return new_state
	
	if player.is_on_floor() and not just_enter:
		#Check jump Buffer first
		return idle_state if input_frame["direction"] == Vector2.ZERO else run_state
	just_enter = false
	if player.velocity.y < 0:
		return fall_state
	player.velocity.y -= GRAVITY * delta 
	
	if player.check_ledge() and player.velocity.y < 0.1:
		return ledge_state
	
	if player.go_to_hook:
		return hook_state
	
	var target_direction = player.cal_direction(input_frame["direction"])

	player.velocity.x = target_direction.x*SPEED
	player.velocity.z = target_direction.z*SPEED

	if not wall_jump_timer.is_stopped():
		player.velocity += player.wall_run_jumping
		
	player.move_and_slide()
	
	return null

func handle_input(delta: float,input_frame:Dictionary) -> BaseState:
	if input_frame['jump']:
		player.velocity.y += HOLDJUMPFORCE * delta 
		
	if input_frame['just_jump'] and player.can_double_jump:
		player.velocity.y = DOUBLE_JUMP_VELOCITY
	
	if input_frame["just_wall_run"] and player.is_wall_runable and player.selected_wall:
		if player.selected_wall[2].dot(player.direction) < -0.9:
			return wall_climb_state
		else:
			return wall_run_state
	return null
