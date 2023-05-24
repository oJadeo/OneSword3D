extends Node3D

@onready var animationPlayer = $AnimationPlayer
@onready var timer = $Timer
@onready var activate_children = $activateChildren
@onready var deactivate_children = $deactivateChildren

@export var activateTimer = false
@export var timerDuration = 0
@onready var onAudio = $Activate
@onready var offAudio = $Deactivate
@onready var timerAudio = $Timer2
var isOn = false


func _ready():
	switchDeactivate()
	animationPlayer.play("Idle_off")
	timer.wait_time = timerDuration



func _process(delta):
	pass


		
func _on_area_3d_body_entered(body):
	if body is Bullet and not isOn:
		switchActivate()
		body.queue_free()
	elif body is Bullet and isOn:
		switchDeactivate()
		body.queue_free()

func _on_timer_timeout():
	switchDeactivate()

func switchDeactivate():
	if activateTimer:
			timer.stop()
			timerAudio.stop()
	animationPlayer.play("Deactivate")
	offAudio.play()
	isOn = false
	if activate_children.get_child_count() != 0:
		for e in activate_children.get_children():
			if e and e.has_method('deactivate'):
				e.deactivate()
				
	if deactivate_children.get_child_count() != 0:
		for e in deactivate_children.get_children():
			if e and e.has_method('activate'):
				e.activate()

func switchActivate():
	animationPlayer.play("Activate")
	onAudio.play()
	isOn = true
	if activate_children.get_child_count() != 0:
		for e in activate_children.get_children():
			if e and e.has_method('activate'):
				e.activate()
	
	if deactivate_children.get_child_count() != 0:
		for e in deactivate_children.get_children():
			if e and e.has_method('deactivate'):
				e.deactivate()
				
	if activateTimer:
		timer.start()
		timerAudio.play()
	
func onActivationFinished():
	animationPlayer.play("Idle_on")
	

func OnDeactivationFinished():
	animationPlayer.play("Deactivate")
	
