extends Node3D
@export var S_Tutorial: Resource
@export var S_level_1_A: Resource
@export var S_level_1_B: Resource
@export var S_level_1_C: Resource
@export var S_level_2: Resource
@export var S_level_3_A: Resource
@export var S_level_3_B: Resource
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

