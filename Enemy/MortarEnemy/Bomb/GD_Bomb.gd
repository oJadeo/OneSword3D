extends Area3D

@onready var bombHitbox = $Hitbox
@onready var warnAnimationPlayer = $AnimationPlayer
@onready var bomb = $Hitbox/Bomb
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func init(position,mortar_position):
	warnAnimationPlayer.play("warn")
	global_position.x = position.x
	global_position.z = position.z
	global_position.y = mortar_position.y
	bombHitbox.disabled = true
	bomb.set_visible(false)

func trigger_bomb():
	bomb.set_visible(true)
	bombHitbox.disabled = false
	await get_tree().create_timer(0.25).timeout
	queue_free()
