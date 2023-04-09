extends Node3D

@export var bullet: Resource
@export var charge_angles:PackedInt32Array
@export var bullet_speed:float = 0.0175
@export var hook_range:int = 5

@onready var shootTimer = $shootTimer
@onready var chargeTimer = $chargeTimer
@onready var showMouseAimTimer = $showMouseAimTimer
@onready var hook_ray = $HookRay
@onready var aim_assist = $AimAssist

var bullet_direction = Vector3.ZERO
var reloading:bool = false
var isShootMouse:bool = false
var showMouseAim:bool = false
var player:PlayerCharacter
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.
func init(_player:PlayerCharacter) -> void:
	self.player = _player
	
func normal_shoot():
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
func process(_delta: float,input_frame:Dictionary) -> void:
	cal_bullet_dir(input_frame)
	#Handle Charge
	if input_frame["charge"] and player.can_shoot:
		chargeTimer.start()

	if input_frame["attack"] and shootTimer.is_stopped() and player.can_shoot:
		if (chargeTimer.time_left > 0):
			normal_shoot()

func _on_charge_timer_timeout():
	charge_shoot()
func create_bullet(direction:Vector3):
	var new_bullet = bullet.instantiate()
	get_tree().current_scene.add_child(new_bullet)
	showMouseAimTimer.start()
	showMouseAim = true
	new_bullet.init(direction,global_position,bullet_speed,true)
		
func line(pos1: Vector3, pos2: Vector3, color = Color.WHITE_SMOKE) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = 0

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(pos1)
	immediate_mesh.surface_add_vertex(pos2)
	immediate_mesh.surface_end()	
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	
	get_tree().get_root().add_child(mesh_instance)
	
	return mesh_instance

func cal_bullet_dir(input_frame:Dictionary):
	var target_pos:Vector3
	if isShootMouse:
		var mousePos = get_viewport().get_mouse_position()
		var camera = get_tree().root.get_camera_3d()
		var rayOrigin = camera.project_ray_origin(mousePos)
		var ray_Vector = camera.project_ray_normal(mousePos)
		var amount:float = (rayOrigin.y-global_position.y)/ray_Vector.y
		target_pos= rayOrigin - ray_Vector * amount
		bullet_direction = (target_pos - global_position).normalized()
		if  showMouseAim:
			var line = line(global_position,global_position+bullet_direction*5,Color.BLACK)
			get_tree().create_timer(.001).timeout.connect(func():line.queue_free())
	else:
		var input_pos = input_frame["shoot_direction"].normalized()*player.view_size.y/2 + player.view_size/2
		var camera = get_tree().root.get_camera_3d()
		var rayOrigin = camera.project_ray_origin(input_pos)
		var ray_Vector = camera.project_ray_normal(input_pos)
		var amount:float = (global_position.y - rayOrigin.y)/ray_Vector.y
		target_pos= rayOrigin + ray_Vector * amount
		bullet_direction = (target_pos - global_position).normalized()
		if input_frame["shoot_direction"] != Vector2.ZERO :
			var line = line(global_position,global_position+bullet_direction*5,Color.BLACK)
			get_tree().create_timer(.001).timeout.connect(func():line.queue_free())
	bullet_direction = aim_assist.get_assist(Vector2(bullet_direction.x,bullet_direction.z))
func hook() -> bool:
	hook_ray.set_target_position(bullet_direction*hook_range)
	hook_ray.force_raycast_update()
	var is_hook_collided = hook_ray.get_collider()
	if is_hook_collided is HookTarget:
		player.target_hook = is_hook_collided.global_position
		return true
	return false
func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		isShootMouse = true
	
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		isShootMouse = false


func _on_show_mouse_aim_timer_timeout():
	showMouseAimTimer.stop()
	showMouseAim = false
