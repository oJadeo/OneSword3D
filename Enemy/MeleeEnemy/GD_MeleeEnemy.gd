extends CharacterBody3D
class_name MeleeEnemy
enum {
	IDLE,
	DRAW_WEAPON,
	STORE_WEAPON,
	CHASE,
	ATTACK,
	KNOCKBACK,
	BLOCK
}

@onready var playerDetectionCollision = $CollisionShape3d
@onready var nav_agent = $NavigationAgent3D
@onready var hitboxCollision = $Marker3d/Hitbox/HitboxCollision

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var jumping = false
var jump_force = 0

var player = null
var state = IDLE
var block = 3
var direction = Vector3.ZERO
var knockbackDirection
var lastDirection
var moveSpeed = 0.75
var knockback = false
var blocking = false
var inAttackRange = false
var attacking = false
var isRotate = false

#Animation
@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")


func _ready():
	pass

func _process(delta):
	handle_rotate()
	if not is_on_floor():
		velocity.y -= gravity * delta
	if player != null:
		direction = Global.cal_sprite_direction((player.global_position - global_position).normalized())
	else :
		blocking = false
		knockback = false
	match state:
		IDLE:
			animationTree.set("parameters/Idle/blend_position",direction)
			animationState.travel("Idle")
		CHASE:
			if player != null and !knockback and !blocking:
				if inAttackRange:
					state = ATTACK
				animationTree.set("parameters/Dash/blend_position",direction)
				animationState.travel("Dash")
				if nav_agent.is_target_reachable():
					var next_pos = nav_agent.get_next_path_position()
					var current_pos = get_global_position()
					var new_speed = Vector3.ZERO
					new_speed.x = (next_pos.x-current_pos.x)
					new_speed.z = (next_pos.z-current_pos.z)
					new_speed = new_speed.normalized()*moveSpeed
					velocity.x = new_speed.x
					velocity.z = new_speed.z
					if jumping and next_pos.y > current_pos.y:
						velocity.y = jump_force
						jumping = false
				else:
					print("Can't Go")
					velocity.x = 0
					velocity.z = 0
				#velocity = (player.global_position - global_position).normalized() * moveSpeed
			if player == null:
				blocking = false
				knockback = false
				state = IDLE
		ATTACK:
			if player != null and inAttackRange and !attacking:
				attacking = true
				velocity = Vector3.ZERO
				animationTree.set("parameters/Attack/blend_position",direction)
				animationState.travel("Attack")
		DRAW_WEAPON:
			knockback = false
			blocking = false
			velocity = Vector3.ZERO
			animationTree.set("parameters/DrawWeapon/blend_position",direction)
			animationState.travel("DrawWeapon")
		STORE_WEAPON:
			velocity = Vector3.ZERO
			animationState.travel("StoreWeapon")
			animationTree.set("parameters/StoreWeapon/blend_position",direction)
		KNOCKBACK:
			animationTree.set("parameters/Knockback/blend_position",lastDirection)
			animationState.travel("Knockback")
			velocity += knockbackDirection * 0.0075
		BLOCK:
			velocity = Vector3.ZERO
			animationTree.set("parameters/Block/blend_position",lastDirection)
			animationState.travel("Block")
			
		
	
	move_and_slide()
func handle_rotate():
	isRotate = Input.is_action_just_pressed("Rotate_CW")
	if isRotate:
		rotate(Vector3(0,1,0),deg_to_rad(-90))
	
func draw_weapon_finished():
	#print("chase")
	state = CHASE
	
func store_weapon_finished():
	#print("call")
	attacking = false
	if (player != null):
		if (inAttackRange):
			state = ATTACK
		state = CHASE
	else:
		state = IDLE


func knockback_recovery():
	attacking = false
	knockback = false
	blocking = false
	if player != null:
		state = CHASE
	else:
		state = STORE_WEAPON

func blocking_recovery():
	print("Hi")
	blocking = false
	knockback = false
	if player != null:
		state = CHASE
	else:
		state = STORE_WEAPON

func on_attack_finished():
	state = STORE_WEAPON

func jump(force):
	jumping = true
	jump_force = force

func stop_jump():
	jumping = false
	jump_force = 0

func update_target_location(location):
	nav_agent.set_target_position(location)	

func _on_player_detection_body_entered(body):
	if body.name == "Player_Character":
		player = body
		state = DRAW_WEAPON


func _on_player_detection_body_exited(body):
	if body.name == "Player_Character":
		player = null
		attacking = false
		if state != ATTACK and state != KNOCKBACK and state != BLOCK:
			state = STORE_WEAPON


func _on_hurtbox_area_entered(area):
	if area.name == "Hitbox":
		if block > 0:
			block -= 1
			blocking = true
			knockback = false
			attacking = false
			lastDirection = direction
			state = BLOCK
		else:
			queue_free()
		
func _on_attac_range_body_entered(body):
	if body.name == "Player_Character":
		inAttackRange = true
		#velocity = Vector3.ZERO
		#animationTree.set("parameters/Attack/blend_position",direction)
		#animationState.travel("Attack")
		state = ATTACK


func _on_attac_range_body_exited(body):
	if body.name == "Player_Character":
		inAttackRange = false
		if state != ATTACK and state != KNOCKBACK and state != BLOCK:
			state = STORE_WEAPON


func _on_parrybox_area_entered(area):
	if area.name == "Hitbox":
		knockback = true
		blocking = false
		lastDirection = direction
		knockbackDirection = (global_position - area.global_position).normalized()
		#animationTree.set("parameters/Knockback/blend_position",direction)
		#animationState.travel("Knockback")
		#velocity += Vector3(direction.x,direction.y,0) * -20
		state = KNOCKBACK


