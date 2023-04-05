extends Node3D

@onready var animationPlayer = $AnimationPlayer
@onready var timer = $Timer

@export var activateTimer = false
@export var timerDuration = 0
@export var activator : NodePath

var isOn = false


func _ready():
	animationPlayer.play("Idle_off")
	timer.wait_time = timerDuration



func _process(delta):
	pass


		
func _on_area_3d_body_entered(body):
	if body is Bullet and not isOn:
		switchActivate()
	elif body is Bullet and isOn:
		switchDeactivate()

func _on_timer_timeout():
	switchDeactivate()

func switchDeactivate():
	if activateTimer:
			timer.stop()
	animationPlayer.play("Deactivate")
	isOn = false
	if activator:
		var node = get_node(activator)
		if node and node.has_method('deactivate'):
			node.deactivate()

func switchActivate():
	animationPlayer.play("Activate")
	isOn = true
	if activator:
		var node = get_node(activator)
		if node and node.has_method('activate'):
			node.activate()
	if activateTimer:
		timer.start()

func onActivationFinished():
	animationPlayer.play("Idle_on")

func OnDeactivationFinished():
	animationPlayer.play("Deactivate")
