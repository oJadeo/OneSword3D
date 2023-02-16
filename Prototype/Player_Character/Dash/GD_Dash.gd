extends Node3D

const dash_delay = 0.5


@onready var timer = $dash_timer
@onready var ghost_timer = $ghost_timer
@onready var dust_trail = $DustTrail
@onready var dust_burst = $DustBurst
var can_dash = true
var ghost_scene = preload("res://Testing3D_wallRun/Prototype/Player_Character/Dash/S_dashGhost.tscn")
var sprite
var height = 0
var dashFinished = false

func start_dash(height,sprite,dur,direction):
	dashFinished = false
	self.sprite = sprite
	self.height = height
	timer.wait_time = dur
	timer.start()
	ghost_timer.start()
	
	instance_ghost()
	
	dust_trail.restart()
	dust_trail.emitting = true
	
	dust_burst.rotate((direction * -1).angle())
	dust_burst.restart()
	dust_burst.emitting = true

func instance_ghost():
	var ghost = ghost_scene.instantiate()
	#print(get_parent().get_parent().get_parent())
	get_parent().get_parent().add_child(ghost)
	
	ghost.global_position = global_position
	ghost.texture = sprite.texture
	ghost.vframes = sprite.vframes
	ghost.hframes = sprite.hframes
	ghost.frame = sprite.frame
	ghost.flip_h = sprite.flip_h

func is_dashing():
	return !timer.is_stopped()
	
func end_dash():
	dash_delay_camera()
	ghost_timer.stop()
	can_dash = false
	await get_tree().create_timer(dash_delay).timeout
	can_dash = true
	


func _on_dash_timer_timeout():
	end_dash()


func _on_ghost_timer_timeout():
	instance_ghost()

func dash_delay_camera():
	await get_tree().create_timer(0.1).timeout
	dashFinished = true
