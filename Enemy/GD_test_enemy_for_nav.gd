extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3d

const SPEED = 0.5
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	velocity = Vector3.ZERO
	if nav_agent.is_target_reachable():
		var next_pos = nav_agent.get_next_location()
		velocity.x = (next_pos.x-get_global_position().x)
		velocity.z = (next_pos.z-get_global_position().z)
		velocity = velocity.normalized()*SPEED
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()
func update_target_location(location):
	nav_agent.set_target_location(location)
