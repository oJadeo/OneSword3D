extends Area3D


func _on_body_entered(body):
	if (body.name == "Player_Character") :
			body.set_draw_flag(false)

func _on_body_exited(body):
	if (body.name == "Player_Character") :
			body.set_draw_flag(true)

