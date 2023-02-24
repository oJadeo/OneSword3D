extends CharacterBody3D
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var ammo = 3
var player
var reloading = false
@onready var attackTimer = $AttackTimer
@onready var reloadTimer = $ReloadTimer
func _ready():
	attackTimer.wait_time = 0.25
func _physics_process(delta):

	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()


func _on_player_detection_body_entered(body):
	if body.name == "Player_Character":
		player = body
		attackTimer.start()
		print("player in range")


func _on_attack_timer_timeout():
	attackTimer.stop()
	if ammo > 0 and not reloading:
		print("shoot!",player.global_position)
		attackTimer.start()
		ammo -= 1
	else:
		reloading = true
		print("start_reload")
