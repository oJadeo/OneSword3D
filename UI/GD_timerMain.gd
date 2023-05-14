extends Node2D

var time =  0
var timer_on = false

@onready var label = $Label


# Called when the node enters the scene tree for the first time.
func _ready():
	start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timer_on :
		time += delta
	var cens = fmod(time,1) * 100
	var secs = fmod(time,60)
	var mins = fmod(time,60*60) /60 
	var hrs = fmod(fmod(time,3600*60)/3600, 24)
	var time_passed
	if hrs > 1 :
		time_passed = "%02d :%02d : %02d : %02d" %[hrs,mins,secs,cens]
	else:
		time_passed = "%02d : %02d : %02d" %[mins,secs,cens]
	label.text = time_passed

func start() :
	timer_on = true
	
func stop():
	timer_on = false

func reset():
	time = 0
