extends CanvasLayer

signal transitioned

@onready var animationPlayer = $AnimationPlayer

func _ready():
	animationPlayer.play("fade_to_normal")
func transition():
	animationPlayer.play("fade_to_black")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		emit_signal("transitioned")
		$AnimationPlayer.play("fade_to_normal")
	if anim_name == "fade_to_normal":
		print("finish fade")
