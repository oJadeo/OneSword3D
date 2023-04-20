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

# For setting the Bullet that was shot
var bullet_direction = Vector3.ZERO

# For checking which input is use
var isShootMouse:bool = false

# For shoot when click within the timer
var next_shot:bool = false

# Reference to player
var player:PlayerCharacter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.

# Get Reference to player
func init(_player:PlayerCharacter) -> void:
	self.player = _player

# Call every frame to calculate the aim direction and check if there are input
func process(_delta: float,input_frame:Dictionary) -> void:
	cal_aim_dir(input_frame)
	
	# When player hold shoot
	if input_frame["charge"] and player.can_shoot:
		
		# Show aim line if it mouse
		if isShootMouse:
			showMouseAimTimer.start()
		
		# Start conuting to charge
		chargeTimer.start()
	
	# When player just press shoot
	if input_frame["attack"]and player.can_shoot:
		
		# Show aim line if it mouse
		if isShootMouse:
			showMouseAimTimer.start()
		
		# the first time just normal_shoot
		if shootTimer.is_stopped():
			if (chargeTimer.time_left > 0):
				normal_shoot()

		# in timer so wait for timer end to shoot
		else:
			next_shot = true

# Calculate aim direction form input
func cal_aim_dir(input_frame:Dictionary):
	# Check Input if using mouse
	if isShootMouse:

		# Get vector2 direction of mouse according to player
		var mousePos = get_viewport().get_mouse_position() - player.view_size/2

		# Get aim assist to calculate
		bullet_direction = aim_assist.get_assist(mousePos.normalized())

		# Show aim lime for aim line timer
		if not showMouseAimTimer.is_stopped():
			var line = line(global_position,global_position+bullet_direction*5,Color.BLACK)
			get_tree().create_timer(.001).timeout.connect(func():line.queue_free())
	
	# if using controller
	else:

		# vector2 direction of Input
		var input_pos = input_frame["shoot_direction"].normalized()

		# Get aim assist to calculate
		bullet_direction = aim_assist.get_assist(input_pos)

		# Show aim lime for aim line timer
		if input_frame["shoot_direction"] != Vector2.ZERO :
			var line = line(global_position,global_position+bullet_direction*5,Color.BLACK)
			get_tree().create_timer(.001).timeout.connect(func():line.queue_free())

# Create aim line with color
func line(pos1: Vector3, pos2: Vector3, color = Color.WHITE_SMOKE) -> MeshInstance3D:
	
	# Generate mesh and material
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	# Setting mesh 
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = 0

	# Setting line pos and material
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(pos1)
	immediate_mesh.surface_add_vertex(pos2)
	immediate_mesh.surface_end()	
	
	# Setting material to show color
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	
	# add aim line to scene
	get_tree().get_root().add_child(mesh_instance)
	
	# return reference
	return mesh_instance

# when player shoot
func normal_shoot():
	
	# set that it is not a charge shot
	chargeTimer.stop()

	# Generate bullet
	create_bullet(bullet_direction)

	# start timer for not shoot again
	shootTimer.start()

# player can shoot again
func _on_shoot_timer_timeout():
	
	# Check if player press witnin timer
	if next_shot:

		# Reset vairable and shoot normal
		next_shot = false
		normal_shoot()

# when charge shot has been shot
func charge_shoot():

	# cal culation for each bullet by rotate 
	var bullet_vec = Vector2(bullet_direction.x,bullet_direction.z)
	for angle in charge_angles : 
		var new_bullet_vec = bullet_vec.rotated(deg_to_rad(angle))
		create_bullet(Vector3(new_bullet_vec.x,0,new_bullet_vec.y))

	# stop from shooting again
	shootTimer.start()

# charge shot get shot
func _on_charge_timer_timeout():
	charge_shoot()

# create bullet
func create_bullet(direction:Vector3):

	# instante setting and add to scene
	var new_bullet = bullet.instantiate()
	get_tree().current_scene.add_child(new_bullet)
	new_bullet.init(direction,global_position,bullet_speed,true)

# check hook in this component becuase use the same direction input
func hook() -> bool:
	
	# ray cast to direction after aim assit
	hook_ray.set_target_position(bullet_direction*hook_range)
	hook_ray.force_raycast_update()
	var is_hook_collided = hook_ray.get_collider()
	
	# check if it hit hook target
	if is_hook_collided is HookTarget:
		player.target_hook = is_hook_collided.global_position
		return true
		
	return false
	
# check input type
func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		isShootMouse = true
	
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		isShootMouse = false


