extends Area3D

@export var scene = "rangeArena"
signal loadNewArea

func _on_body_entered(body):
	if (body.name == "Player_Character") :
		emit_signal("loadNewArea")
