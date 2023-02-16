extends CharacterBody3D

#Exploring variable
const SPEED = 5 #150 for 2 tile gap Hrozon vetical 3 tile for diagonal
const JUMP_VELOCITY = 3.5
var direction 
#Dash variable
var DASH_SPEED = 20
var dash_dur = 0.1
const MAX_CHARGE = 3
var dash_charge = 3
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
# Wallrun variable
var wall_normal
var is_wall_runable = false
@onready var wall_run_timer = $Wallrun_Timer
#Attack variable
var attacking = false
var input_combo = 1
var current_combo = 1

#Deflect variable
var perfect_deflect = false
var deflecting = false
var knockback = false
var last_direction = Vector2.ZERO
const MAX_BLOCK_BAR = 100
var blockBar = 100

var begin_regen = false
var is_regen = false

#signals
signal Blockbar_changed
signal DashCharge_changed



# input variable
var input_frame = {
	"direction" : Vector2.ZERO,
	"jump" : false,
	"attack" : false,
	"deflect" : false,
	"dash" : false,
	"rotate_cw" : false,
	"rotate_ccw" : false,
	}

#Animation variable
@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")
@onready var root = $".."
#@onready var dash = $Dash
@onready var playerCamera = $SpringArm3d/Camera3d

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	handle_input()
	handle_move(delta)
	handle_atk()
	handle_animation()
		

#take all input into input dict
func handle_input():
	input_frame["direction"] = Vector2(Input.get_axis("Move_Left", "Move_Right"),Input.get_axis("Move_Up", "Move_Down")) 
	input_frame["direction"] = input_frame["direction"] if input_frame["direction"].length() <=1 else input_frame["direction"].normalized()
	if input_frame["direction"] != Vector2.ZERO and not deflecting:
		animationTree.set("parameters/Run/blend_position",input_frame["direction"])
		animationTree.set("parameters/Idle/blend_position",input_frame["direction"])
		animationTree.set("parameters/Block/blend_position",input_frame["direction"])
		animationTree.set("parameters/Attack_1/blend_position",input_frame["direction"])
		animationTree.set("parameters/Attack_2/blend_position",input_frame["direction"])
		animationTree.set("parameters/Attack_3/blend_position",input_frame["direction"])
		animationTree.set("parameters/Dash/blend_position",input_frame["direction"])
	if input_frame["direction"] != Vector2.ZERO:
		last_direction = input_frame["direction"]
	input_frame["attack"] = Input.is_action_just_pressed("Attack")
	input_frame["deflect"] = Input.is_action_pressed("Deflect")
	input_frame["rotate_cw"] = Input.is_action_just_pressed("Rotate_CW")
	input_frame["rotate_ccw"] = Input.is_action_just_pressed("Rotate_CCW")
	input_frame["jump"] = Input.is_action_pressed("ui_accept")
	if Input.is_action_pressed("Deflect"):
		deflecting = true
	elif Input.is_action_just_released("Deflect"):
		deflecting = false
		on_deflect_animation_end()
		
	if input_frame["rotate_cw"]:
		rotate(Vector3(0,1,0),deg_to_rad(-45))
	if input_frame["rotate_ccw"]:
		rotate(Vector3(0,1,0),deg_to_rad(45))


func handle_move(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	#Handle Direction from camera_direction
	direction = (transform.basis * Vector3(input_frame["direction"] .x,0, input_frame["direction"] .y)).normalized()
	var character_rotation = get_rotation()
	var cam_dir = Global.cal_camera_direction(rad_to_deg(character_rotation[1]))

	if abs(input_frame["direction"].x) > 0.1 || abs(input_frame["direction"].y) > 0.1 :
		animationState.travel("Run")
	else:
		animationState.travel("Idle")
	if not is_on_floor():
		if velocity.y > 0:
			pass
			#animationState.travel("Fall")
		else:
			pass
			#animationState.travel("Jump")
	else:
		is_wall_runable = false
#	if (dash.dashFinished):
#		playerCamera.current = true
#	if Input.is_action_just_pressed("Dash") && dash.can_dash && !dash.is_dashing() && dash_charge != 0:
#		dash_charge -= 1
#		emit_signal("DashCharge_changed",dash_charge)
#		rechargeDashTimer.start()
#		dash.start_dash(height,sprite,dash_dur,input_frame["direction"])
#		animationState.travel("Dash")
#		playerCamera.current = false
#	var speed = DASH_SPEED if dash.is_dashing() else SPEED
	var speed = SPEED
	if direction:
		velocity.x = direction.dot(cam_dir[0])
		velocity.z = direction.dot(cam_dir[1])
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_wall_runable = true
		wall_run_timer.start()
	if knockback :
		velocity = -Vector3(last_direction.dot(cam_dir[0]),0,last_direction.dot(cam_dir[1]))*SPEED*2.5
		move_and_slide()
		await get_tree().create_timer(0.05).timeout
		knockback = false
#	if softCollision.is_colliding():
#		velocity += softCollision.get_push_vector() *_delta* 200

	if not is_on_floor() and direction and is_on_wall() and is_wall_runable:
		wall_run()
		
	if not attacking and not deflecting:
		move_and_slide()

func wall_run():
	wall_normal = get_slide_collision(0)
	await get_tree().create_timer(0.2).timeout
	velocity.y = 0
	velocity -= wall_normal.get_normal(0)*SPEED

func on_deflect_animation_end():	
	perfect_deflect = false

func handle_atk():
	if input_frame["attack"]:
		if attacking:
			match input_combo:
				1:
					input_combo = 2
				2:
					input_combo = 3
				3:
					input_combo = 4
		else:
			attacking = true
func next_attack():
	match current_combo:
		1:
			if input_combo > 1:
				current_combo = 2
		2:
			if input_combo > 2:
				current_combo = 3
func reset_attack():
	attacking = false
	input_combo = 1
	current_combo = 1
	
func handle_animation():
	if input_frame["direction"] == Vector2.ZERO and not attacking and not deflecting:
		animationState.travel("Idle")
	if attacking:
		match current_combo:
			1:
				animationState.travel("Attack_1")
			2:
				animationState.travel("Attack_2")
			3:
				animationState.travel("Attack_3")
	if (input_frame["deflect"]):	
		animationState.travel("Block")


func _on_wallrun_timer_timeout():
	is_wall_runable = false
