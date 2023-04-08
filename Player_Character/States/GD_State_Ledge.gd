extends BaseState

@onready var idle_state = $"../Idle"
@onready var run_state = $"../Run"
@onready var jump_state = $"../Jump"
@onready var fall_state = $"../Fall"
@onready var hook_state = $"../Hook"

@onready var wall_run_timer = $"../../WallRun/WallrunTimer"
@onready var wall_jump_timer = $"../../WallRun/WallRunJumpTimer"

@export var ACCEL_TO_LEDGE:float = 0.1
@export var JUMP_VELOCITY:float = 3.5
func enter() -> void:
	super()
	print("State:Ledging")
	animationState.travel("Fall")

func exit() -> void:
	super()
	
	
func process(delta: float,input_frame:Dictionary) -> BaseState:
	var new_state = handle_input(delta,input_frame)
	if new_state:
		return new_state
	
	if player.go_to_hook:
		return hook_state
		
	player.velocity = player.ledge_pos - player.position
	
	player.move_and_slide()
	
	return null
	
func handle_input(delta: float,input_frame:Dictionary) -> BaseState:
	if input_frame['just_jump']:
		player.velocity.y += JUMP_VELOCITY
		return jump_state
	return null

