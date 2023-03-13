extends Area3D

func _on_body_entered(body):
	if (body.name == "Player_Character") :
		var levelManager = get_tree().get_root().get_node("LevelManager")
		GdLevelGlobal.current_level += 1
		levelManager.transitionScreen.transition()

