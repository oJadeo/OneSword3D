extends CanvasLayer

var current = 0
@onready var buttonList = $ButtonList

func _ready():
	GdLevelGlobal.current_level = -1
	buttonList.get_children()[current].grab_focus()

func _process(delta):
	#if Input.is_action_just_pressed("Move_Down") or Input.is_action_just_pressed("Move_Up") :
		#if Input.is_action_just_pressed("Move_Down") :
			#current += 1
		#elif  Input.is_action_just_pressed("Move_Up") :
			#current -= 1
		#current = current%5
		#buttonList.get_children()[current].grab_focus()
	#if Input.is_action_just_pressed("Menu_Accept") :
		#buttonList.get_children()[current].emit_signal("pressed")
	if Input.is_action_just_pressed("Menu_Back"):
		buttonList.get_children()[4].emit_signal("pressed")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Menu/S_Main_Menu.tscn")

func _on_tutorial_pressed():
	get_tree().change_scene_to_file("res://Level/LevelManager/S_Level_Manager.tscn")

func _on_level_1_pressed():
	GdLevelGlobal.current_level = 0
	get_tree().change_scene_to_file("res://Level/LevelManager/S_Level_Manager.tscn")

func _on_level_2_pressed():
	GdLevelGlobal.current_level = 1
	get_tree().change_scene_to_file("res://Level/LevelManager/S_Level_Manager.tscn")

