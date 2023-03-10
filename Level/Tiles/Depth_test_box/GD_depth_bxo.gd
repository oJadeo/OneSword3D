extends Area3D


func _on_body_entered(body):
	if body is CharacterBody3D :
		body.get_node("Sprite3d").set_draw_flag(3,false)

func _on_body_exited(body):
	if body is CharacterBody3D :
		body.get_node("Sprite3d").set_draw_flag(3,true)

