extends Node3D
class_name BaseState

var player:PlayerCharacter
var animationTree
var animationState

func enter() -> void:
	pass
	
func exit() -> void:
	pass
	
func process(delta: float,input_frame:Dictionary) -> BaseState:
	return null
	
