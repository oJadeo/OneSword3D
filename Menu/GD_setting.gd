extends CanvasLayer

@onready var firstCol = $HBoxContainer/VBoxContainer
@onready var secondCol = $HBoxContainer/VBoxContainer2
@onready var inputPanel = $Panel

var currentRow
var currentCol
var currentAction
var edit = false

var cannotMappedKeyboard = ["Enter","Escape"]
var cannotMappedController = [4,6]
var gameActions = ["Move_Left","Move_Right","Move_Up","Move_Down","Attack","Dash","WallRun","Jump","Block"]
var actionsName = {
	"Move Left": "Move_Left",
	"Move Right" : "Move_Right",
	"Move Up" : "Move_Up",
	"Move Down" : "Move_Down",
	"Attack" : "Attack",
	"Dash" : "Dash",
	"Wall Run" : "WallRun",
	"Jump" : "Jump",
	"Block" : "Block"
}

var currentInputMappedKeyboard = {
	"Attack" : 75,
	"Jump" : 32,
	"Dash" : 4194325,
	"Move_Up" : 87,
	"Move_Down" : 83,
	"Move_Left" : 65,
	"Move_Right" : 68,
	"WallRun" : 4194326,
	"Block" : 76
}

var currentInputMappedController = {
	"Attack" : 2,
	"Jump" : 0,
	"Dash" : 1,
	"Move_Up" : 11,
	"Move_Down" : 12,
	"Move_Left" : 13,
	"Move_Right" : 14,
	"WallRun" : 9,
	"Block" : 10
}


func _ready():
	loadConfigFile()
	displayInput(currentInputMappedKeyboard)
	inputPanel.visible = false
	firstCol.get_child(0).get_child(1).grab_focus()
	print(currentInputMappedKeyboard["Move_Up"])


func loadConfigFile():
	var config = ConfigFile.new()
	var err = config.load("user://inputMap.cfg")

	if err != OK:
		print("no config to load")
	else :
		print("load complete")
	
	for section in config.get_sections():
		currentInputMappedKeyboard[section] = config.get_value(section,"Keyboard")
		currentInputMappedController[section] = config.get_value(section,"Controller")
	setupInput(currentInputMappedKeyboard,currentInputMappedController)
	
func _on_back_pressed():
	var config = ConfigFile.new()
	for action in currentInputMappedKeyboard:
		config.set_value(action,"Keyboard",currentInputMappedKeyboard[action])
		config.set_value(action,"Controller",currentInputMappedController[action])
	config.save("user://inputMap.cfg")
	setupInput(currentInputMappedKeyboard,currentInputMappedController)
	get_tree().change_scene_to_file("res://Menu/S_Main_Menu.tscn")
	

		
func displayInput(input_dict: Dictionary):
	var actions = input_dict.keys()
	for action in firstCol.get_children():
		action.get_child(1).text = OS.get_keycode_string(input_dict[actionsName[action.get_child(0).text]])
	for action in secondCol.get_children():
		action.get_child(1).text = OS.get_keycode_string(input_dict[actionsName[action.get_child(0).text]])
		
		
func _on_button_Move_Up_pressed():
	currentAction = "Move_Up"
	edit = true
	inputPanel.visible = true

func _on_button_Move_down_pressed():
	currentAction = "Move_Down"
	edit = true
	inputPanel.visible = true

func _on_button_Move_Right_pressed():
	currentAction = "Move_Right"
	edit = true
	inputPanel.visible = true
	
func _on_button_Move_Left_pressed():
	currentAction = "Move_Left"
	edit = true
	inputPanel.visible = true

func _on_button_Jump_pressed():
	currentAction = "Jump"
	edit = true
	inputPanel.visible = true
	
func _on_button_Dash_pressed():
	currentAction = "Dash"
	edit = true
	inputPanel.visible = true

func _on_button_Wall_Run_pressed():
	currentAction = "WallRun"
	edit = true
	inputPanel.visible = true

func _on_button_Attack_pressed():
	currentAction = "Attack"
	edit = true
	inputPanel.visible = true

func _on_button_Block_pressed():
	currentAction = "Block"
	edit = true
	inputPanel.visible = true

func getInputMaped():
	var actions = InputMap.get_actions()
	for action in actions:
		if action in gameActions:
			print(InputMap.action_get_events(action))

func _input(event):
	if edit:
		var targetEvent
		if event is InputEventKey:
			var duplicate = false
			for e in currentInputMappedKeyboard:
				if currentInputMappedKeyboard[e] == event.keycode:
					duplicate = true
			var string
			string = OS.get_keycode_string(event.keycode)
			if (!string in cannotMappedKeyboard):
				if not duplicate:
					currentInputMappedKeyboard[currentAction] = event.keycode
					#setupInput(currentInputMappedKeyboard,currentInputMappedController)
					edit = false
					inputPanel.visible = false
			displayInput(currentInputMappedKeyboard)
		if event is InputEventJoypadButton:
			print(event.button_index)
			var duplicate = false
			for e in currentInputMappedKeyboard:
				if currentInputMappedKeyboard[e] == event.button_index:
					duplicate = true
			if (event.button_index not in cannotMappedController and not duplicate):
				currentInputMappedController[currentAction] = event.button_index
				#setupInput(currentInputMappedKeyboard,currentInputMappedController)
				edit = false
				inputPanel.visible = false
			

func setupInput(inputKeyboard:Dictionary,inputController:Dictionary):
	for action in inputKeyboard:
		var targetEvent = InputMap.action_get_events(action)
		InputMap.action_erase_events(action)
		var newKeyboard = InputEventKey.new()
		newKeyboard.keycode = inputKeyboard[action]
		InputMap.action_add_event(action,newKeyboard)
		var newController = InputEventJoypadButton.new()
		newController.button_index = inputController[action]
		InputMap.action_add_event(action,newController)

