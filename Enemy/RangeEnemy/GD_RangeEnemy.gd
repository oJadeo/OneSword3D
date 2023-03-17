extends CharacterBody3D
class_name RangeEnemy

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
var can_shoot = false
var find_new_pos_direction = Vector3.ZERO
var finding_new_pos = false
var player_pos

@onready var playerDetectionCollision = $PlayerDetection/CollisionShape3d
@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")
@export var bullet: Resource

@onready var ray = $RayCast3D
@onready var nav_agent = $NavigationAgent3D
func _ready():
	pass

func _physics_process(delta):
	if player != null:
		direction = Global.cal_sprite_direction((player.global_position - global_position).normalized())
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
			if danger :
				nav_agent.set_target_position(global_position-((player.global_position - global_position).normalized()))
				if nav_agent.is_target_reachable():
					velocity  = -((player.global_position - global_position).normalized() * fleeSpeed)
			if not can_shoot:
				if finding_new_pos :
					velocity.x = find_new_pos_direction.x
					velocity.z = find_new_pos_direction.z
					velocity = velocity.normalized()*moveSpeed
				else:
					velocity = Vector3.ZERO
	if not is_on_floor():
		velocity.y -= gravity
	move_and_slide()
		
	
func spawn_bullet():
	new_bullet = bullet.instantiate()
	var bulletDirection_x = player.get_global_position().x - get_global_position().x
	var bulletDirection_z = player.get_global_position().z - get_global_position().z
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
	
func get_collider(ray_pos,location):
	ray.set_position(ray_pos)
	var target_pos = location-ray.get_global_position()
	target_pos.y = 0
	ray.set_target_position(target_pos)
	ray.force_raycast_update()
	return ray.get_collider()

func update_target_location(location):
	var collider = get_collider((Vector3.ZERO),location)
	if collider:
		if collider.name == "Player_Character":
			can_shoot = true
			player_pos = location
			finding_new_pos = false
		else:
			can_shoot = false
			var new_pos  = Vector3.ZERO
			finding_new_pos = false
			var length = 0
			for i in range(-3,3,1):
				for j in range(-3,3,1):
					var a = i / 2.0
					var b = j / 2.0
					var new_collider = get_collider(Vector3(i,0,j),location)
					if new_collider:
						if new_collider.name == "Player_Character":
							var target_pos = location-ray.get_global_position()
							var new_legnth = target_pos.length()
							if new_legnth > length:
								nav_agent.set_target_position(ray.get_global_position())
								if nav_agent.is_target_reachable():
									length = new_legnth
									new_pos = ray.get_global_position()
									finding_new_pos = true
									find_new_pos_direction = Vector3(i,0,j).normalized()
			nav_agent.set_target_position(get_global_position())
			ray.set_position(Vector3.ZERO)
			var target_pos = location-ray.get_global_position()
			ray.set_target_position(target_pos)
			if finding_new_pos:
				nav_agent.set_target_position(new_pos)
