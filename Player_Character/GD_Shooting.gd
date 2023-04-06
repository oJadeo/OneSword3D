extends Node3D

@export var bullet: Resource
@export var charge_angles:PackedInt32Array
@export var bullet_speed:float = 0.0175

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
	
func normal_shoot():
	print("Shoot")
	chargeTimer.stop()
	create_bullet(bullet_direction)
	shootTimer.start()
func charge_shoot():
	chargeTimer.stop()
	var bullet_vec = Vector2(bullet_direction.x,bullet_direction.z)
	for angle in charge_angles : 
		var new_bullet_vec = bullet_vec.rotated(deg_to_rad(angle))
		create_bullet(Vector3(new_bullet_vec.x,0,new_bullet_vec.y))
	shootTimer.start()
func process(delta: float,input_frame:Dictionary) -> void:
	cal_bullet_dir(input_frame)
	#Handle Charge
	if input_frame["charge"] :
		chargeTimer.start()

	if input_frame["attack"] and shootTimer.is_stopped():
		if (chargeTimer.time_left > 0):
			normal_shoot()
func _on_charge_timer_timeout():
	charge_shoot()
func create_bullet(direction:Vector3):
	var new_bullet = bullet.instantiate()
	get_tree().current_scene.add_child(new_bullet)
	new_bullet.init(direction,global_position,bullet_speed,true)
	
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
		var input_pos = input_frame["shoot_direction"].normalized()*player.view_size.y/2 + player.view_size/2
		var camera = get_tree().root.get_camera_3d()
		var rayOrigin = camera.project_ray_origin(input_pos)
		var ray_Vector = camera.project_ray_normal(input_pos)
		var amount:float = (global_position.y - rayOrigin.y)/ray_Vector.y
		var target_pos:Vector3 = rayOrigin + ray_Vector * amount
		
		bullet_direction = (target_pos - global_position).normalized()

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		isShootMouse = true
	
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		isShootMouse = false
