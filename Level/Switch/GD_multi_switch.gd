extends Node3D

@onready var animationPlayer = $AnimationPlayer

var isOn = false

func _ready():
	animationPlayer.play("Idle_off")


func _process(delta):
	pass


func _on_area_3d_body_entered(body):
	if body is Bullet and not isOn:
		animationPlayer.play("Idle_wait")
		isOn = true
		body.queue_free()
		

func complete():
	animationPlayer.play("complete")
	
func onCompleteFinished():
	animationPlayer.play("Idle_complete")

func reset():
	animationPlayer.play("Idle_off")
	isOn = false
