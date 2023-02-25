extends CharacterBody3D
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var ammo = 3
var player
var reloading = false
var new_bomb
@onready var attackTimer = $AttackTimer
@onready var reloadTimer = $ReloadTimer
@onready var bomb = preload("res://Enemy/MortarEnemy/S_Bomb.tscn")
@onready var sprtie = $Sprite3d
func _ready():
	attackTimer.wait_time = 0.25
func _physics_process(delta):
	if reloading :
		sprtie.modulate = Color(0,1,0)
	else:
		sprtie.modulate = Color(0,0,0)
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()


func _on_player_detection_body_entered(body):
	if body.name == "Player_Character":
		player = body
		attackTimer.start()
		print("player in range")
		
func _on_player_detection_body_exited(body):
	if body.name == "Player_Character":
		player = null

func _on_attack_timer_timeout():
	attackTimer.stop()
	if ammo > 0 and not reloading and player != null:
		new_bomb = bomb.instantiate()
		get_owner().add_child(new_bomb)
		new_bomb.init(player.global_position,global_position)
		attackTimer.start()
		ammo -= 1
	elif ammo == 0:
		reloading = true
		reloadTimer.start()
		print("start_reload")


func _on_reload_timer_timeout():
	print("finish_reload")
	reloadTimer.stop()
	attackTimer.start()
	ammo = 3
	reloading = false
