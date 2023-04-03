extends BaseState

@onready var idle_state = $"../Idle"
@onready var run_state = $"../Run"
@onready var jump_state = $"../Jump"
@onready var fall_state = $"../Fall"

@onready var wall_jump_timer = $"../../WallRun/WallRunJumpTimer"

@export var WALL_CLIMB_Y_VELOCITY:float = 3.0
@export var WALL_CLIMB_GRAVITY:float = 6.8
@export var WALL_JUMP_Y_VELOCITY:float  = 3.5
@export var WALL_JUMP_FORCE:float = 1

func enter() -> void:
	super()
	print("State:WallClimb")
	player.velocity.y = WALL_CLIMB_Y_VELOCITY
	player.wall_run_jumping = Vector3.ZERO
	animationState.travel("Jump")

func exit() -> void:
	pass
	
func process(delta: float,input_frame:Dictionary) -> BaseState:
	var new_state = handle_input(delta,input_frame)
	if new_state:
		return new_state
	
	if player.velocity.y < 0:
		return fall_state
	
	if not player.selected_wall:
		return fall_state
	
	player.velocity.y -= WALL_CLIMB_GRAVITY*delta
	
	player.move_and_slide()
	
	return null
	
func handle_input(delta: float,input_frame:Dictionary) -> BaseState:
	if input_frame['direction'] == Vector2.ZERO:
		return fall_state
	if input_frame['just_jump']:
		player.velocity.y = WALL_JUMP_Y_VELOCITY
		player.wall_run_jumping = player.selected_wall[2]*WALL_JUMP_FORCE
		wall_jump_timer.start()
		return jump_state
	return null
