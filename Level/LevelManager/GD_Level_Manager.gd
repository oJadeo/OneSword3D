extends Node3D

const S_Test_Level = preload("res://Level/S_Test_Level.tscn")
const S_level_3_B = preload("res://Level/Level_Scene/S_Level_3_B.tscn")
@onready var transitionScreen = $TransitionScreen
@onready var currentScene = $currentScene


func _on_transition_screen_transitioned():
	var temp = currentScene.get_child(0).name
	currentScene.get_child(0).queue_free()
	if (temp == "S_tutorial"):
		currentScene.add_child(S_Test_Level.instantiate())
	if (temp == "S_level_3_A"):
		currentScene.add_child(S_level_3_B.instantiate())



func _on_tutorial_load_area_1_load_new_area():
	transitionScreen.transition()


func _on_area_3d_load_new_area():
	transitionScreen.transition()
