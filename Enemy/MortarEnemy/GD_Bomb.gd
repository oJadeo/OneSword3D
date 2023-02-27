extends Area3D

@onready var bomb = $Bomb
@onready var warn = $Warn
@onready var bombHitbox = $Hitbox
@onready var warn_timer = $warn_timer
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func init(position,mortar_position):
	global_position.x = position.x
	global_position.z = position.z
	global_position.y = mortar_position.y
	bomb.set_visible(false)
	bombHitbox.disabled = true
	warn_timer.start()

func _on_warn_timer_timeout():
	warn_timer.stop()
	bombHitbox.disabled = false
	bomb.set_visible(true)
	await get_tree().create_timer(0.25).timeout
	queue_free()
