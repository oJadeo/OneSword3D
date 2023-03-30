extends CharacterBody3D
class_name PlayerCharacterWithStates


@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")
@onready var state = $StateManager

func _ready() -> void:
	#Initilize State machine with reference to player
	state.init(self,animationState)

func _physics_process(delta):
	handle_rotation(delta)

# input variable
var input_frame = {
	"direction" : Vector2.ZERO,
	"jump" : false,
	"block" : false,
	"dash" : false,
	"wall_run":false,
	"just_jump":true
	}
#take all input into input dict
func handle_input():
	input_frame["direction"] = Vector2(Input.get_axis("Move_Left", "Move_Right"),Input.get_axis("Move_Up", "Move_Down")) 
	input_frame["direction"] = input_frame["direction"] if input_frame["direction"].length() <=1 else input_frame["direction"].normalized()
	input_frame["direction"] = input_frame["direction"] if input_frame["direction"].length() >0.05 else Vector2.ZERO
	input_frame["attack"] = Input.is_action_just_pressed("Attack")
	input_frame["block"] = Input.is_action_pressed("Block")
	input_frame["jump"] = Input.is_action_pressed("Jump")
	input_frame["just_jump"] = Input.is_action_just_pressed("Jump")
	input_frame["dash"] = Input.is_action_pressed("Dash")
	input_frame["wall_run"]  = Input.is_action_pressed("WallRun")
	var character_rotation = get_rotation()
	Global.cal_camera_direction(rad_to_deg(character_rotation[1]))
	animationTree.set("parameters/Run/blend_position",input_frame["direction"])
	animationTree.set("parameters/Idle/blend_position",input_frame["direction"])
	animationTree.set("parameters/Dash/blend_position",input_frame["direction"])
	animationTree.set("parameters/Fall/blend_position",input_frame["direction"])
	animationTree.set("parameters/Jump/blend_position",input_frame["direction"])
	animationTree.set("parameters/Wall_run_left/blend_position",Global.cal_sprite_direction(velocity))
	animationTree.set("parameters/Wall_run_right/blend_position",Global.cal_sprite_direction(velocity))

func _process(delta: float) -> void:
	handle_input()
	state.process(delta,input_frame)

# For Rotaion Camera
@export var tar_rot :float = 0
func set_target_rotation(new_tar_rot):
	tar_rot = new_tar_rot
func handle_rotation(delta):
	rotation.y = lerp_angle(rotation.y,tar_rot,5.0*delta)

#Coyote Timer
@onready var coyote_timer = $Timer/CoyoteTimer
#Jump Buffer
@onready var jump_buffer = $Timer/jumpBufferTimer

# For depthBox to behind box
func set_draw_flag(draw):
	$Sprite3d.set_draw_flag(3,draw)
