extends CharacterBody3D

enum {
	IDLE,
	CHASE,
	ATTACK
}

@onready var playerDetectionCollision = $CollisionShape3d
var player = null
var state = IDLE
var direction = Vector3.ZERO
var moveSpeed = 0.5

#Animation
@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")


func _ready():
	pass

func _process(delta):
	if player != null:
		direction = Vector2((player.global_position - global_position).normalized().z,(player.global_position - global_position).normalized().x)
	match state:
		IDLE:
			animationTree.set("parameters/Idle/blend_position",direction)
			animationState.travel("Idle")
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
				animationTree.set("parameters/Attack/blend_position",direction)
				animationState.travel("Attack")
	
	move_and_slide()
	

func _on_player_detection_body_entered(body):
	if body.name == "PlayerCharacter":
		player = body
		state = CHASE


func _on_player_detection_body_exited(body):
	if body.name == "PlayerCharacter":
		player = null


func _on_hurtbox_area_entered(area):
	if area.name == "Hitbox":
		queue_free()
		
func _on_attac_range_body_entered(body):
	if body.name == "PlayerCharacter":
		state = ATTACK
