extends BaseState

@onready var jump_state = $"../Jump"
@onready var fall_state = $"../Fall"

@onready var wall_jump_timer = $"../../WallRun/WallRunJumpTimer"

@export var JUMP_VELOCITY:float = 3.5
@export var SPEED:float = 4
@export var ACCEL:float = 10
var hook_direction:Vector3
func enter() -> void:
	super()
	print("State:Hooking")
	player.go_to_hook = false
	player.can_shoot = false
	hook_direction = (player.target_hook - player.global_position).normalized()
	animationState.travel("Dash")
	player.animationTree.set("parameters/Dash/blend_position",Vector2(hook_direction.x,hook_direction.z))

func exit() -> void:
	player.target_hook = Vector3.ZERO
	player.can_shoot = true
	
func process(delta: float,input_frame:Dictionary) -> BaseState:
	var new_state = handle_input(delta,input_frame)
	if new_state:
		return new_state
	
	if hook_direction.dot((player.target_hook - player.global_position).normalized()) < 0:
		return fall_state
		
	var target_velocity:Vector3 =hook_direction* SPEED
	
	player.velocity.x = lerp(player.velocity.x,target_velocity.x,ACCEL*delta)
	player.velocity.z = lerp(player.velocity.z,target_velocity.z,ACCEL*delta)
	player.velocity.y = 0
	
	var was_on_floor = player.is_on_floor()
	player.move_and_slide()
	if not player.is_on_floor() and was_on_floor:
		player.coyote_timer.start()
	
	return null
	
func handle_input(_delta: float,input_frame:Dictionary) -> BaseState:
	if input_frame['just_jump']:
		player.velocity.y = JUMP_VELOCITY
		return jump_state
	if input_frame['attack']:
		return fall_state
	return null
