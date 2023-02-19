extends Sprite3D

# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = get_tree().create_tween()
	tween.tween_property( self, "modulate",Color(1,1,1,0.0),  0.1 )
	tween.set_ease(3)
	tween.set_trans(1)
	await get_tree().create_timer(0.1).timeout
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#tween.interpolate_value(self,"modulate:a",1.0,0.0,0.5,3)
