extends Node

@onready var blockProgressBar = $Control/BlockLabel/ProgressBar
@onready var firstDashCharge = $Control/DashCharge/firstDashCharge
@onready var secondDashCharge = $Control/DashCharge/secondDashCharge
@onready var thirdDashCharge = $Control/DashCharge/thirdDashCharge
# Called when the node enters the scene tree for the first time.
@onready var buttonList = $ButtonList
@onready var pauseCanvas = $ColorRect

var current = 0
var menuOpen = false

func _ready():
	hidePauseMenu()

func _process(delta):
	if Input.is_action_just_pressed("Menu_Toggle") :
		menuOpen = !menuOpen
		get_tree().paused = menuOpen
		if menuOpen :
			showPauseMenu()
		else :
			hidePauseMenu()
			
	elif Input.is_action_just_pressed("Move_Down") or Input.is_action_just_pressed("Move_Up") and menuOpen :
		if Input.is_action_just_pressed("Move_Down") :
			current += 1
		elif  Input.is_action_just_pressed("Move_Up") :
			current -= 1
		current = current%4
		buttonList.get_children()[current].grab_focus()
		
	elif Input.is_action_just_pressed("Menu_Accept") and menuOpen :
		buttonList.get_children()[current].emit_signal("pressed")
		
	elif Input.is_action_just_pressed("Menu_Back") and menuOpen :
		buttonList.get_children()[0].emit_signal("pressed")
	

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


func hidePauseMenu():
	buttonList.hide()
	pauseCanvas.hide()

func showPauseMenu():
	buttonList.show()
	pauseCanvas.show()
	buttonList.get_children()[current].grab_focus()

func _on_continue_pressed():
	get_tree().paused = false
	hidePauseMenu()

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://Menu/S_Main_Menu.tscn")
	get_tree().paused = false

func _on_level_select_pressed():
	get_tree().change_scene_to_file("res://Menu/S_Level_Select.tscn")
	get_tree().paused = false

func _on_exit_game_pressed():
	get_tree().paused = false
	get_tree().quit()


