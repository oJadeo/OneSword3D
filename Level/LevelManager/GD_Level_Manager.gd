extends Node3D

const S_Tutorial = preload("res://Level/Level_Scene/S_tutorial_2.tscn")
const S_level_1_A = preload("res://Level/Level_Scene/S_level1_A.tscn")
const S_level_1_B = preload("res://Level/Level_Scene/S_Level_1_B.tscn")
const S_level_1_C = preload("res://Level/Level_Scene/S_Level_1_C.tscn")
const S_level_2 = preload("res://Level/Level_Scene/S_Level_2.tscn")
const S_level_3_A = preload("res://Level/Level_Scene/S_Level_3_A.tscn")
const S_level_3_B = preload("res://Level/Level_Scene/S_Level_3_B.tscn")
@onready var transitionScreen = $TransitionScreen
@onready var currentScene = $currentScene

func _on_transition_screen_transitioned():
	currentScene.get_child(0).queue_free()
	if (GdLevelGlobal.current_level == -1):
		currentScene.add_child(S_Tutorial.instantiate())
		
	if (GdLevelGlobal.current_level == 0):
		currentScene.add_child(S_level_1_A.instantiate())
		
	if (GdLevelGlobal.current_level == 1):
		currentScene.add_child(S_level_1_B.instantiate())
	if (GdLevelGlobal.current_level == 2):
		currentScene.add_child(S_level_1_C.instantiate())
	if (GdLevelGlobal.current_level == 3):
		currentScene.add_child(S_level_2.instantiate())
		
	if (GdLevelGlobal.current_level == 4):
		currentScene.add_child(S_level_3_A.instantiate())
		
	if (GdLevelGlobal.current_level == 5):
		currentScene.add_child(S_level_3_B.instantiate())

