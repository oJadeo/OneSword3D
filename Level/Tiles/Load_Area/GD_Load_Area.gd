extends Area3D
class_name Transporter
@onready var collision = $CollisionShape3D
@onready var sprite = $Sprite3D
@export var default_on :bool = false
func _ready():
	deactivate()
	if default_on:
		activate()

func _on_body_entered(body):
	print("Enter")
	if body is PlayerCharacter :
		var levelManager = get_tree().get_root().get_node("LevelManager")
		GdLevelGlobal.current_level += 1
		levelManager.transitionScreen.transition()

func activate():
	collision.disabled = false
	sprite.visible = true

func deactivate():
	collision.disabled = true
	sprite.visible = false
