extends CharacterBody3D

enum {
	IDLE,
	CHASE,
	ATTACK,
}

var player = null
var state = IDLE
var direction = Vector3.ZERO
var moveSpeed = 0.5
var fleeSpeed = 0.5
var danger = false

@onready var playerDetectionCollision = $PlayerDetection/CollisionShape3d
@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")

func _ready():
	pass

func _physics_process(delta):
	if player != null:
		direction = Vector2((player.global_position - global_position).normalized().z,(player.global_position - global_position).normalized().x)
	match state:
		IDLE:
			velocity = Vector3.ZERO
		CHASE:
			if player != null:
				animationTree.set("parameters/Run/blend_position",direction)
				animationState.travel("Run")
				velocity = (player.global_position - global_position).normalized() * moveSpeed
			if player == null:
				state = IDLE
		ATTACK:
			if player != null:
				velocity = Vector3.ZERO
				animationTree.set("parameters/Reload/blend_position",direction)
				animationTree.set("parameters/Attack/blend_position",direction)
			if not danger:
				velocity = Vector3.ZERO
			else:
				velocity  = -((player.global_position - global_position).normalized() * fleeSpeed)
	move_and_slide()
		
	


func _on_player_detection_body_entered(body):
	if body.name == "Player_Character":
		player = body
		state = CHASE


func _on_player_detection_body_exited(body):
	if body.name == "Player_Character":
		player = null


func _on_attack_range_body_entered(body):
	if body.name == "Player_Character":
		state = ATTACK
		animationState.travel("Attack")


func _on_attack_range_body_exited(body):
	if body.name == "Player_Character":
		state = CHASE
		animationState.travel("Run")
func reload():
	animationState.travel("Reload")


func _on_danger_zone_body_entered(body):
	if body.name == "Player_Character":
		danger = true


func _on_danger_zone_body_exited(body):
	if body.name == "Player_Character":
		danger = false
