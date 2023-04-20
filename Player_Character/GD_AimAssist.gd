extends Area3D

@export var assist_angle:float = 90
@export var y_diff:float = 0.25
@export var debug:bool = false
@onready var camera = $"../../Camera3d"
@onready var assist_ray = $"../HookRay"
var view_size:Vector2 = Vector2(640,360)
var nearest_target_range:float = 100
var target_list:Array = []

# From input position in the camera 
func get_assist(input_angle:Vector2) -> Vector3:

	var output_direction = Vector3.ZERO

	# calculate normal from position in the camera  cast to same height
	var input_pos = input_angle*view_size.y/2 + view_size/2
	var camera = get_tree().root.get_camera_3d()
	var rayOrigin = camera.project_ray_origin(input_pos)
	var ray_Vector = camera.project_ray_normal(input_pos)
	var amount:float = (global_position.y - rayOrigin.y)/ray_Vector.y
	var target_pos= rayOrigin + ray_Vector * amount
	output_direction = (target_pos - global_position).normalized()

	# Show input aim line if debug
	if debug:
		var line = get_parent().line(global_position,global_position+output_direction,Color.RED)
		get_tree().create_timer(.001).timeout.connect(func():line.queue_free())

	# reset variable
	nearest_target_range = 100
	for target in target_list:

		# calculate angle when look in camera
		var target_angle = (camera.unproject_position(target.global_position) - view_size/2).normalized()
		
		# cal direction in 3d space
		var distance_vector = target.global_position- global_position

		# Ray cast check if there are something in the way
		assist_ray.set_target_position(distance_vector)
		assist_ray.force_raycast_update()
		var is_assist_collided = assist_ray.get_collider()
		if is_assist_collided and is_assist_collided.is_in_group('target'):
			
			# check height diff of target
			if distance_vector.y <= y_diff:

				# check angle
				if abs(rad_to_deg(input_angle.angle_to(target_angle))) <= assist_angle:

					# check is this the nearest taget
					if distance_vector.length() < nearest_target_range:

						# this one is target
						nearest_target_range = distance_vector.length()
						output_direction = distance_vector.normalized()

						# Show assist aim line if debug
						if debug:
							var line_2 = get_parent().line(global_position,global_position+output_direction,Color.BLACK)
							get_tree().create_timer(.001).timeout.connect(func():line_2.queue_free())
		
	return output_direction


# Check if target enter range and add to list
func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group('target'):
		target_list.append(area.get_parent())

# Check if target exit range and remove from list
func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group('target'):
		target_list.erase(area.get_parent())

