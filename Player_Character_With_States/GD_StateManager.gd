extends Node3D


var current_state: BaseState
@onready var starting_state = $Idle

func change_state(new_state: BaseState)-> void:
	if current_state:
		current_state.exit()
		
	current_state = new_state
	current_state.enter()
	
func init(player:PlayerCharacterWithStates,animationState) -> void:
	for child in get_children():
		child.player = player
		child.animationState = animationState
	change_state(starting_state)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta: float,input_frame:Dictionary) -> void:
	var new_state = current_state.process(delta,input_frame)
	if new_state:
		change_state(new_state)
		
