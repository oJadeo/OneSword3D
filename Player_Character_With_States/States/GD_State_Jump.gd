extends BaseState

@onready var idle_state = $"../Idle"
@onready var run_state = $"../Run"
@onready var fall_state = $"../Fall"

@export var SPEED = 1
@export var DOUBLE_JUMP_VELOCITY = 3.5
@export var GRAVITY = 9.8
@export var HOLDJUMPFORCE = 3
var just_enter = false
func enter() -> void:
	super()
	player.coyote_timer.stop()
	player.jump_buffer.stop()
	animationState.travel("Jump")
	just_enter = true
func exit() -> void:
	pass
	
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
	
	var direction:Vector3 = (transform.basis * Vector3(input_frame["direction"] .x,0, input_frame["direction"] .y)).normalized()
	var character_rotation:Vector3 = player.get_rotation()
	var cam_dir = Global.cal_camera_direction(rad_to_deg(character_rotation[1]))

	player.velocity.x = direction.dot(cam_dir[0])*SPEED
	player.velocity.z = direction.dot(cam_dir[1])*SPEED

	player.move_and_slide()
	return null

func handle_input(delta: float,input_frame:Dictionary) -> BaseState:
	if input_frame['jump']:
		player.velocity.y += HOLDJUMPFORCE * delta 
		
	if input_frame['just_jump']:
		#Double Jump
		pass
	return null
