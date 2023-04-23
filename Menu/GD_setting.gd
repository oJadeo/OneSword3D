extends CanvasLayer



@onready var container = $VBoxContainer
@onready var firstCol = $VBoxContainer/HBoxContainer/VBoxContainer
@onready var secondCol = $VBoxContainer/HBoxContainer/VBoxContainer2
@onready var inputPanel = $Panel
@onready var keyboard = $VBoxContainer/HBoxContainer
@onready var movementContainer = $VBoxContainer/HBoxContainer/VBoxContainer
@onready var seperateContainer = $VBoxContainer/HBoxContainer/VBoxContainer3
@onready var keyboardButton = $VBoxContainer/HBoxContainer2/Keyboard
@onready var controllerButton = $VBoxContainer/HBoxContainer2/Controller
@onready var testButton = $VBoxContainer/HBoxContainer/VBoxContainer2/Input5/Button

var currentAction
var edit = false
enum mode {
	KEYBOARD,
	CONTROLLER
}

var currentMode = mode.KEYBOARD
var currentControllerType
var cannotMappedKeyboard = ["Enter","Escape"]
var cannotMappedController = [6]
var gameActions = ["Move_Left","Move_Right","Move_Up","Move_Down","Attack","Dialogue","WallRun","Jump","Hook"]
var actionsName = {
	"Move Left": "Move_Left",
	"Move Right" : "Move_Right",
	"Move Up" : "Move_Up",
	"Move Down" : "Move_Down",
	"Attack" : "Attack",
	"Dialogue" : "Dialogue",
	"Wall Run" : "WallRun",
	"Jump" : "Jump",
	"Hook" : "Hook"
}

enum controllerType {
	PS4,
	XBOX
}

var PS4_button= {
	0 : "X",
	1 : "Circle",
	2 : "Square",
	3 : "Triangle",
	4 : "L2",
	5 : "R2",
	6 : "Share",
	7 : "L3",
	8 : "R3",
	9 : "L1",
	10 : "R1",
	11 : "Dpad Up",
	12 : "Dpad Down",
	13 : "Dpad Left",
	14 : "Dpad Right"	
}

var PS4_button_pics= {
	0 : "Cross",
	1 : "Circle",
	2 : "Square",
	3 : "Triangle",
	4 : "L2",
	5 : "R2",
	6 : "SelectP",
	7 : "LS",
	8 : "RS",
	9 : "L1",
	10 : "R1",
	11 : "UpDpadP",
	12 : "DownDpadP",
	13 : "LeftDpadP",
	14 : "RightDpadP"	
}

var xbox_button= {
	0 : "A",
	1 : "B",
	2 : "X",
	3 : "Y",
	4 : "LT",
	5: "RT",
	6 : "mairu",
	7 : "LS",
	8 : "RS",
	9 : "LB",
	10 : "RB",
	11 : "Dpad Up",
	12 : "Dpad Down",
	13 : "Dpad Left",
	14 : "Dpad Right"	
}

var xbox_button_pics= {
	0 : "A",
	1 : "B",
	2 : "X",
	3 : "Y",
	4 : "LT",
	5: "RT",
	6 : "mairu",
	7 : "LS",
	8 : "RS",
	9 : "LB",
	10 : "RB",
	11 : "UpDpadX",
	12 : "DownDpadX",
	13 : "LeftDpadX",
	14 : "RightDpadX"	
}

var keyboard_button_pics = {
	1 : "LeftMouse",
	2 : "RightMouse",
	65 : "A",
	66 : "B",
	67 : "C",
	68 : "D",
	69 : "E",
	70 : "F",
	71 : "G",
	72 : "H",
	73 : "I",
	74 : "J",
	75 : "K",
	76 : "L",
	77 : "M",
	78 : "N",
	79 : "O",
	80 : "P",
	81 : "Q",
	82 : "R",
	83 : "S",
	84 : "T",
	85 : "U",
	86 : "V",
	87 : "W",
	88 : "X",
	89 : "Y",
	90 : "Z",
	4194320 : "Up",
	4194319 : "Left",
	4194322 : "Down",
	4194321 : "Right",
	4194325 : "Shift",
	4194326 : "CTRL",
	46 : "Dot",
	44 : "Comma",
	59 : "Semicolon",
	91 : "OpenBracket",
	93 : "CloseBracket",
	92 : "BackSlash",
	47 : "Slash",
	61 : "Equal",
	39 : "Apostrophe",
	48 : "0",
	49 : "1",
	50 : "2",
	51 : "3",
	52 : "4",
	53 : "5",
	54 : "6",
	55 : "7",
	56 : "8",
	57 : "9",
	32 : "Space"
}

var defaultInputKeyboard = {
	"Attack" : 1,
	"Jump" : 32,
	"Dialogue" : 70,
	"Move_Up" : 87,
	"Move_Down" : 83,
	"Move_Left" : 65,
	"Move_Right" : 68,
	"WallRun" : 4194326,
	"Hook" : 2
}

