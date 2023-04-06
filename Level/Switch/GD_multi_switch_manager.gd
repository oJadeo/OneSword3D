extends Node3D


var multiSwitchList = []
var activated = false
var check = true
var firstActivated = false

@onready var timer = $Timer

@export var activator : NodePath
@export var activateTimer : bool
@export var timerDuration : float

func _ready():
	timer.wait_time = timerDuration



func _process(delta):
	check = true
	for child in get_children():
		if not child.get("isOn") == null:
			if not child.isOn:
				check = false
			elif child.isOn and not firstActivated and activateTimer:
				firstActivated = true
				timer.start()
	if check and not activated:
		activated = true
		completeAllSwitch()

func completeAllSwitch():
	for child in get_children():
		if child.has_method("complete"):
			child.complete()
	print("dai leaw")
	if activated and activator:
		var node = get_node(activator)
		if node and node.has_method('activate'):
			node.activate()
	
				
		


func _on_timer_timeout():
	timer.stop()
	firstActivated = false
	if not activated:
		for child in get_children():
			if child.has_method("reset"):
				child.reset()
	
