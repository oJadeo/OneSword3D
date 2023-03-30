extends Node

enum State{
	Null,
	Idle,
	Run,
	Air,
	WallRun,
	WallClimb,
	Ledge
}

@export var animation_name:String

var player:PlayerCharacterWithStates

func enter() -> void:
	pass
	
func exit() -> void:
	pass
	
func input(event: InputEvent) -> State:
	return State.Null

func process(delta: float) -> State:
	return State.Null
	
func physics_process(delta: float) -> State:
	return State.Null
