extends Node3D

@onready var player = $Player_Character
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'deltamove_and_slide()' is the elapsed time since the previous frame.
func _physics_process(delta):
	get_tree().call_group("Enemy","update_target_location",player.get_global_position())
