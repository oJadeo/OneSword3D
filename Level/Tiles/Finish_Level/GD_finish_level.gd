extends Node3D


func _on_area_3d_body_entered(body):
	if (body.name == "Player_Character") :
		body.canvas_layer.showFinLev()
