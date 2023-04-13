extends Node3D

enum Mode{
	Moving,
	Appear,
	Falling
}
enum State{
	on,
	off
}
@export var mode:Mode =  Mode.Moving
@onready var move_timer = $MoveTimer
@export var use_timer:bool = false
@onready var on_timer = $OnTimer
@onready var off_timer = $OffTimer
@onready var fall_timer = $FallTimer
var state:State = State.off
var charactes_list = []
var is_on = false

var velocity:Vector3 = Vector3.ZERO
@onready var platform = $GridMap
@onready var start_pos = $StartPos
@onready var end_pos = $EndPos
@onready var collision = $Area3D/CollisionShape3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match mode:
		Mode.Moving:
			platform.set_global_position(start_pos.get_global_position())
			if use_timer:
				on_timer.start()
		Mode.Appear:
			platform.set_global_position(start_pos.get_global_position())
			if use_timer:
				on_timer.start()
		Mode.Falling:
			platform.set_global_position(start_pos.get_global_position())

	activate()

	velocity = (end_pos.global_position - start_pos.global_position)/move_timer.wait_time

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match mode:
		Mode.Moving:
			if is_on and not move_timer.is_stopped():
				global_position -= velocity*delta
				for character in charactes_list:
					character.global_position -= velocity*delta
			if not is_on and not move_timer.is_stopped():
				global_position += velocity*delta
				for character in charactes_list:
					character.global_position += velocity*delta

func activate()-> void:
	match mode:
		Mode.Moving:
			move_timer.start()
			is_on = true
		Mode.Appear:
			platform.visible = true
			platform.set_collision_layer_value(1,true)
			collision.disabled = false
		Mode.Falling:
			platform.visible = true
			platform.set_collision_layer_value(1,true)
			collision.disabled = false
func deactivate()-> void:
	match mode:
		Mode.Moving:
			move_timer.start()
			is_on = false
		Mode.Appear:
			platform.visible = false
			platform.set_collision_layer_value(1,false)
			collision.disabled = true
		Mode.Falling:
			platform.visible = false
			platform.set_collision_layer_value(1,false)
			collision.disabled = true

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		charactes_list.append(body)
		if mode == Mode.Falling:
			fall_timer.start()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		charactes_list.erase(body)


func _on_on_timer_timeout() -> void:
	deactivate()
	if use_timer:
		match mode:
			Mode.Moving:
				off_timer.start()
			Mode.Appear:
				off_timer.start()
			Mode.Falling:
				off_timer.start()


func _on_off_timer_timeout() -> void:
	activate()
	if use_timer:
		match mode:
			Mode.Moving:
				on_timer.start()
			Mode.Appear:
				on_timer.start()
			Mode.Falling:
				pass


func _on_fall_timer_timeout() -> void:
	deactivate()
	off_timer.start()
