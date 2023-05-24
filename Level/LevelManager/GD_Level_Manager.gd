extends Node3D
@export var S_Tutorial: Resource
@export var S_level_1: Resource
@export var S_level_2: Resource
@onready var transitionScreen = $TransitionScreen
@onready var currentScene = $currentScene

func _on_transition_screen_transitioned():
	currentScene.get_child(0).queue_free()
	if (GdLevelGlobal.current_level == -1):
		currentScene.add_child(S_Tutorial.instantiate())
		
	if (GdLevelGlobal.current_level == 0):
		currentScene.add_child(S_level_1.instantiate())
		
	if (GdLevelGlobal.current_level == 1):
		currentScene.add_child(S_level_2.instantiate())

