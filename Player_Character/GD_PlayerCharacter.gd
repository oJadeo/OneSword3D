extends CharacterBody3D
class_name PlayerCharacter


@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")
@onready var state = $StateManager
@onready var shooting = $Shooting

var view_size:Vector2 = Vector2(640,360)
var target_hook:Vector3 = Vector3.ZERO
var go_to_hook:bool = false
var can_shoot:bool = true
var can_double_jump = true
func _ready() -> void:
	#Initilize State machine with reference to player
	state.init(self,animationState)
	shooting.init(self)

# input variable
var input_frame = {
	"direction" : Vector2.ZERO,
	"shoot_direction" : Vector2.ZERO,
	"attack" : false,
	"charge" : false,
	"hook" : false,
	"jump" : false,
	"just_jump" : false,
	"dash" : false,
	"wall_run":false,
	"just_wall_run":false,
	}
#take all input into input dict
func handle_input():
	input_frame["direction"] = Vector2(Input.get_axis("Move_Left", "Move_Right"),Input.get_axis("Move_Up", "Move_Down")) 
	input_frame["direction"] = input_frame["direction"] if input_frame["direction"].length() <=1 else input_frame["direction"].normalized()
	input_frame["direction"] = input_frame["direction"] if input_frame["direction"].length() >0.05 else Vector2.ZERO
	input_frame["attack"] = Input.is_action_just_released("Attack")
	input_frame["charge"] = Input.is_action_just_pressed("Attack")
	input_frame["jump"] = Input.is_action_pressed("Jump")
	input_frame["just_jump"] = Input.is_action_just_pressed("Jump")
	input_frame["wall_run"]  = Input.is_action_pressed("WallRun")
	input_frame["just_wall_run"] = Input.is_action_just_pressed("WallRun")
	input_frame["hook"] = Input.is_action_just_pressed("Hook")
	input_frame["shoot_direction"] = Vector2(Input.get_axis("Shoot_Left", "Shoot_Right"),Input.get_axis("Shoot_Up", "Shoot_Down")) 
	input_frame["shoot_direction"] = input_frame["shoot_direction"] if input_frame["shoot_direction"].length() <=1 else input_frame["shoot_direction"].normalized()
	input_frame["shoot_direction"] = input_frame["shoot_direction"] if input_frame["shoot_direction"].length() >0.05 else Vector2.ZERO
	var character_rotation = get_rotation()
	Global.cal_camera_direction(rad_to_deg(character_rotation[1]))
	animationTree.set("parameters/Run/blend_position",input_frame["direction"])
	animationTree.set("parameters/Idle/blend_position",input_frame["direction"])
	animationTree.set("parameters/Fall/blend_position",input_frame["direction"])
	animationTree.set("parameters/Jump/blend_position",input_frame["direction"])
	animationTree.set("parameters/Wall_run_left/blend_position",Global.cal_sprite_direction(velocity))
	animationTree.set("parameters/Wall_run_right/blend_position",Global.cal_sprite_direction(velocity))
	
	if input_frame["wall_run"]:
		is_wall['left'] = check_wall(Vector3(-WALL_CHECK_RANGE,0,0))
		is_wall['right'] = check_wall(Vector3(WALL_CHECK_RANGE,0,0))
		is_wall['up'] = check_wall(Vector3(0,0,-WALL_CHECK_RANGE))
		selected_wall = select_wall()
		
	if input_frame["hook"]:
		go_to_hook = shooting.hook()
		print(go_to_hook)
func _process(delta: float) -> void:
	handle_input()
	handle_rotation(delta)
	check_ledge()
	state.process(delta,input_frame)
	shooting.process(delta,input_frame)

# For Rotaion Camera
@export var tar_rot :float = 0
func set_target_rotation(new_tar_rot):
	tar_rot = new_tar_rot
