extends CharacterBody3D

enum {
	IDLE,
	DRAW_WEAPON,
	STORE_WEAPON,
	CHASE,
	ATTACK,
	KNOCKBACK
}

@onready var playerDetectionCollision = $CollisionShape3d
var player = null
var state = IDLE
var block = 3
var direction = Vector3.ZERO
var moveSpeed = 0.5
var knockback = false
var blocking = false

#Animation
@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")


func _ready():
	pass

func _process(delta):
	#print(player)
	#print(state)
	if player != null:
		direction = Vector2((player.global_position - global_position).normalized().z,(player.global_position - global_position).normalized().x)
	else :
		blocking = false
		knockback = false
	match state:
		IDLE:
			animationTree.set("parameters/Idle/blend_position",direction)
			animationState.travel("Idle")
			velocity = Vector3.ZERO
		CHASE:
			if player != null and !knockback and !blocking:
				animationTree.set("parameters/Dash/blend_position",direction)
				animationState.travel("Dash")
				velocity = (player.global_position - global_position).normalized() * moveSpeed
			if player == null:
				blocking = false
				knockback = false
				state = IDLE
		ATTACK:
			if player != null:
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
			animationTree.set("parameters/Knockback/blend_position",direction)
			animationState.travel("Knockback")
			velocity += -direction * 20
		
	
	move_and_slide()
	
func draw_weapon_finished():
	print("chase")
	state = CHASE

func store_weapon_finished():
	print("call")
	if (player != null):
		state = CHASE
	else:
		state = IDLE


func knockback_recovery():
	knockback = false

func blocking_recovery():
	blocking = false

func on_attack_finished():
	state = STORE_WEAPON
	

func _on_player_detection_body_entered(body):
	if body.name == "Player_Character":
		player = body
		state = DRAW_WEAPON


func _on_player_detection_body_exited(body):
	if body.name == "Player_Character":
		player = null
		if state != ATTACK:
			state = STORE_WEAPON


func _on_hurtbox_area_entered(area):
	if area.name == "Hitbox":
		if block > 0:
			block -= 1
			blocking = true
			knockback = false
			animationState.travel("Block")
			velocity = Vector3.ZERO
		else:
			queue_free()
		
func _on_attac_range_body_entered(body):
	if body.name == "Player_Character":
		state = ATTACK


func _on_attac_range_body_exited(body):
	if body.name == "Player_Character":
		if state != ATTACK:
			state = STORE_WEAPON
