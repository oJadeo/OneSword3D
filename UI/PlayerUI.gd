extends Node

@onready var blockProgressBar = $Control/BlockLabel/ProgressBar
@onready var firstDashCharge = $Control/DashCharge/firstDashCharge
@onready var secondDashCharge = $Control/DashCharge/secondDashCharge
@onready var thirdDashCharge = $Control/DashCharge/thirdDashCharge
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_player_character_blockbar_changed(blockBar):
	blockProgressBar.value = blockBar

func _on_player_character_dash_charge_changed(dash_charge):
	if dash_charge == 0 :
		firstDashCharge.value = 0
		secondDashCharge.value = 0
		thirdDashCharge.value = 0
	elif dash_charge == 1 :
		firstDashCharge.value = 100
		secondDashCharge.value = 0
		thirdDashCharge.value = 0
	elif dash_charge == 2 :
		firstDashCharge.value = 100
		secondDashCharge.value = 100
		thirdDashCharge.value = 0
	else :
		firstDashCharge.value = 100
		secondDashCharge.value = 100
		thirdDashCharge.value = 100.
