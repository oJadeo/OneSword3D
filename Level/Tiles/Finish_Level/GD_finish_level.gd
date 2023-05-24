extends Node3D
@export var level = 1

func _on_area_3d_body_entered(body):
	if (body.name == "Player_Character") :
		body.canvas_layer.showFinLev(level)
