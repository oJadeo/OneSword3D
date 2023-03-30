extends CharacterBody3D
class_name PlayerCharacter
#signals
signal Blockbar_changed
signal DashCharge_changed

@export var enable_wallrun : bool = true

@export var dash_version : int = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	handle_input()
	handle_move(delta)
	handle_atk()
	handle_block()
	handle_animation()
	handle_rotation(delta)

# input variable
var input_frame = {
	"direction" : Vector2.ZERO,
	"jump" : false,
	"attack" : false,
	"block" : false,
	"dash" : false,
	"rotate_cw" : false,
	"rotate_ccw" : false,
	"respawn":false,
	"wall_run":false,
	"just_jump":true
	}
#take all input into input dict
func handle_input():
	input_frame["direction"] = Vector2(Input.get_axis("Move_Left", "Move_Right"),Input.get_axis("Move_Up", "Move_Down")) 
	input_frame["direction"] = input_frame["direction"] if input_frame["direction"].length() <=1 else input_frame["direction"].normalized()
	input_frame["direction"] = input_frame["direction"] if input_frame["direction"].length() >0.05 else Vector2.ZERO
	if input_frame["direction"] != Vector2.ZERO:
		last_direction = (transform.basis * Vector3(input_frame["direction"] .x,0, input_frame["direction"] .y)).normalized()
	input_frame["attack"] = Input.is_action_just_pressed("Attack")
	input_frame["block"] = Input.is_action_pressed("Block")
	input_frame["rotate_cw"] = Input.is_action_just_pressed("Rotate_CW")
	input_frame["rotate_ccw"] = Input.is_action_just_pressed("Rotate_CCW")
	input_frame["respawn"] = Input.is_action_pressed("Respawn")
	input_frame["jump"] = Input.is_action_pressed("Jump")
	input_frame["just_jump"] = Input.is_action_just_pressed("Jump")
	input_frame["dash"] = Input.is_action_pressed("Dash")
	input_frame["wall_run"]  = Input.is_action_pressed("WallRun")

	#if input_frame["rotate_cw"]:
	#	rotate(Vector3(0,1,0),deg_to_rad(-90))
	#if input_frame["rotate_ccw"]:
	#	rotate(Vector3(0,1,0),deg_to_rad(90))
	#if input_frame["respawn"]: #Fix this back when finished testing
		#respawn()

#Exploring variable
const SPEED = 2
const BLOCK_SPEED = 0.5
const SLAM_SPEED = 0.25
const ACCEL = 10
const DECEL = 6
const FRICTION = 5
var target_velocity = Vector3.ZERO
var direction 
func handle_move(delta):
	target_velocity = Vector3.ZERO

	#Handle Direction from camera_direction
	direction = (transform.basis * Vector3(input_frame["direction"] .x,0, input_frame["direction"] .y)).normalized()
	var character_rotation = get_rotation()
	var cam_dir = Global.cal_camera_direction(rad_to_deg(character_rotation[1]))


	if direction:
		target_velocity.x = direction.dot(cam_dir[0])*SPEED
		target_velocity.z = direction.dot(cam_dir[1])*SPEED
	else:
		target_velocity.x = 0
		target_velocity.z = 0

	handle_jump(delta)
	
	if enable_wallrun:
		handle_wall_run(delta)
	
	
	var speed_dif = target_velocity-velocity
	var acceleration = Vector3.ZERO
	acceleration.x = ACCEL if abs(target_velocity.x) > 0.01 else DECEL
	acceleration.z = ACCEL if abs(target_velocity.z) > 0.01 else DECEL
	acceleration.x = acceleration.x*2 if abs(speed_dif.x) > 1 else acceleration.x
	acceleration.z = acceleration.z*2 if abs(speed_dif.z) > 1 else acceleration.z
	
	match dash_version:
		1:
			handle_dash_1()
			if not is_dashing and Vector2(velocity.x,velocity.z).length() > Vector2(target_velocity.x,target_velocity.z).length():
				acceleration.x = 10
				acceleration.z = 10
			if is_dashing:
				acceleration.x = 0 
				acceleration.z = 0
	
	velocity.x = lerp(velocity.x,target_velocity.x,acceleration.x*delta)
	velocity.z = lerp(velocity.z,target_velocity.z,acceleration.z*delta)
	
	if deflecting:
		velocity.x *= BLOCK_SPEED 
		velocity.z *= BLOCK_SPEED 

	if slaming:
		target_velocity.y -= SLAM_SPEED

	if slaming:
		velocity.x = 0
		velocity.z = 0
	
	if knockback :
		velocity = -Vector3(last_direction.dot(cam_dir[0]),0,last_direction.dot(cam_dir[1]))*SPEED*2.5
		move_and_slide()
		await get_tree().create_timer(0.05).timeout
		knockback = false

	var was_on_floor = is_on_floor()
	move_and_slide()
	if not is_on_floor() and was_on_floor and not is_jumping and not is_wall_climbing and not is_wall_running:
		coyote_timer.start()

