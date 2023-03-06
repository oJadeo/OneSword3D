extends CharacterBody3D

@onready var bombHitbox = $Hitbox/Hitbox
@onready var animationPlayer = $AnimationPlayer
@onready var boomSprite = $Hitbox/Hitbox/boom
@onready var warnSprite = $warnSprite

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
#@onready var bomb = $Hitbox/Bomb
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * 1000
	move_and_slide()
	
func init(position):
	animationPlayer.play("warn")
	global_position.x = position.x
	global_position.z = position.z
	global_position.y = position.y - 0.25
	bombHitbox.disabled = true
	boomSprite.set_visible(false)

func trigger_bomb():
	bombHitbox.disabled = false
	warnSprite.set_visible(false)
	boomSprite.set_visible(true)
	animationPlayer.play("boom")

func bomb_fin():
	queue_free()
