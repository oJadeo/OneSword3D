extends Area3D

@export var assist_angle:float = 90
@export var y_diff:float = 0.25
@onready var camera = $"../../Camera3d"
@onready var assist_ray = $"../HookRay"
var view_size:Vector2 = Vector2(640,360)
var target_range:float = 100
var target_list:Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_assist(input_angle:Vector2) -> Vector3:
	var assist = {}
	var output_direction = Vector3.ZERO
	target_range = 100
	for target in target_list:
		var target_angle = (camera.unproject_position(target.global_position) - view_size/2).normalized()
		var distance_vector = target.global_position- global_position
		assist_ray.set_target_position(distance_vector)
		assist_ray.force_raycast_update()
		var is_assist_collided = assist_ray.get_collider()
		if is_assist_collided and is_assist_collided.is_in_group('target'):
			if distance_vector.y <= y_diff:
				if abs(rad_to_deg(input_angle.angle_to(target_angle))) <= assist_angle:
					if distance_vector.length() < target_range:
						target_range = distance_vector.length()
						output_direction = distance_vector.normalized()
		
	return Vector3(input_angle.x,0,input_angle.y) if output_direction == Vector3.ZERO else output_direction


func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group('target'):
		target_list.append(area.get_parent())

func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group('target'):
		target_list.erase(area.get_parent())
