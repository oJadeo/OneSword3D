extends Node3D

@onready var sprite = $Sprite3D
@onready var timer = $Timer
var deflected = false
var direction = Vector2.ZERO
var speed = 0.025
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	#position+= direction[move_dir] * speed
	position.x += direction.x * speed
	position.z += direction.y * speed
	#handle_height()
	pass

func init(dir_x,dir_z,pos,height,time):
	direction = Vector2(dir_x,dir_z).normalized()
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
