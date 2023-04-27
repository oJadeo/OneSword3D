extends CanvasLayer

var dialogue = []
var current_dialogue = 0
@onready var dialogue_box = $HBoxContainer
@onready var name_label = $HBoxContainer/NameLabel
@onready var message_label = $HBoxContainer/MessageLabel
@onready var button = $HBoxContainer/Button

var dialogue_activate = false

# Called when the node enters the scene tree for the first time.
func _ready():
	dialogue_box.visible = false

func start(file):
	if dialogue_activate:
		return
	get_tree().call_group("dialogue",end_dialogue())
	dialogue_activate = true
	dialogue_box.visible = true
	dialogue=load_dialogue(file)
	current_dialogue = 0
	change_name(dialogue[current_dialogue]['name'])
	change_text(dialogue[current_dialogue]['message'])
	
func load_dialogue(file):
	return  file.get_data()
	
	
func change_name(new_name):
	name_label.text = new_name+":"
	
func change_text(new_text):
	message_label.text = new_text
	
func change_button(new_button):
	button.text = new_button
	
	
func _input(event):
	if event.is_action_pressed("Dialogue"):
		current_dialogue += 1
		
		if current_dialogue >= len(dialogue):
			end_dialogue()
			return
		
		change_name(dialogue[current_dialogue]['name'])
		change_text(dialogue[current_dialogue]['message'])

func end_dialogue():
	dialogue_box.visible = false
