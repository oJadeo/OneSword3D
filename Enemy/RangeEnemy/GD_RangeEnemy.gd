extends CharacterBody3D

enum {
	IDLE,
	CHASE,
	ATTACK,
}

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var player = null
var state = IDLE
var block = 3
var direction = Vector3.ZERO
var moveSpeed = 0.5
var fleeSpeed = 0.5
var danger = false
var blocking = true
var new_bullet

@onready var playerDetectionCollision = $PlayerDetection/CollisionShape3d
@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")
@onready var bullet = preload("res://Enemy/RangeEnemy/Bullet/S_Bullet.tscn")

func _ready():
	pass

func _physics_process(delta):
	if player != null:
		direction = Vector2((player.global_position - global_position).normalized().z,(player.global_position - global_position).normalized().x)
	else:
		blocking = false
		danger = false
	match state:
		IDLE:
			velocity = Vector3.ZERO
		CHASE:
			if player != null:
				animationTree.set("parameters/Run/blend_position",direction)
				animationState.travel("Run")
				velocity = (player.global_position - global_position).normalized() * moveSpeed
			if player == null:
				state = IDLE
		ATTACK:
			if player != null:
				velocity = Vector3.ZERO
				animationTree.set("parameters/Reload/blend_position",direction)
				animationTree.set("parameters/Attack/blend_position",direction)
			if not danger:
				velocity = Vector3.ZERO
			else:
				velocity  = -((player.global_position - global_position).normalized() * fleeSpeed)
	if not is_on_floor():
		velocity.y -= gravity
	move_and_slide()
		
	
func spawn_bullet():
	new_bullet = bullet.instantiate()
	var bulletDirection_x = player.global_position.x - global_position.x
	var bulletDirection_z = player.global_position.z - global_position.z
	add_child(new_bullet)
	new_bullet.init(bulletDirection_x,bulletDirection_z,0,0,2)

func _on_player_detection_body_entered(body):
	if body.name == "Player_Character":
		player = body
		state = CHASE


func _on_player_detection_body_exited(body):
	if body.name == "Player_Character":
		player = null


func _on_attack_range_body_entered(body):
	if body.name == "Player_Character":
		state = ATTACK
		animationState.travel("Attack")


func _on_attack_range_body_exited(body):
	if body.name == "Player_Character":
		state = CHASE
		animationState.travel("Run")
		
func reload():
	animationState.travel("Reload")


func _on_danger_zone_body_entered(body):
	if body.name == "Player_Character":
		danger = true


func _on_danger_zone_body_exited(body):
	if body.name == "Player_Character":
		danger = false


func _on_hurtbox_area_entered(area):
	if area.name == "Hitbox":
		if block > 0:
			block -= 1
			blocking = true
			animationTree.set("parameters/Block/blend_position",direction)
			animationState.travel("Block")
			velocity = Vector3.ZERO
		else:
			queue_free()
			
func on_blocking_finish():
	animationState.travel("Attack")
	blocking = false
