extends BaseState

@onready var idle_state = $"../Idle"
@onready var run_state = $"../Run"
@onready var jump_state = $"../Jump"
@onready var fall_state = $"../Fall"

@onready var wall_run_timer = $"../../WallRun/WallrunTimer"
@onready var wall_jump_timer = $"../../WallRun/WallRunJumpTimer"

@export var WALL_RUN_Y_VELOCITY:float = 0.5
@export var WALL_RUN_GRAVITY:float = 0.5
@export var WALL_RUN_SPEED:float = 2.0
@export var WALL_JUMP_Y_VELOCITY:float = 3.5
@export var WALL_JUMP_FORCE:float = 1

func enter() -> void:
	super()
	print("State:WallRun")
	player.velocity.y = WALL_RUN_Y_VELOCITY
	player.is_wall_runable = false
	player.wall_run_jumping = Vector3.ZERO
	wall_run_timer.start()
	cal_velocity()
	if player.velocity.cross(player.selected_wall[2]).y < 0:
		animationState.travel("Wall_run_left")
	else:
		animationState.travel("Wall_run_right")

func exit() -> void:
	wall_run_timer.stop()
	super()
	
	
func process(delta: float,input_frame:Dictionary) -> BaseState:
	var new_state = handle_input(delta,input_frame)
	if new_state:
		return new_state
	
	if wall_run_timer.is_stopped():
		return fall_state
	
	if player.selected_wall:
		cal_velocity()
	else:
		return fall_state
	
	player.velocity.y -= WALL_RUN_GRAVITY*delta

	player.move_and_slide()
	
	return null
	
func handle_input(delta: float,input_frame:Dictionary) -> BaseState:
	if input_frame['direction'] == Vector2.ZERO:
		return idle_state
	if input_frame['just_jump']:
		player.velocity.y = WALL_JUMP_Y_VELOCITY
		player.wall_run_jumping = player.selected_wall[2]*WALL_JUMP_FORCE
		wall_jump_timer.start()
		return jump_state
	if not input_frame['wall_run']:
		return fall_state
	return null

func cal_velocity():
	var wall_normal = player.selected_wall[2]
	var move_dir = wall_normal.cross(Vector3(0,1,0))
	if abs(move_dir.x) > 0.1 :
		player.velocity.z = 0
		player.velocity.x = WALL_RUN_SPEED if player.velocity.x>0 else -WALL_RUN_SPEED
		player.direction = Vector3(1,0,0) if player.velocity.x>0 else Vector3(-1,0,0)
	if abs(move_dir.z) > 0.1:
		player.velocity.x = 0
		player.velocity.z = WALL_RUN_SPEED if player.velocity.z>0 else -WALL_RUN_SPEED
		player.direction = Vector3(0,0,1) if player.velocity.z>0 else Vector3(0,0,-1)
	player.velocity -= wall_normal
	
