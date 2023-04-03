extends Node3D

@export var bullet: Resource
@export var charge_angles:PackedInt32Array


@onready var shootTimer = $shootTimer
@onready var chargeTimer = $chargeTimer
var bullet_direction = Vector3.ZERO
var reloading:bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.
	
	
func spawn_bullet():
	chargeTimer.stop()
	screen_point_to_ray()
	var new_bullet = bullet.instantiate()
	var bulletDirection_x = bullet_direction.x 
	var bulletDirection_z = bullet_direction.z
	add_child(new_bullet)
	new_bullet.init(bulletDirection_x,0,bulletDirection_z,0,0,2)
	shootTimer.start()
func spawn_charge_bullet():
	chargeTimer.stop()
	screen_point_to_ray()
	var bullet_vec = Vector2(bullet_direction.x,bullet_direction.z)
	for angle in charge_angles : 
		var new_bullet = bullet.instantiate()
		var new_bullet_vec = bullet_vec.rotated(deg_to_rad(angle))
		add_child(new_bullet)
		new_bullet.init(new_bullet_vec.x,0,new_bullet_vec.y,0,0,2)
	shootTimer.start()
func screen_point_to_ray():
	var mousePos = get_viewport().get_mouse_position()
	var camera = get_tree().root.get_camera_3d()
	var rayOrigin = camera.project_ray_origin(mousePos)
	var ray_Vector = camera.project_ray_normal(mousePos)
	var amount:float = (rayOrigin.y-global_position.y)/ray_Vector.y
	var target_pos:Vector3 = rayOrigin - ray_Vector * amount
	bullet_direction = (target_pos - global_position).normalized()
func process(delta: float,input_frame:Dictionary) -> void:
	
	#Handle Charge
	if input_frame["charge"] :
		chargeTimer.start()

	if input_frame["attack"] and shootTimer.is_stopped():
		if (chargeTimer.time_left > 0):
			spawn_bullet()
func _on_charge_timer_timeout():
	spawn_charge_bullet()
