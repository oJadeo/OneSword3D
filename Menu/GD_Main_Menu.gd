extends CanvasLayer

var current = 0
@onready var buttonList = $ButtonList

var currentInputMappedKeyboard = {
	"Attack" : 1,
	"Jump" : 32,
	"Dash" : 4194325,
	"Move_Up" : 87,
	"Move_Down" : 83,
	"Move_Left" : 65,
	"Move_Right" : 68,
	"WallRun" : 4194326,
	"Block" : 2
}

var currentInputMappedController = {
	"Attack" : 5,
	"Jump" : 0,
	"Dash" : 1,
	"Move_Up" : 999,
	"Move_Down" : 999,
	"Move_Left" : 999,
	"Move_Right" : 999,
	"WallRun" : 9,
	"Block" : 10
}


func _ready():
	loadConfigFile()
	buttonList.get_children()[current].grab_focus()

func _process(delta):
	pass
	#if Input.is_action_just_pressed("Move_Down") or Input.is_action_just_pressed("Move_Up") :
		#if Input.is_action_just_pressed("Move_Down") :
			#current += 1
		#elif  Input.is_action_just_pressed("Move_Up") :
			#current -= 1
		#current = current%3
		#buttonList.get_children()[current].grab_focus()
		
	#if Input.is_action_just_pressed("Menu_Accept") :
		#buttonList.get_children()[current].emit_signal("pressed")
		
func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Menu/S_Level_Select.tscn")
	
func _on_setting_button_pressed():
	get_tree().change_scene_to_file("res://Menu/S_setting.tscn")
	
func _on_exit_button_pressed():
	get_tree().quit()

func loadConfigFile():
	var config = ConfigFile.new()
	var err = config.load("user://inputMapping.cfg")

	if err != OK:
		print("no config to load")
	else :
		print("load complete")
		for section in config.get_sections():
			currentInputMappedKeyboard[section] = config.get_value(section,"Keyboard")
			currentInputMappedController[section] = config.get_value(section,"Controller")
	setupInput(currentInputMappedKeyboard,currentInputMappedController)

func setupInput(inputKeyboard:Dictionary,inputController:Dictionary):
	for action in inputKeyboard:
		var targetEvent = InputMap.action_get_events(action)
		var newKeyboard
		InputMap.action_erase_events(action)
		if currentInputMappedKeyboard[action] == 1:
			newKeyboard = InputEventMouseButton.new()
			newKeyboard.button_index = currentInputMappedKeyboard[action]
		elif currentInputMappedKeyboard[action] == 2:
			newKeyboard = InputEventMouseButton.new()
			newKeyboard.button_index = currentInputMappedKeyboard[action]
		else:
			newKeyboard = InputEventKey.new()
			newKeyboard.keycode = inputKeyboard[action]
		InputMap.action_add_event(action,newKeyboard)
		var newController
		if currentInputMappedController[action] == 4:
			newController = InputEventJoypadMotion.new()
			newController.axis = 4
			newController.axis_value = +1
		elif currentInputMappedController[action] == 5:
			newController = InputEventJoypadMotion.new()
			newController.axis = 5
			newController.axis_value = +1
		elif action == "Move_Up":
			newController = InputEventJoypadMotion.new()
			newController.axis = 1
			newController.axis_value = -1
		elif action == "Move_Down":
			newController = InputEventJoypadMotion.new()
			newController.axis = 1
			newController.axis_value = 1
		elif action == "Move_Left":
			newController = InputEventJoypadMotion.new()
			newController.axis = 0
			newController.axis_value = -1
		elif action == "Move_Right":
			newController = InputEventJoypadMotion.new()
			newController.axis = 0
			newController.axis_value = 1
		else:
			newController = InputEventJoypadButton.new()
			newController.button_index = inputController[action]
		InputMap.action_add_event(action,newController)

