extends Area3D

@export var file:JSON
@onready var dialogue = $Dialogue

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerCharacter :
		dialogue.start(file)


func _on_body_exited(body: Node3D) -> void:
	pass # Replace with function body.
