extends CharacterBody3D

#signals
signal Blockbar_changed
signal DashCharge_changed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
func _physics_process(delta):
	handle_input()
	handle_move(delta)
	handle_atk()
	handle_animation()

# input variable
var input_frame = {
	"direction" : Vector2.ZERO,
	"jump" : false,
	"attack" : false,
	"deflect" : false,
	"dash" : false,
	"rotate_cw" : false,
	"rotate_ccw" : false,
	"respawn":false
	}
#take all input into input dict
func handle_input():
	input_frame["direction"] = Vector2(Input.get_axis("Move_Left", "Move_Right"),Input.get_axis("Move_Up", "Move_Down")) 
	input_frame["direction"] = input_frame["direction"] if input_frame["direction"].length() <=1 else input_frame["direction"].normalized()
	if input_frame["direction"] != Vector2.ZERO and not deflecting:
		animationTree.set("parameters/Run/blend_position",input_frame["direction"])
		animationTree.set("parameters/Idle/blend_position",input_frame["direction"])
		animationTree.set("parameters/Block/blend_position",input_frame["direction"])
		animationTree.set("parameters/Attack_1/blend_position",input_frame["direction"])
		animationTree.set("parameters/Slaming/blend_position",input_frame["direction"])
		animationTree.set("parameters/Slam_end/blend_position",input_frame["direction"])
		animationTree.set("parameters/Dash/blend_position",input_frame["direction"])
	if input_frame["direction"] != Vector2.ZERO:
		last_direction = (transform.basis * Vector3(input_frame["direction"] .x,0, input_frame["direction"] .y)).normalized()
	input_frame["attack"] = Input.is_action_just_pressed("Attack")
	input_frame["deflect"] = Input.is_action_pressed("Deflect")
	input_frame["rotate_cw"] = Input.is_action_just_pressed("Rotate_CW")
	input_frame["rotate_ccw"] = Input.is_action_just_pressed("Rotate_CCW")
	input_frame["respawn"] = Input.is_action_pressed("Respawn")
	input_frame["jump"] = Input.is_action_pressed("Jump")
	input_frame["dash"] = Input.is_action_pressed("Dash")
	if Input.is_action_pressed("Deflect"):
		deflecting = true
	elif Input.is_action_just_released("Deflect"):
		deflecting = false
		on_deflect_animation_end()
		
	if input_frame["rotate_cw"]:
		rotate(Vector3(0,1,0),deg_to_rad(-45))
	if input_frame["rotate_ccw"]:
		rotate(Vector3(0,1,0),deg_to_rad(45))
	if input_frame["respawn"]:
		respawn()

