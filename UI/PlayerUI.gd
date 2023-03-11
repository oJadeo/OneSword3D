extends Node

@onready var blockProgressBar = $Control/BlockLabel/ProgressBar
@onready var firstDashCharge = $Control/DashCharge/firstDashCharge
@onready var secondDashCharge = $Control/DashCharge/secondDashCharge
@onready var thirdDashCharge = $Control/DashCharge/thirdDashCharge
# Called when the node enters the scene tree for the first time.
@onready var menu = $MenuButton
@onready var MainMenu = $"Main Menu"
@onready var LevelSelect = $"Level Select"
@onready var closeMenu = $Close
@onready var ExitGame = $"Exit Game"
@onready var pauseCanvas = $ColorRect
func _ready():
	hidePauseMenu()
	
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


func hidePauseMenu():
	menu.show()
	MainMenu.hide()
	LevelSelect.hide()
	closeMenu.hide()
	ExitGame.hide()
	pauseCanvas.hide()

func showPauseMenu():
	menu.hide()
	MainMenu.show()
	LevelSelect.show()
	closeMenu.show()
	ExitGame.show()
	pauseCanvas.show()

func _on_menu_button_pressed():
	get_tree().paused = true
	showPauseMenu()


func _on_close_pressed():
	hidePauseMenu()
	get_tree().paused = false


func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://Menu/S_Main_Menu.tscn")
	get_tree().paused = false

func _on_level_select_pressed():
	get_tree().change_scene_to_file("res://Menu/S_Level_Select.tscn")
	get_tree().paused = false


func _on_exit_game_pressed():
	get_tree().paused = false
	get_tree().quit()