var is_jumping = false
@onready var coyote_timer = $Timer/CoyoteTimer
@onready var jumpbuffer = $Timer/junmpBufferTimer
var gravity = 9.8
const JUMP_VELOCITY = 3.5
func handle_jump(delta):
	if is_on_floor() and not is_wall_running:
		is_jumping = false
	if is_jumping and input_frame["jump"] and velocity.y > 0 :
		velocity.y += 5*delta
	if not is_on_floor() and coyote_timer.is_stopped() and not is_wall_running :
		velocity.y -= gravity * delta 
		print(velocity.y)
		velocity.y = clamp(velocity.y,-10,100)
	# Handle Normal Jump.
	if input_frame["just_jump"] and not is_wall_running and not is_wall_climbing:
		if  is_on_floor() or not coyote_timer.is_stopped():
			coyote_timer.stop()
			jump()
		else:
			jumpbuffer.start()
	if is_on_floor() and not jumpbuffer.is_stopped():
		jumpbuffer.stop()
		jump()
func jump():
	velocity.y = JUMP_VELOCITY
	is_jumping = true
func _on_coyote_timer_timeout():
	coyote_timer.stop()
func _on_junmp_buffer_timer_timeout():
	jumpbuffer.stop()

# Dash variable
const DASH_SPEED = 13
const MAX_CHARGE = 3
var dash_charge = 3
var is_dash_able = true
var is_dashing = false
var dash_end = false
@onready var rechargeDashTimer = $Timer/RechargeDashTimer
func handle_dash_1():
	if input_frame["dash"] and is_dash_able and not is_wall_running and not is_dashing and dash_charge != 0 and not attacking:
		dash_charge -= 1
		velocity.x = direction.x*3
		velocity.z = direction.z*3
		emit_signal("DashCharge_changed",dash_charge)
		rechargeDashTimer.start()
		is_dashing = true
		is_dash_able = false
	if (not input_frame["dash"] or input_frame["direction"] == Vector2.ZERO) and is_dashing:
		end_dash()
	if not input_frame["dash"] and dash_end:
		is_dash_able = true
		dash_end = false	
func end_dash():
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
var is_wall_runable = true
var is_wall_running = false
var is_wall_climbing = false
var is_wall= {'left':null,'right':null,'up':null}
var selected_wall 
var wall_run_jumping = [false,Vector3.ZERO]
const WALL_CHECK_RANGE = 0.5
@onready var ray = $WallRun/RayCast3D
@onready var wall_run_timer = $WallRun/WallrunTimer
@onready var wall_run_jump_Timer = $WallRun/WallRunJumpTimer
func handle_wall_run(delta):
	if is_on_floor() and not is_wall_running:
		is_wall_runable = true
		is_wall_climbing = false
		is_wall_running = false
	
	if is_wall_climbing and velocity.y > 0:
		velocity.y += 3*delta
	is_wall['left'] = check_wall(Vector3(-WALL_CHECK_RANGE,0,0))
	is_wall['right'] = check_wall(Vector3(WALL_CHECK_RANGE,0,0))
	is_wall['up'] = check_wall(Vector3(0,0,-WALL_CHECK_RANGE))
	var has_wall = select_wall()
	if Input.is_action_just_pressed("WallRun") and input_frame['direction'] != Vector2.ZERO and is_wall_runable and has_wall:
		if has_wall[2].dot(direction) < -0.9:
			is_wall_climbing = true
			velocity.y = 3
			selected_wall = has_wall
			is_wall_running = false
		else:
			is_wall_running = true
			velocity.y = 0.5
			wall_run_jumping = [false,Vector3.ZERO]
			wall_run_timer.start()
			is_wall_runable = false
	if not input_frame["wall_run"]:
		is_wall_running = false
	if is_wall_running and input_frame['direction'] != Vector2.ZERO:
		is_wall['left'] = check_wall(Vector3(-WALL_CHECK_RANGE,0,0))
		is_wall['right'] = check_wall(Vector3(WALL_CHECK_RANGE,0,0))
		is_wall['up'] = check_wall(Vector3(0,0,-WALL_CHECK_RANGE))
		selected_wall = has_wall
		if selected_wall:
			velocity.y -= 0.5 * delta
			var wall_normal = selected_wall[2]
			var move_dir = wall_normal.cross(Vector3(0,1,0))
			if abs(move_dir.x) > 0.1 :
				target_velocity.z = 0
				target_velocity.x = 2 if target_velocity.x>0 else -2
			if abs(move_dir.z) > 0.1:
				target_velocity.x = 0
				target_velocity.z = 2 if target_velocity.z>0 else -2
			target_velocity -= wall_normal
		else:
			is_wall_running = false
			
	if input_frame["just_jump"] and (is_wall_running or is_wall_climbing):
		is_wall_runable = true
		wall_run_jump_Timer.start()
		wall_run_jumping = [true,selected_wall[2]]
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		is_wall_running = false
		is_wall_climbing = false
	

	if wall_run_jumping[0]:
		if is_on_floor():
			wall_run_jumping = [false,Vector3.ZERO]
		else:
			target_velocity += selected_wall[2]*3
