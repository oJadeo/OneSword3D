extends Node3D
class_name Bullet

@onready var collision = $Hitbox/CollisionShape3D
@onready var sprite = $Sprite3D
@onready var timer = $Timer
@onready var initialTimer = $InitialTimer

var deflected = false
var direction = Vector3.ZERO
var speed = 0.0175
# Called when the node enters the scene tree for the first time.
func _ready():
	collision.disabled = true
	initialTimer.start()
func _physics_process(delta):
	#position+= direction[move_dir] * speed
	global_position.x += direction.x * speed
	global_position.y += direction.y * speed
	global_position.z += direction.z * speed
	#handle_height()
	pass

func init(dir_x,dir_y,dir_z,pos,height,time):
	direction = Vector3(dir_x,dir_y,dir_z).normalized()
	timer.set_wait_time(2) #time 
	timer.set_autostart(true)
	timer.start()
	timer.set_one_shot(true)
	timer.connect("timeout",func(): queue_free())


func _on_hitbox_area_entered(area):
	if area.name == "Hitbox":
		deflected = true
		direction = -direction
		speed = 0.025
	elif area.name == "HurtBox" :		
		queue_free()
	

func _on_hitbox_body_entered(body):
	if body is StaticBody3D :
		queue_free()


func _on_initial_timer_timeout():
	collision.disabled = false
