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
	"respawn":false,
	"wall_run":false
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
		animationTree.set("parameters/Fall/blend_position",input_frame["direction"])
		animationTree.set("parameters/Jump/blend_position",input_frame["direction"])
	if input_frame["direction"] != Vector2.ZERO:
		last_direction = (transform.basis * Vector3(input_frame["direction"] .x,0, input_frame["direction"] .y)).normalized()
	input_frame["attack"] = Input.is_action_just_pressed("Attack")
	input_frame["deflect"] = Input.is_action_pressed("Deflect")
	input_frame["rotate_cw"] = Input.is_action_just_pressed("Rotate_CW")
	input_frame["rotate_ccw"] = Input.is_action_just_pressed("Rotate_CCW")
	input_frame["respawn"] = Input.is_action_pressed("Respawn")
	input_frame["jump"] = Input.is_action_pressed("Jump")
	input_frame["dash"] = Input.is_action_pressed("Dash")
	input_frame["wall_run"]  = Input.is_action_pressed("WallRun")
	if Input.is_action_pressed("Deflect"):
		deflecting = true
	elif Input.is_action_just_released("Deflect"):
		deflecting = false
		on_deflect_animation_end()
		
	if input_frame["rotate_cw"]:
		rotate(Vector3(0,1,0),deg_to_rad(-90))
	if input_frame["rotate_ccw"]:
		rotate(Vector3(0,1,0),deg_to_rad(90))
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
	if not is_on_floor() and not is_wall_running:
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

	handle_wall_run(delta)

	# Handle Jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor() and not is_wall_running:
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("Jump") and is_wall_running:
		wall_run_jump_Timer.start()
		wall_run_jumping = [true,selected_wall[2]]
		velocity.y = JUMP_VELOCITY
		is_wall_running = false

	if wall_run_jumping[0]:
		if is_on_floor():
			wall_run_jumping = [false,Vector3.ZERO]
		else:
			velocity += selected_wall[2]*3

	if slaming:
		velocity.y -= SLAM_SPEED

	if knockback :
		velocity = -Vector3(last_direction.dot(cam_dir[0]),0,last_direction.dot(cam_dir[1]))*SPEED*2.5
		move_and_slide()
		await get_tree().create_timer(0.05).timeout
		knockback = false

	if not deflecting or is_dashing  :
		velocity.x *= speed 
		velocity.z *= speed 
	elif deflecting:
		velocity.x *= BLOCK_SPEED 
		velocity.z *= BLOCK_SPEED 
	if slaming:
		velocity.x = 0
		velocity.z = 0
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
	if input_frame["dash"] and is_dash_able and not is_wall_running and not is_dashing and dash_charge != 0 and not attacking:
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
var is_wall= {'left':null,'right':null,'up':null}
var selected_wall 
var wall_run_jumping = [false,Vector3.ZERO]
const WALL_CHECK_RANGE = 1
@onready var ray = $RayCast3D
@onready var ray_target = $RayCast3D/ray_target
@onready var wall_run_timer = $WallrunTimer
@onready var wall_run_jump_Timer = $WallRunJumpTimer
func handle_wall_run(delta):
	if Input.is_action_just_pressed("WallRun") and input_frame['direction'] != Vector2.ZERO:
		is_wall_running = true
		velocity.y = 0.5
		wall_run_jumping = [false,Vector3.ZERO]
		wall_run_timer.start()
	if not input_frame["wall_run"]:
		is_wall_running = false
	if is_wall_running and input_frame['direction'] != Vector2.ZERO:
		is_wall['left'] = check_wall(Vector3(-WALL_CHECK_RANGE,0.2,0))
		is_wall['right'] = check_wall(Vector3(WALL_CHECK_RANGE,0.2,0))
		is_wall['up'] = check_wall(Vector3(0,0.2,-WALL_CHECK_RANGE))
		selected_wall = select_wall()
		if selected_wall:
			velocity.y -= 0.5 * delta
			var wall_normal = selected_wall[2]
			var move_dir = wall_normal.cross(Vector3(0,1,0))
			if move_dir.x != 0:
				velocity.z = 0
				velocity.x = 2 if velocity.x>0 else -2
			if move_dir.z != 0:
				velocity.x = 0
				velocity.z = 2 if velocity.z>0 else -2
			velocity -= wall_normal
		else:
			is_wall_running = false
func check_wall(dir):
	ray.set_target_position(dir)
	ray.force_raycast_update()
	var collided = ray.get_collider()
	if collided is StaticBody3D:
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
	print("Wallrun_timeout")
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
var perfect_deflect = false
var deflecting = false
var knockback = false
var last_direction = Vector2.ZERO
const MAX_BLOCK_BAR = 100
var blockBar = 100
var begin_regen = false
var is_regen = false
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
@onready var playerSpawnPoint = $"../playerSpawnPoint"
func handle_animation():
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
	if deflecting and not is_dashing:
		animationState.travel("Block")
	if is_dashing:
		animationState.travel("Dash")

func respawn():
	set_position(playerSpawnPoint.global_position)
	blockBar = 100
	dash_charge = 3
	emit_signal("Blockbar_changed",blockBar)
	emit_signal("DashCharge_changed",dash_charge)

func print_lam():
	print(slaming)
