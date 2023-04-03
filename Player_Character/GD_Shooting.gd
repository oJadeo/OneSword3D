extends Node3D

@export var bullet: Resource
@export var charge_angles:PackedInt32Array


@onready var shootTimer = $shootTimer
@onready var chargeTimer = $chargeTimer
var bullet_direction = Vector3.ZERO
var reloading:bool = false
var isShootMouse:bool = false
var player:PlayerCharacter
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.
func init(player:PlayerCharacter) -> void:
	self.player = player
	
func spawn_bullet():
	chargeTimer.stop()
	var new_bullet = bullet.instantiate()
	var bulletDirection_x = bullet_direction.x 
	var bulletDirection_z = bullet_direction.z
	add_child(new_bullet)
	new_bullet.init(bulletDirection_x,0,bulletDirection_z,0,0,2)
	shootTimer.start()
func spawn_charge_bullet():
	chargeTimer.stop()
	var bullet_vec = Vector2(bullet_direction.x,bullet_direction.z)
	for angle in charge_angles : 
		var new_bullet = bullet.instantiate()
		var new_bullet_vec = bullet_vec.rotated(deg_to_rad(angle))
		add_child(new_bullet)
		new_bullet.init(new_bullet_vec.x,0,new_bullet_vec.y,0,0,2)
	shootTimer.start()
func process(delta: float,input_frame:Dictionary) -> void:
	cal_bullet_dir(input_frame)
	#Handle Charge
	if input_frame["charge"] :
		chargeTimer.start()

	if input_frame["attack"] and shootTimer.is_stopped():
		if (chargeTimer.time_left > 0):
			spawn_bullet()
func _on_charge_timer_timeout():
	spawn_charge_bullet()

func cal_bullet_dir(input_frame:Dictionary):
	if isShootMouse:
		var mousePos = get_viewport().get_mouse_position()
		var camera = get_tree().root.get_camera_3d()
		var rayOrigin = camera.project_ray_origin(mousePos)
		var ray_Vector = camera.project_ray_normal(mousePos)
		var amount:float = (rayOrigin.y-global_position.y)/ray_Vector.y
		var target_pos:Vector3 = rayOrigin - ray_Vector * amount
		bullet_direction = (target_pos - global_position).normalized()
	else:
		var input_bullet_direction = Vector3(input_frame["shoot_direction"].x,0, input_frame["shoot_direction"].y)
		var character_rotation = player.get_rotation()
		var cam_dir = Global.cal_camera_direction(rad_to_deg(character_rotation[1]))
		
		bullet_direction.x = input_bullet_direction.dot(cam_dir[0])
		bullet_direction.z = input_bullet_direction.dot(cam_dir[1])

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		isShootMouse = true
	
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		isShootMouse = false