var currentInputMappedKeyboard = {
	"Attack" : 1,
	"Jump" : 32,
	"Dialogue" : 70,
	"Move_Up" : 87,
	"Move_Down" : 83,
	"Move_Left" : 65,
	"Move_Right" : 68,
	"WallRun" : 4194326,
	"Hook" : 2
}

var defaultInputController = {
	"Attack" : 5,
	"Jump" : 4,
	"Dialogue" : 0,
	"Move_Up" : 999,
	"Move_Down" : 999,
	"Move_Left" : 999,
	"Move_Right" : 999,
	"WallRun" : 9,
	"Hook" : 10
}

var currentInputMappedController = {
	"Attack" : 5,
	"Jump" : 4,
	"Dialogue" : 0,
	"Move_Up" : 999,
	"Move_Down" : 999,
	"Move_Left" : 999,
	"Move_Right" : 999,
	"WallRun" : 9,
	"Hook" : 10
}


func _ready():
	if Input.get_joy_name(0) == "PS4 Controller":
		currentControllerType = controllerType.PS4
	if Input.get_joy_name(0) == "XInput Gamepad":
		currentControllerType = controllerType.XBOX
	loadConfigFileForDisplay()
	container.visible = true
	inputPanel.visible = false
	keyboard.visible = true
	keyboardButton.grab_focus()
	#firstCol.get_child(0).get_child(1).grab_focus()
	#print(currentInputMappedKeyboard["Move_Up"])


func loadConfigFileForDisplay():
	var config = ConfigFile.new()
	var err = config.load("user://inputMapping.cfg")

	if err != OK:
		print("no config to load")
	else :
		print("load complete")
	
	for section in config.get_sections():
		currentInputMappedKeyboard[section] = config.get_value(section,"Keyboard")
		currentInputMappedController[section] = config.get_value(section,"Controller")
	displayInputKeyboard(currentInputMappedKeyboard)
	
	
func _on_back_pressed():
	var config = ConfigFile.new()
	for action in currentInputMappedKeyboard:
		config.set_value(action,"Keyboard",currentInputMappedKeyboard[action])
		config.set_value(action,"Controller",currentInputMappedController[action])
	config.save("user://inputMapping.cfg")
	get_tree().change_scene_to_file("res://Menu/S_Main_Menu.tscn")
	

		
func displayInputKeyboard(input_dict: Dictionary):
	var actions = input_dict.keys()
	for action in firstCol.get_children():
		action.get_child(1).icon = load("res://Menu/Buttons/Keyboard_Pics/" + keyboard_button_pics[input_dict[actionsName[action.get_child(0).text]]] + ".png")
		#if currentInputMappedKeyboard[actionsName[action.get_child(0).text]] == 1:
			#action.get_child(1).text = "LM"
		#elif currentInputMappedKeyboard[actionsName[action.get_child(0).text]] == 2:
			#action.get_child(1).text = "RM"
		#else:
			#action.get_child(1).text = OS.get_keycode_string(input_dict[actionsName[action.get_child(0).text]])
	for action in secondCol.get_children():
		action.get_child(1).icon = load("res://Menu/Buttons/Keyboard_Pics/" + keyboard_button_pics[input_dict[actionsName[action.get_child(0).text]]] + ".png")
		#if currentInputMappedKeyboard[actionsName[action.get_child(0).text]] == 1:
			#action.get_child(1).text = "LM"
		#elif currentInputMappedKeyboard[actionsName[action.get_child(0).text]] == 2:
			#action.get_child(1).text = "RM"
		#else:
			#action.get_child(1).text = OS.get_keycode_string(input_dict[actionsName[action.get_child(0).text]])
func displayInputController(input_dict:Dictionary):
	if currentControllerType == null:
		pass
	elif currentControllerType == controllerType.PS4:
		for action in secondCol.get_children():
			#print(input_dict[actionsName[action.get_child(0).text]])
			if input_dict[actionsName[action.get_child(0).text]] != 999:
				#action.get_child(1).text = PS4_button[input_dict[actionsName[action.get_child(0).text]]]
				action.get_child(1).icon = load("res://Menu/Buttons/Controller_Pics/" + PS4_button_pics[input_dict[actionsName[action.get_child(0).text]]] + ".png")
	elif currentControllerType == controllerType.XBOX:
		for action in secondCol.get_children():
			#print(input_dict[actionsName[action.get_child(0).text]])
			if input_dict[actionsName[action.get_child(0).text]] != 999:
				#action.get_child(1).text = xbox_button[input_dict[actionsName[action.get_child(0).text]]]
				action.get_child(1).icon = load("res://Menu/Buttons/Controller_Pics/" + xbox_button_pics[input_dict[actionsName[action.get_child(0).text]]] + ".png")
