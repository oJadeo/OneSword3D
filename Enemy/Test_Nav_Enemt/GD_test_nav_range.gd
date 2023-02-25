extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3d
@onready var ray = $RayCast3D
const SPEED = 0.5
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var jumping = false
var jump_force = 0
var can_shoot = false
var moving = false
var player_pos 
var direction = Vector3.ZERO

func _physics_process(delta):
	if moving:
		velocity.x = direction.x
		velocity.z = direction.z
	else:
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
			moving = false
		else:
			can_shoot = false
			var new_pos  = Vector3.ZERO
			moving = false
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
									moving = true
									direction = Vector3(i,0,j).normalized()
			nav_agent.set_target_position(get_global_position())
			ray.set_position(Vector3.ZERO)
			var target_pos = location-ray.get_global_position()
			ray.set_target_position(target_pos)
			if moving:
				nav_agent.set_target_position(new_pos)
