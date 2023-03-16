extends Area3D

@onready var newSpawnPoint = $newSpawnPoint
var isSet = false
@onready var isSetSprite = $Sprite3D
@onready var isNotSetSprite = $Sprite3D2

func _ready():
	isSetSprite.visible = false
	isNotSetSprite.visible = true
	

func _on_s_set_spawn_body_entered(body):
	#print(body)
	if (body.name == "Player_Character" and not isSet) :
		#print(body.playerSpawnPoint.global_position)
		body.playerSpawnPoint = newSpawnPoint
		#print(body.playerSpawnPoint.global_position)
		isSet = true
		isSetSprite.visible = true
		isNotSetSprite.visible = false
