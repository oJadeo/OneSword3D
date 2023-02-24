extends Area3D


# Called when the node enters the scene tree for the first time.
var angle = 90
var activate = false
var turn = false
func _rotate_camera_on_body_entered(body):
	#print("body: ",body.name)
	if (body.name == "Player_Character" and not activate) :
		
		if not turn:
			print("turn")
			await get_tree().create_timer(0.05).timeout
			body.rotate(Vector3(0,1,0),deg_to_rad(angle))
			turn = true
		else:
			print("unturn")
			await get_tree().create_timer(0.07).timeout
			body.rotate(Vector3(0,1,0),deg_to_rad(-angle))
			turn = false
		activate = true


func _rotate_camera_on_body_exited(body):
	print("Player Exited")
	activate = false
