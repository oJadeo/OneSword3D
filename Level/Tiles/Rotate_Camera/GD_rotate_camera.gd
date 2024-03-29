extends Area3D


# Called when the node enters the scene tree for the first time.
@export var angle = 0
@export var delay = false
func _rotate_camera_on_body_entered(body):
	#print("body: ",body.name)
	if (body.name == "Player_Character") :
			if delay:
				await get_tree().create_timer(0.25).timeout
			#body.rotate(Vector3(0,1,0),deg_to_rad(angle))
			body.set_target_rotation(deg_to_rad(angle))
			get_tree().call_group("Enemy","set_rotation",Vector3(0,deg_to_rad(angle),0))



func _rotate_camera_on_body_exited(body):
	#print("Player Exited")
	pass
