extends CharacterBody3D

@onready var animationPlayer = $AnimationPlayer
@onready var animationTree = $AnimationTree
@onready var playerDetection = $PlayerDetection
@onready var animationState = animationTree.get("parameters/playback")
@onready var bullet = preload("res://Enemy/RangeEnemy/Bullet/S_Bullet.tscn")

enum {
	IDLE,
	ATTACK,
}

var new_bullet
var player = null
var direction = Vector3.ZERO
var health = 3
var state = IDLE

func _ready():
	animationState.travel("Idle")
func _physics_process(delta):
	if player != null:
		direction = Global.cal_sprite_direction((player.global_position - global_position).normalized())
	match state :
		IDLE: 
			animationState.travel("Idle")
		ATTACK:
			animationTree.set("parameters/Attack/blend_position",direction)

func spawn_bellet():
	new_bullet = bullet.instantiate()
	var bulletDirection_x = player.get_global_position().x - get_global_position().x
	var bulletDirection_z = player.get_global_position().z - get_global_position().z
	add_child(new_bullet)
	print(player.global_position)
	print(new_bullet.global_position)
	new_bullet.init(bulletDirection_x,bulletDirection_z,0,0,2)

func attack_fin() :
	animationState.travel("Idle")
	if player == null :
		pass
	else:
		await get_tree().create_timer(1).timeout
		animationState.travel("Attack")
	

func _on_hurtbox_area_entered(area):
	if area.name == "Hitbox":
		if health > 1:
			health -= 1
			animationState.travel("Take_damage")
			animationTree.set("parameters/Take_damage/blend_position",direction)
			await get_tree().create_timer(1).timeout
			if state == ATTACK :
				animationState.travel("Attack")
			else:
				animationState.travel("Idle")
				
		else:
			animationState.travel("Death")
			await get_tree().create_timer(3).timeout
			animationState.travel("Regen")
			health = 3

func regen_fin():
	if state == ATTACK :
		animationState.travel("Attack")
	else:
		animationState.travel("Idle")

func _on_player_detection_body_entered(body):
	if body.name == "Player_Character":
		player = body
		state = ATTACK
		animationState.travel("Attack")


func _on_player_detection_body_exited(body):
	if body.name == "Player_Character":
		player = null
		state = IDLE
