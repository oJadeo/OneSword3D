extends Area3D

@onready var newSpawnPoint = $newSpawnPoint
var isSet = false




func _on_s_set_spawn_body_entered(body):
	if (body.name == "Player_Character" and not isSet) :
		#print(body.playerSpawnPoint.global_position)
		body.playerSpawnPoint = newSpawnPoint
		#print(body.playerSpawnPoint.global_position)
		isSet = true