func check_wall(dir):
	ray.set_target_position(dir)
	ray.force_raycast_update()
	var collided = ray.get_collider()
	if collided is StaticBody3D or collided is GridMap:
		return [collided,(ray.get_collision_point()-get_global_position()).length(),ray.get_collision_normal()]
	return null
func select_wall():
	var result = null
	if is_wall['left']:
		result = is_wall['left']
	if is_wall['right']:
		if result:
			result = is_wall['right'] if is_wall['right'][1] < result[1] else result
		else:
			result = is_wall['right']
	if is_wall['up']:
		if result:
			result = is_wall['up'] if is_wall['up'][1] < result[1] else result
		else:
			result = is_wall['up']
	return result
func _on_wallrun_timer_timeout():
	is_wall_running = false
func _on_wall_run_jump_timer_timeout():
	wall_run_jumping = [false,Vector3.ZERO]

#Attack variable
var attacking = false
var slaming = false
func handle_atk():
	if input_frame["attack"] and not attacking and not is_wall_running:
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
var iFrame = false
var perfect_deflect = false
var deflecting = false
var knockback = false
var last_direction = Vector3.ZERO
const MAX_BLOCK_BAR = 100
var blockBar = 100
var begin_regen = false
var is_regen = false
@onready var iframeTimer = $Timer/IframeTimer

func _on_hurt_box_area_entered(area):
	if "Hitbox" not in area.name :
		return 0
	if not perfect_deflect and ( not deflecting or blockBar < 20):
		if blockBar == 0 or not deflecting:
			respawn()
		else:
			regen_timer.stop()
			blockBar = 0
			knockback = true
			emit_signal("Blockbar_changed",blockBar)
			recharge_block_timer.start()
			print("blockBar : " + str(blockBar))
	elif not perfect_deflect and blockBar >= 20 and !iFrame:
		regen_timer.stop()
		knockback = true
		blockBar -= 20
		iFrame = true
		iframeTimer.start()
		emit_signal("Blockbar_changed",blockBar)
		recharge_block_timer.start()
		print("blockBar : " + str(blockBar))
func on_deflect_animation_end():	
	perfect_deflect = false
@onready var recharge_block_timer = $Timer/RechargeBlockTimer
@onready var regen_timer = $Timer/RegenTimer
func handle_block():
	if Input.is_action_pressed("Block") and is_on_floor() and not is_dashing and not is_wall_running and not slaming:
		deflecting = true
	elif Input.is_action_just_released("Block"):
		deflecting = false
		on_deflect_animation_end()
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
@onready var playerSpawnPoint = $"../playerSpawnPoint"
func handle_animation():
	if input_frame["direction"] != Vector2.ZERO and not deflecting and not attacking:
		animationTree.set("parameters/Run/blend_position",input_frame["direction"])
		animationTree.set("parameters/Idle/blend_position",input_frame["direction"])
		animationTree.set("parameters/Block/blend_position",input_frame["direction"])
		animationTree.set("parameters/Attack_1/blend_position",input_frame["direction"])
		animationTree.set("parameters/Slaming/blend_position",input_frame["direction"])
		animationTree.set("parameters/Slam_end/blend_position",input_frame["direction"])
		animationTree.set("parameters/Dash/blend_position",input_frame["direction"])
		animationTree.set("parameters/Fall/blend_position",input_frame["direction"])
		animationTree.set("parameters/Jump/blend_position",input_frame["direction"])
		animationTree.set("parameters/Wall_run_left/blend_position",Global.cal_sprite_direction(velocity))
		animationTree.set("parameters/Wall_run_right/blend_position",Global.cal_sprite_direction(velocity))
	animationState.travel("Idle")
	if abs(input_frame["direction"].x) > 0.1 || abs(input_frame["direction"].y) > 0.1 :
		animationState.travel("Run")
	if not is_on_floor():
		if velocity.y > 0:
			animationState.travel("Jump")
		else:
			animationState.travel("Fall")
	if attacking:
		if slaming:
			if not is_on_floor():
				animationState.travel("Slaming")
			else:
				animationState.travel("Slam_end")
		else:
			animationState.travel("Attack_1")
	if is_wall_running:
		if velocity.cross(selected_wall[2]).y < 0:
			animationState.travel("Wall_run_left")
		else:
			animationState.travel("Wall_run_right")
	if deflecting and not is_dashing and is_on_floor():
		animationState.travel("Block")
	if is_dashing:
		animationState.travel("Dash")
func respawn():
	set_position(playerSpawnPoint.global_position)
	blockBar = 100
	dash_charge = 3
	emit_signal("Blockbar_changed",blockBar)
	emit_signal("DashCharge_changed",dash_charge)
	get_tree().call_group("respawn","respawn")
func _on_iframe_timer_timeout():
	iFrame = false
	
# For Rotaion Camera
@export var tar_rot :float = 0
func set_target_rotation(new_tar_rot):
	tar_rot = new_tar_rot
func handle_rotation(delta):
	rotation.y = lerp_angle(rotation.y,tar_rot,5.0*delta)
# For depthBox to behind box
func set_draw_flag(draw):
	$Sprite3d.set_draw_flag(3,draw)



