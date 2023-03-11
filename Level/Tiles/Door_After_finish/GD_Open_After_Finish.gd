extends Node3D

@export var move:Vector3=Vector3.ZERO
var start_pos
var target_pos
func _ready():
	start_pos = global_position
	target_pos = start_pos
	deactivate()
	
func _process(delta):
	if target_pos != global_position:
		global_position = lerp(global_position,target_pos,delta)
func activate():
	target_pos = start_pos+move
func deactivate():
	global_position = start_pos
	target_pos = start_pos
