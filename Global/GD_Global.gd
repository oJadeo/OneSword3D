extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func cal_camera_direction(y_deg):
	if y_deg == 0:
		return [Vector3(1,0,0), Vector3(0,0,1)] 
	elif y_deg == 45:
		return [Vector3(sqrt(2),0,sqrt(2)), Vector3(-sqrt(2),0,sqrt(2))]
	elif y_deg == 90:
		return [Vector3(0,0,1), Vector3(-1,0,0)]
	elif y_deg == 135:
		return [Vector3(-sqrt(2),0,sqrt(2)),Vector3(-sqrt(2),0,-sqrt(2))]
	elif y_deg == -180:
		return [Vector3(-1,0,0), Vector3(0,0,-1)] 
	elif y_deg == -135:
		return [Vector3(-sqrt(2),0,-sqrt(2)), Vector3(sqrt(2),0,-sqrt(2))] 
	elif y_deg == -90:
		return [Vector3(0,0,-1), Vector3(1,0,0)]
	elif y_deg == -45:
		return [Vector3(sqrt(2),0,-sqrt(2)),Vector3(sqrt(2),0,sqrt(2))]
	return [Vector3(1,0,0), Vector3(0,0,1)] 
