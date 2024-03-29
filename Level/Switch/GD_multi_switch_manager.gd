extends Node3D



var multiSwitchList = []
var activated = false
var check = true
var firstActivated = false




@export var activateTimer : bool
@export var timerDuration : float

@onready var activate_children = $activateChildren
@onready var timer = $Timer
@onready var deactivate_children = $deactivateChildren
@onready var timerAudio = $Timer2
@onready var timeoutAudio = $Timeout
@onready var completeAudio = $Complete
func _ready():
	timer.wait_time = timerDuration
	if activate_children.get_child_count() != 0:
		for e in activate_children.get_children():
			if e and e.has_method('deactivate'):
				e.deactivate()



func _process(delta):
		check = true
		for child in get_children():
			if not child.get("isOn") == null:
				if not child.isOn:
					check = false
				elif child.isOn and not firstActivated and activateTimer:
					firstActivated = true
					timer.start()
					timerAudio.play()
		if check and not activated:
			activated = true
			completeAllSwitch()		

func completeAllSwitch():	
	completeAudio.play()
	timerAudio.stop()
	timer.stop()
	for child in get_children():
		if child.has_method("complete"):
			child.complete()
	if activate_children.get_child_count() != 0:
		for e in activate_children.get_children():
			if e and e.has_method('activate'):
				e.activate()
				
	if deactivate_children.get_child_count() != 0:
		for e in deactivate_children.get_children():
			if e and e.has_method('deactivate'):
				e.activate()
				
		


func _on_timer_timeout():
	timerAudio.stop()
	timeoutAudio.play()
	firstActivated = false
	if not activated:
		for child in get_children():
			if child.has_method("reset"):
				child.reset()
