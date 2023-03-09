extends Node3D

@onready var animation = $AnimationPlayer
@onready var timer = $Timer
@onready var destroyTimer = $DestroyTimer
@onready var bomb = preload("res://Enemy/MortarEnemy/Bomb/S_Bomb.tscn")
@onready var sprite = $Sprite3D
var player
var down = false
var new_bomb
func _ready():
	animation.play("moving Ball")
	timer.start()
func _physics_process(delta):
	if down :
		position.y -= .1
	else:
		position.y += .1
	
func init(p,position):
	set_global_position(position)
	player = p

func _on_timer_timeout():
	timer.stop()
	new_bomb = bomb.instantiate()
	get_parent_node_3d().add_child(new_bomb)
	new_bomb.init(player.global_position)
	global_position.x = player.global_position.x
	down = true
	global_position.z = player.global_position.z
	destroyTimer.start()

func _on_destroy_timer_timeout():
	queue_free()