func handle_rotation(delta):
	rotation.y = lerp_angle(rotation.y,tar_rot,5.0*delta)
	$Shooting.rotation.y = - rotation.y 
#Coyote Timer
@onready var coyote_timer = $Timer/CoyoteTimer
#Jump Buffer
@onready var jump_buffer = $Timer/jumpBufferTimer

var direction:Vector3
func cal_direction(input_direction:Vector2):
	if input_direction == Vector2.ZERO:
		return Vector3.ZERO
	var input_pos = input_direction.normalized()*view_size.y/2 + view_size/2
	var camera = get_tree().root.get_camera_3d()
	var rayOrigin = camera.project_ray_origin(input_pos)
	var ray_Vector = camera.project_ray_normal(input_pos)
	var amount:float = (global_position.y - rayOrigin.y)/ray_Vector.y
	var target_pos:Vector3 = rayOrigin + ray_Vector * amount
	direction = (target_pos - global_position).normalized()
	return direction

# For depthBox to behind box
func set_draw_flag(draw):
	$Sprite3d.set_draw_flag(3,draw)

var is_wall_runable = true
@export var WALL_CHECK_RANGE = 0.5
@onready var ray = $WallRun/RayCast3D
var is_wall= {'left':null,'right':null,'up':null}
var selected_wall
var wall_run_jumping:Vector3
func check_wall(dir):
	ray.set_target_position(dir)
	ray.force_raycast_update()
	var collided = ray.get_collider()
	if collided is StaticBody3D or collided is GridMap:
		return [collided,(ray.get_collision_point()-get_global_position()).length(),ray.get_collision_normal()]
	return null
func select_wall():
	var result = null
	if is_wall['left']:
		result = is_wall['left']
	if is_wall['right']:
		if result:
			result = is_wall['right'] if is_wall['right'][1] < result[1] else result
		else:
			result = is_wall['right']
	if is_wall['up']:
		if result:
			result = is_wall['up'] if is_wall['up'][1] < result[1] else result
		else:
			result = is_wall['up']
	return result
	
@onready var ray_wall = $Ledge/CheckWall
@onready var ray_top = $Ledge/CheckTop
@onready var ray_body = $Ledge/CheckBody
@export var LEDGE_CHECK_RANGE = 0.25
@export var LEDGE_CHECK_HEIGHT = 0.3
var ledge_pos:Vector3
func check_ledge()->bool:
	if direction!= Vector3.ZERO:
		ray_wall.set_position(Vector3(direction.x*LEDGE_CHECK_RANGE,LEDGE_CHECK_HEIGHT,direction.z*LEDGE_CHECK_RANGE))
		ray_wall.set_target_position(Vector3(0,-1,0))
		ray_wall.force_raycast_update()
		var is_wall_collided = ray_wall.get_collider()
		ray_top.set_position(Vector3(0,LEDGE_CHECK_HEIGHT,0))
		ray_top.set_target_position(direction*LEDGE_CHECK_RANGE)
		ray_top.force_raycast_update()
		var is_top_collided = ray_top.get_collider()
		ray_body.set_position(Vector3(0,0.1,0))
		ray_body.set_target_position(direction*LEDGE_CHECK_RANGE)
		ray_body.force_raycast_update()
		var is_body_collided = ray_body.get_collider()
		if is_wall_collided is GridMap and not is_top_collided is GridMap and is_body_collided is GridMap:
			ledge_pos = ray_body.get_collision_point() - Vector3(0,0.1,0)
			return true
	return false

func _on_hurt_box_area_entered(area: Area3D) -> void:
	if "Hitbox" not in area.name :
		return
	if area.get_parent().friendly:
		return
	area.get_parent().queue_free()
	respawn()

@onready var playerSpawnPoint = $"../playerSpawnPoint"
func respawn():
	set_position(playerSpawnPoint.global_position)
	velocity = Vector3.ZERO
	state.respawn()
	get_tree().call_group("respawn","respawn")