func _on_controller_button_pressed():
	if currentControllerType == null:
		pass
	else:
		currentMode = mode.CONTROLLER
		movementContainer.visible = false
		seperateContainer.visible = false
		displayInputController(currentInputMappedController)
	
func _on_keyboard_button_pressed():
	currentMode = mode.KEYBOARD
	movementContainer.visible = true
	seperateContainer.visible = true
	displayInputKeyboard(currentInputMappedKeyboard)
	
func _on_button_Move_Up_pressed():
	currentAction = "Move_Up"
	edit = true
	container.visible = false
	inputPanel.visible = true

func _on_button_Move_down_pressed():
	currentAction = "Move_Down"
	edit = true
	container.visible = false
	inputPanel.visible = true

func _on_button_Move_Right_pressed():
	currentAction = "Move_Right"
	edit = true
	container.visible = false
	inputPanel.visible = true
	
func _on_button_Move_Left_pressed():
	currentAction = "Move_Left"
	edit = true
	container.visible = false
	inputPanel.visible = true

func _on_button_Jump_pressed():
	currentAction = "Jump"
	edit = true
	container.visible = false
	inputPanel.visible = true
	
func _on_button_Dash_pressed():
	currentAction = "Dialogue"
	edit = true
	container.visible = false
	inputPanel.visible = true

func _on_button_Wall_Run_pressed():
	currentAction = "WallRun"
	edit = true
	container.visible = false
	inputPanel.visible = true

func _on_button_Attack_pressed():
	currentAction = "Attack"
	edit = true
	container.visible = false
	inputPanel.visible = true

func _on_button_Block_pressed():
	currentAction = "Hook"
	edit = true
	container.visible = false
	inputPanel.visible = true

func _on_button_default_pressed():
	currentInputMappedKeyboard = defaultInputKeyboard
	currentInputMappedController = defaultInputController
	if currentMode == mode.KEYBOARD:
		displayInputKeyboard(currentInputMappedKeyboard)
	elif currentMode == mode.CONTROLLER:
		displayInputController(currentInputMappedController)

func _input(event):
	if (event is InputEventKey):
		#print(event.keycode)
		pass
	if edit :
		var targetEvent
		if currentMode == mode.KEYBOARD:
			if event is InputEventKey:
				var duplicate = false
				for e in currentInputMappedKeyboard:
					if currentInputMappedKeyboard[e] == event.keycode:
						duplicate = true
				print(duplicate)
				var string
				string = OS.get_keycode_string(event.keycode)
				if (!string in cannotMappedKeyboard):
					if not duplicate:
						currentInputMappedKeyboard[currentAction] = event.keycode
						edit = false
						inputPanel.visible = false
						container.visible = true
						#saveButton.grab_focus()
				displayInputKeyboard(currentInputMappedKeyboard)
			if event is InputEventMouseButton:
				var duplicate = false
				for e in currentInputMappedKeyboard:
					if currentInputMappedKeyboard[e] == event.button_index:
						duplicate = true
				if not duplicate:
					currentInputMappedKeyboard[currentAction] = event.button_index
					edit = false
					inputPanel.visible = false
					container.visible = true
					#saveButton.grab_focus()
				displayInputKeyboard(currentInputMappedKeyboard)
			keyboardButton.grab_focus()
		if currentMode == mode.CONTROLLER:
			if event is InputEventJoypadButton and event.is_pressed():
				#print(event.button_index)
				var duplicate = false
				for e in currentInputMappedController:
					if currentInputMappedController[e] == event.button_index:
						#print(currentInputMappedController[e])
						duplicate = true
				if (event.button_index not in cannotMappedController and not duplicate and event.button_index != 4):
					currentInputMappedController[currentAction] = event.button_index
					edit = false
					inputPanel.visible = false
					container.visible = true
				displayInputController(currentInputMappedController)
			if event is InputEventJoypadMotion:
				if event.axis == 4 || event.axis == 5:
					var duplicate = false
					for e in currentInputMappedController:
						if currentInputMappedController[e] == event.axis:
							#print(currentInputMappedController[e])
							duplicate = true
					if (event.axis not in cannotMappedController and not duplicate):
						currentInputMappedController[currentAction] = event.axis
						edit = false
						inputPanel.visible = false
						container.visible = true
				displayInputController(currentInputMappedController)
			controllerButton.grab_focus()		

func setupInput(inputKeyboard:Dictionary,inputController:Dictionary):
	for action in inputKeyboard:
		var targetEvent = InputMap.action_get_events(action)
		InputMap.action_erase_events(action)
		var newKeyboard = InputEventKey.new()
		newKeyboard.keycode = inputKeyboard[action]
		InputMap.action_add_event(action,newKeyboard)
		var newController
		if action == "Move_Up":
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

