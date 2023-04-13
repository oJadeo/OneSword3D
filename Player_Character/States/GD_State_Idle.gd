extends BaseState

@onready var run_state = $"../Run"
@onready var jump_state = $"../Jump"
@onready var fall_state = $"../Fall"
@onready var hook_state = $"../Hook"

@onready var wall_jump_timer = $"../../WallRun/WallRunJumpTimer"

@export var JUMP_VELOCITY:float = 3.5
@export var DECEL:float = 6

func enter() -> void:
	super()
	print("State:Idle")
	animationState.travel("Idle")
	player.can_double_jump = true

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
	
	if player.go_to_hook:
		return hook_state
	
	if player.velocity != Vector3.ZERO:
		player.velocity.x = lerp(player.velocity.x,0.0,DECEL*delta)
		player.velocity.z = lerp(player.velocity.z,0.0,DECEL*delta)
	
	var was_on_floor = player.is_on_floor()
	player.move_and_slide()
	if not player.is_on_floor() and was_on_floor:
		player.coyote_timer.start()
	
	return null
	
func handle_input(delta: float,input_frame:Dictionary) -> BaseState:
	if input_frame['direction'] != Vector2.ZERO:
		return run_state
	if input_frame['just_jump']:
		player.velocity.y = JUMP_VELOCITY
		return jump_state
	return null
