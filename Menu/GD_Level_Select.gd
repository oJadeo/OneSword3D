extends CanvasLayer



func _on_back_pressed():
	get_tree().change_scene_to_file("res://Menu/S_Main_Menu.tscn")


func _on_tutorial_pressed():
	get_tree().change_scene_to_file("res://Level/Level_Scene/S_tutorial_2.tscn")
