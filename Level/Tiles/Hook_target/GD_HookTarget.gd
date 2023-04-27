extends Node3D


@onready var sprite = $Sprite3D
@onready var hookCollision = $Area3D/CollisionShape3D
@onready var area = $Area3D

var check = false




func _ready():
	pass



func _process(delta):
	if check:
		sprite.visible = false
		hookCollision.disabled = true 
	else:
		sprite.visible = true
		hookCollision.disabled = false
		

func activate():
	check = false

func deactivate():
	check = true
