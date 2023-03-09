extends Area3D



func _on_danger_area_body_entered(body):
	if (body.name == "Player_Character") :
		body.respawn()
	if (body is CharacterBody3D and body.name != "Player_Character"):
		body.queue_free()
