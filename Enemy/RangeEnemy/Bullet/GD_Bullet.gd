extends Node3D
class_name Bullet

@onready var collision = $Hitbox/CollisionShape3D
@onready var sprite = $Sprite3D
@onready var timer = $Timer

var deflected = false
var direction = Vector3.ZERO
var speed = 0.0175
var friendly = false
# Called when the node enters the scene tree for the first time.
func _ready():
	collision.disabled = false
	
func _physics_process(delta):
	#position+= direction[move_dir] * speed
	global_position.x += direction.x * speed
	global_position.y += direction.y * speed
	global_position.z += direction.z * speed
	#handle_height()
	pass

func init(dir:Vector3,start_pos:Vector3,speed:float,friendly:bool):
	direction = dir.normalized()
	print(direction)
	self.speed = speed
	self.friendly = friendly
	set_global_position(start_pos)
	timer.set_wait_time(2) #time 
	timer.start()
	timer.set_one_shot(true)
	timer.connect("timeout",func(): queue_free())


func _on_hitbox_area_entered(area):
	if area.name == "Hitbox":
		deflected = true
		direction = -direction
		speed = 0.025

func _on_hitbox_body_entered(body):
	if body is StaticBody3D :
		print("OH shit")
		queue_free()


