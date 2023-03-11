extends CanvasLayer


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Menu/S_Level_Select.tscn")


func _on_exit_button_pressed():
	get_tree().quit()


func _on_setting_button_pressed():
	get_tree().change_scene_to_file("res://Menu/S_setting.tscn")
