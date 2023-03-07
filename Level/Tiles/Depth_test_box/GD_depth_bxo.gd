extends Area3D


func _on_body_entered(body):
	print(body.name)
	if (body.name == "Player_Character") :
			print(body.name)
			body.set_draw_flag(false)

func _on_body_exited(body):
	if (body.name == "Player_Character") :
			body.set_draw_flag(true)
