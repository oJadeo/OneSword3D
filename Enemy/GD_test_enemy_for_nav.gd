extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3d

const SPEED = 0.5
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var jumping = false
var jump_force = 0

func _physics_process(delta):
	if nav_agent.is_target_reachable():
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
		print("Can't Go")
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


func update_target_location(location):
	nav_agent.set_target_position(location)