#Exploring variable
const SPEED = 1 
const BLOCK_SPEED = 0.5
const JUMP_VELOCITY = 3.5
const SLAM_SPEED = 0.25
var direction 

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
func handle_move(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	#Handle Direction from camera_direction
	direction = (transform.basis * Vector3(input_frame["direction"] .x,0, input_frame["direction"] .y)).normalized()
	var character_rotation = get_rotation()
	var cam_dir = Global.cal_camera_direction(rad_to_deg(character_rotation[1]))

	handle_dash()

	var speed = DASH_SPEED if is_dashing else SPEED
	
	if direction:
		velocity.x = direction.dot(cam_dir[0])
		velocity.z = direction.dot(cam_dir[1])
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	# Handle Jump.
	if input_frame["jump"] and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_wall_runable = true
		wall_run_timer.start()
	if input_frame["jump"] and is_wall_running:
		velocity -= wall_normal.get_normal(0)*SPEED
		velocity.y = JUMP_VELOCITY
		is_wall_running = false
	if knockback :
		velocity = -Vector3(last_direction.dot(cam_dir[0]),0,last_direction.dot(cam_dir[1]))*SPEED*2.5
		move_and_slide()
		await get_tree().create_timer(0.05).timeout
		knockback = false

	if slaming:
		velocity.y -= SLAM_SPEED

	if not is_on_floor() and direction and is_on_wall() and is_wall_runable:
		wall_run()
	if (is_on_floor() or not is_on_wall() or input_frame["direction"] == Vector2.ZERO) and is_wall_running:
		reset_wall_run()
	if is_wall_running and is_wall_runable:
		velocity -= wall_normal.get_normal(0)
		velocity.y = 0
		velocity = velocity.normalized()

	if not deflecting:
		velocity.x *= speed 
		velocity.z *= speed 
		move_and_slide()
	elif deflecting:
		velocity.x *= BLOCK_SPEED 
		velocity.y *= BLOCK_SPEED 
		move_and_slide()
		
# Dash variable
const DASH_SPEED = 10
const MAX_CHARGE = 3
var dash_charge = 3
var is_dash_able = true
var is_dashing = false
var dash_end = false
@onready var rechargeDashTimer = $RechargeDashTimer
func handle_dash():
	if input_frame["dash"] and is_dash_able and not is_wall_running and not is_dashing and dash_charge != 0:
		dash_charge -= 1
		emit_signal("DashCharge_changed",dash_charge)
		rechargeDashTimer.start()
		is_dashing = true
		is_dash_able = false
	if not input_frame["dash"] and is_dashing:
		end_dash()
	if not input_frame["dash"] and dash_end:
		is_dash_able = true
		dash_end = false
func end_dash():
	print("End dash")
	dash_end = true
	is_dashing = false
func _on_recharge_dash_timer_timeout():
	rechargeDashTimer.stop()
	if dash_charge < MAX_CHARGE :
		dash_charge += 1
		emit_signal("DashCharge_changed",dash_charge)
		if dash_charge != MAX_CHARGE :
			rechargeDashTimer.start()
	
# Wallrun variable
var wall_normal
var is_wall_running = false
var is_wall_runable = false
@onready var wall_run_timer = $WallrunTimer
func wall_run():
	wall_normal = get_slide_collision(0)
	await get_tree().create_timer(0.2).timeout
	is_wall_running = true
func reset_wall_run():
	is_wall_runable = false
	is_wall_running = false
func _on_wallrun_timer_timeout():
	reset_wall_run()

#Attack variable
var attacking = false
var slaming = false
func handle_atk():
	if input_frame["attack"]:
		slaming = not is_on_floor()
		attacking = true
func reset_attack():
	slaming = false
	attacking = false
func _on_hitbox_area_entered(area):
	if area.name == "HurtBox":
		print("Player:hit enemy")
	elif area.name == "HitBox":
		print("Player:parry success")

#Deflect variable
var perfect_deflect = false
var deflecting = false
var knockback = false
var last_direction = Vector2.ZERO
const MAX_BLOCK_BAR = 100
var blockBar = 100
var begin_regen = false
var is_regen = false
func _on_hurt_box_area_entered(area):
	if area.name != 'Hitbox':
		return 0
	if not perfect_deflect and ( not deflecting or blockBar < 20):
		if blockBar == 0 or not deflecting:
			print("ouch!!!")
			respawn()
		else:
			regen_timer.stop()
			blockBar = 0
			knockback = true
			emit_signal("Blockbar_changed",blockBar)
			recharge_block_timer.start()
			print("blockBar : " + str(blockBar))
	elif not perfect_deflect and blockBar >= 20 :
		regen_timer.stop()
		knockback = true
		blockBar -= 20
		emit_signal("Blockbar_changed",blockBar)
		recharge_block_timer.start()
		print("blockBar : " + str(blockBar))
func on_deflect_animation_end():	
	perfect_deflect = false
@onready var recharge_block_timer = $RechargeBlockTimer
@onready var regen_timer = $RegenTimer
func regen_blockBar():
	while is_regen and blockBar < MAX_BLOCK_BAR:
		blockBar += 1
		await get_tree().create_timer(.1).timeout
		emit_signal("Blockbar_changed",blockBar)
func _on_recharge_block_timer_timeout():
	recharge_block_timer.stop()
	if blockBar < MAX_BLOCK_BAR :
		regen_timer.start()
func _on_regen_timer_timeout():
	regen_timer.stop()
	if blockBar < MAX_BLOCK_BAR :
		blockBar += 1
		emit_signal("Blockbar_changed",blockBar)
		if blockBar != MAX_BLOCK_BAR :
			regen_timer.start()

#Animation variable
@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")
@onready var root = $".."
#@onready var dash = $Dash
@onready var playerCamera = $SpringArm3d/Camera3d
@onready var playerSpawnPoint = $"../playerSpawnPoint"
func handle_animation():
	animationState.travel("Idle")
	if abs(input_frame["direction"].x) > 0.1 || abs(input_frame["direction"].y) > 0.1 :
		animationState.travel("Run")
	if not is_on_floor():
		if velocity.y > 0:
			pass
			#animationState.travel("Fall")
		else:
			pass
			#animationState.travel("Jump")
	if is_dashing:
		animationState.travel("Dash")
	if attacking:
		if slaming:
			if not is_on_floor():
				animationState.travel("Slaming")
			else:
				animationState.travel("Slam_end")
		else:
			animationState.travel("Attack_1")
	if (input_frame["deflect"]):	
		animationState.travel("Block")

func respawn():
	set_position(playerSpawnPoint.global_position)
	blockBar = 100
	dash_charge = 3
	emit_signal("Blockbar_changed",blockBar)
	emit_signal("DashCharge_changed",dash_charge)
