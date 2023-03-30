extends BaseState

@onready var idle_state = $"../Run"
@onready var run_state = $"../Run"
@onready var jump_state = $"../Jump"

@export var SPEED = 1
@export var JUMP_VELOCITY = 3.5
@export var GRAVITY = 9.8

func enter() -> void:
	super()
	animationState.travel("Fall")
func exit() -> void:
	pass
	
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
	
	var direction:Vector3 = (transform.basis * Vector3(input_frame["direction"] .x,0, input_frame["direction"] .y)).normalized()
	var character_rotation:Vector3 = player.get_rotation()
	var cam_dir = Global.cal_camera_direction(rad_to_deg(character_rotation[1]))

	player.velocity.x = direction.dot(cam_dir[0])*SPEED
	player.velocity.z = direction.dot(cam_dir[1])*SPEED

	player.move_and_slide()
	return null

func handle_input(delta: float,input_frame:Dictionary) -> BaseState:
	if input_frame['just_jump'] and not player.coyote_timer.is_stopped():
		player.velocity.y = JUMP_VELOCITY
		return jump_state
		#Double Jump
		
		#JumpBuffer
	if input_frame['just_jump']:
		player.jump_buffer.start()
	return null
