extends CharacterBody3D
# Get the gravity from the project settings to be synced with RigidBody nodes.

var ammo = 3
var player
var reloading = false
var isHit = false
var new_bomb
var new_ball
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var bomb = preload("res://Enemy/MortarEnemy/Bomb/S_Bomb.tscn")
@onready  var ball = preload("res://Enemy/MortarEnemy/Ball/S_Ball.tscn")

@onready var attackTimer = $AttackTimer
@onready var reloadLoopTimer = $ReloadLoopTimer
@onready var reloadTimer = $ReloadTimer
@onready var redTimer = $RedTimer
@onready var animation = $AnimationPlayer
@onready var health = 5
@onready var sprite = $Sprite3d

@export var mortarRange : int=3
func _ready():
	animation.play("idle")
	set_range(mortarRange)
	
	
func set_range(range):
	$PlayerDetection/CollisionShape3D.get_shape().set_radius(range)

func _physics_process(delta):
	if isHit :
		sprite.set_modulate(Color(0.8,0,0))
	elif reloading :
		sprite.set_modulate(Color(0.8,0.8,0.8))
	else :
		sprite.set_modulate(Color(1,1,1))
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()
	
func _on_player_detection_body_entered(body):
	if body.name == "Player_Character":
		player = body
		attackTimer.start()
		
func _on_player_detection_body_exited(body):
	if body.name == "Player_Character":
		player = null

func _on_attack_timer_timeout():
	attackTimer.stop()
	animation.play("attack")
	
func attack_finish():
	if ammo > 0 and not reloading and player != null and player.is_on_floor():
		new_ball = ball.instantiate()
		new_ball.init(player,global_position)
		get_parent_node_3d().add_child(new_ball)
		#new_bomb = bomb.instantiate()
		#get_owner().add_child(new_bomb)
		#new_bomb.init(player.global_position,global_position)
		attackTimer.start()
		ammo -= 1
	elif ammo == 0:
		reloading = true
		reloadLoopTimer.start()
		animation.play("reload loop")


func _on_reload_loop_timer_timeout():
	reloadLoopTimer.stop()
	animation.play("reload")
	reloadTimer.start()

func _on_reload_timer_timeout():
	reloadTimer.stop()
	reloading = false
	ammo = 3
	animation.play("idle")
	attackTimer.start()


func _on_hurt_box_area_entered(area):
	if area.name == "Hitbox":
		health -= 1
		if health > 0:
			redTimer.start()
			isHit = true
		else:
			queue_free()


func _on_red_timer_timeout():
	redTimer.stop()
	isHit = false
