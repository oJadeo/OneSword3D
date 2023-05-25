extends Node3D

@onready var animationPlayer = $AnimationPlayer
@onready var timer = $Timer
@onready var activate_children = $children

@export var timerDuration = 3
@onready var onAudio = $Activate
@onready var timerAudio = $Timer2
@onready var timeoutAudio = $Timeout
var isOn = false

func _ready():
	animationPlayer.play("Idle")
	if activate_children.get_child_count() != 0:
		for e in activate_children.get_children():
			if e and e.has_method('deactivate'):
				e.deactivate()	
	timer.wait_time = timerDuration



func _process(delta):
	pass


func _on_area_3d_body_entered(body):
	if body is Bullet:
		animationPlayer.play("Idle_wait")
		if activate_children.get_child_count() != 0:
			for e in activate_children.get_children():
				if e and e.has_method('activate'):
					e.activate()
		timer.start()
		onAudio.play()
		timerAudio.play()
		body.queue_free()


func _on_timer_timeout():
		animationPlayer.play("Idle")
		timerAudio.stop()
		timeoutAudio.play()
		if activate_children.get_child_count() != 0:
			for e in activate_children.get_children():
				if e and e.has_method('deactivate'):
					e.deactivate()	
