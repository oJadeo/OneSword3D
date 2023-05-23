extends Node

# Called when the node enters the scene tree for the first time.
@onready var buttonList = $ButtonList
@onready var pauseCanvas = $ColorRect

@onready var timer_main = $timerMain
@onready var conclude = $Conclude

@onready var timer_conclude = $Conclude/timerConclude

var current = 0
var menuOpen = false
var levelFin = false

func _ready():
	hidePauseMenu()
	conclude.hide()

func _process(delta):
	if levelFin:
		get_tree().paused = true
		timer_main.stop()
		buttonList.hide()
		pauseCanvas.show()
		conclude.show()
		timer_main.hide()
		var cens = fmod(timer_main.time,1) * 100
		var secs = fmod(timer_main.time,60)
		var mins = fmod(timer_main.time,60*60) /60 
		var hrs = fmod(fmod(timer_main.time,3600*60)/3600, 24)
		var time_passed
		if hrs > 1 :
			time_passed = "%02d :%02d : %02d : %02d" %[hrs,mins,secs,cens]
		else:
			time_passed = "%02d : %02d : %02d" %[mins,secs,cens]
		timer_conclude.text = "Time used: "+time_passed
	if not levelFin :
		if Input.is_action_just_pressed("Menu_Toggle") :
			menuOpen = !menuOpen
			get_tree().paused = menuOpen
			if menuOpen :
				showPauseMenu()
			else :
				hidePauseMenu()
			
	#elif Input.is_action_just_pressed("Move_Down") or Input.is_action_just_pressed("Move_Up") and menuOpen :
		#if Input.is_action_just_pressed("Move_Down") :
			#current += 1
		#elif  Input.is_action_just_pressed("Move_Up") :
			#current -= 1
		#current = current%4
		#buttonList.get_children()[current].grab_focus()
		
	#elif Input.is_action_just_pressed("Menu_Accept") and menuOpen :
		#buttonList.get_children()[current].emit_signal("pressed")
		
	#elif Input.is_action_just_pressed("Menu_Back") and menuOpen :
		#buttonList.get_children()[0].emit_signal("pressed")
	

func hidePauseMenu():
	timer_main.start()
	buttonList.hide()
	pauseCanvas.hide()
	
func showPauseMenu():
	timer_main.stop()
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

func showFinLev(level):
	levelFin = true
	if level == 1 :
		if (timer_main.time < Global.level1_highScore) or (Global.level1_highScore == 0) :
			Global.level1_highScore = timer_main.time
			
	elif  level == 2 : 
		if (timer_main.time < Global.level2_highScore) or (Global.level2_highScore == 0) :
			Global.level2_highScore = timer_main.time

func _on_main_pressed():
	_on_main_menu_pressed()


func _on_lavel_pressed():
	_on_level_select_pressed()


func _on_quit_pressed():
	_on_exit_game_pressed()
