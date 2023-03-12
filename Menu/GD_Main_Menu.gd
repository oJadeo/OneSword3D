extends CanvasLayer

var current = 0
@onready var buttonList = $ButtonList

func _ready():
	buttonList.get_children()[current].grab_focus()

func _process(delta):
	if Input.is_action_just_pressed("Move_Down") or Input.is_action_just_pressed("Move_Up") :
		if Input.is_action_just_pressed("Move_Down") :
			current += 1
		elif  Input.is_action_just_pressed("Move_Up") :
			current -= 1
		current = current%3
		buttonList.get_children()[current].grab_focus()
		
	if Input.is_action_just_pressed("Menu_Accept") :
		buttonList.get_children()[current].emit_signal("pressed")
		
func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Menu/S_Level_Select.tscn")
	
func _on_setting_button_pressed():
	get_tree().change_scene_to_file("res://Menu/S_setting.tscn")
	
func _on_exit_button_pressed():
	get_tree().quit()
