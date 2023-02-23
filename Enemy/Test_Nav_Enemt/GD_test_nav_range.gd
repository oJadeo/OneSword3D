extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3d
@onready var ray = $RayCast3D
const SPEED = 0.5
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var jumping = false
var jump_force = 0
var can_shoot = false
var player_pos 


func _physics_process(delta):
	if nav_agent.is_target_reachable():
		print("moving")
		var next_pos = nav_agent.get_next_path_position()
		var current_pos = get_global_position()
		var new_speed = Vector3.ZERO
		new_speed.x = (next_pos.x-current_pos.x)
		new_speed.z = (next_pos.z-current_pos.z)
		new_speed = new_speed.normalized()*SPEED
		velocity.x = new_speed.x
		velocity.z = new_speed.z
		if jumping and next_pos.y > current_pos.y:
			velocity.y = jump_force
			jumping = false
	else:
		print("can't move")
		velocity.x = 0
		velocity.z = 0
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()
	
func jump(force):
	jumping = true
	jump_force = force

func stop_jump():
	jumping = false
	jump_force = 0

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
		else:
			can_shoot = false
			var new_pos  = Vector3.ZERO
			var can_move = false
			var length = 0
			for i in range(-5,5,1):
				for j in range(-5,5,1):
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
									can_move = true
			nav_agent.set_target_position(get_global_position())
			ray.set_position(Vector3.ZERO)
			var target_pos = location-ray.get_global_position()
			ray.set_target_position(target_pos)
			if can_move:
				nav_agent.set_target_position(new_pos)
