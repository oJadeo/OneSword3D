extends Area3D



func _on_danger_area_body_entered(body):
	if (body.name == "Player_Character") :
		body.respawn()
