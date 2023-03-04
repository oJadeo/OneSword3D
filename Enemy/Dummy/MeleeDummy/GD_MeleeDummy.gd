extends CharacterBody3D



@onready var animationPlayer = $AnimationPlayer

var health = 3


func _ready():
	animationPlayer.play("Idle")
	
func _physics_process(delta):
	pass
	



func _on_hurtbox_area_entered(area):
	if area.name == "Hitbox":
		if health > 1:
			health -= 1
			animationPlayer.play("Take_damage")
			await get_tree().create_timer(1).timeout
			animationPlayer.play("Idle")
		else:
			animationPlayer.play("Death")
			await get_tree().create_timer(3).timeout
			animationPlayer.play("Regen")
			health = 3

func handle_detah():
	animationPlayer.play("Cooldown")

func handle_regen():
	animationPlayer.play("Idle")

		
