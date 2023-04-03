extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

#Animation variable
@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")

var input_frame:Dictionary = {
	"direction" : Vector2.ZERO,
	"angle" : Vector2.ZERO,
	}
func _physics_process(delta: float) -> void:
	input_frame["direction"] = Vector2(Input.get_axis("Move_Left", "Move_Right"),Input.get_axis("Move_Up", "Move_Down")) 
	input_frame["direction"] = input_frame["direction"] if input_frame["direction"].length() <=1 else input_frame["direction"].normalized()
	input_frame["direction"] = input_frame["direction"] if input_frame["direction"].length() >0.05 else Vector2.ZERO
	input_frame["angle"] = Vector2(Input.get_axis("Angle_Left", "Angle_Right"),Input.get_axis("Angle_Up", "Angle_Down")) 
	input_frame["angle"] = input_frame["angle"] if input_frame["angle"].length() <=1 else input_frame["angle"].normalized()
	input_frame["angle"] = input_frame["angle"] if input_frame["angle"].length() >0.05 else Vector2.ZERO
	animationTree.set("parameters/Idle/blend_position",input_frame["direction"])
	animationTree.set("parameters/Idle/0/blend_position",input_frame["angle"])
	animationTree.set("parameters/Idle/1/blend_position",input_frame["angle"])
	animationTree.set("parameters/Idle/2/blend_position",input_frame["angle"])
	animationTree.set("parameters/Idle/3/blend_position",input_frame["angle"])
	animationState.travel("Idle")
