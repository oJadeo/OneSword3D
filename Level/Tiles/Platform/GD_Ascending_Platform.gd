extends Node3D

var velocity:Vector3 = Vector3.ZERO
var charactes_list = []

@onready var platform = $GridMap
@onready var start_pos = $startPos
@onready var end_pos = $endPos
@onready var collision = $Area3D/CollisionShape3D
@onready var move_timer = $move_timer
@onready var area_3d = $Area3D

# Called when the node enters the scene tree for the first time.
func _ready():
	platform.set_global_position(start_pos.get_global_position())
	print(platform.get_global_position())
	velocity = (start_pos.global_position - end_pos.global_position)/move_timer.wait_time

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	platform.global_position -= velocity*delta
	area_3d.global_position -= velocity*delta
	for character in charactes_list:
		character.global_position -= velocity*delta
	print(platform.global_position,end_pos.global_position)
	if platform.get_global_position().y >= end_pos.get_global_position().y :
		platform.set_global_position(start_pos.get_global_position())


func _on_area_3d_body_entered(body):
	if body is CharacterBody3D:
		charactes_list.append(body)


func _on_area_3d_body_exited(body):
	if body is CharacterBody3D:
		charactes_list.erase(body)
