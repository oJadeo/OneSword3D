extends Node3D

var enemy_node = {
	'MeleeEnemy':preload("res://Enemy/MeleeEnemy/S_MeleeEnemy.tscn"),
	'RangeEnemy':preload("res://Enemy/RangeEnemy/S_RangeEnemy.tscn"),
	'MortarEnemy':preload("res://Enemy/MortarEnemy/S_MortarEnemy.tscn")
}
var enemy_list = {}
var activate = false
@export var activater : NodePath
# Called when the node enters the scene tree for the first time.
func _ready():
	for enemy in enemy_node:
		enemy_list[enemy] = []
	for child in get_children():
		if child.is_in_group("Melee"):
			enemy_list['MeleeEnemy'].append(child.get_position())
		if child.is_in_group("Range"):
			enemy_list['RangeEnemy'].append(child.get_position())
		if child.is_in_group("Mortar"):
			enemy_list['MortarEnemy'].append(child.get_position())
	print(enemy_list)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_child_count() == 0 and not activate:
		trigger()
		activate = true

func trigger():
	print("yay")
	var node = get_node(activater)
	if node and node.has_method('activate'):
		node.activate()
		

func respawn():
	for child in get_children():
		child.queue_free()
		
	for enemy in enemy_list:
		for pos in enemy_list[enemy]:
			var new_enemy = enemy_node[enemy].instantiate()
			add_child(new_enemy)
			new_enemy.set_position(pos)
	
	activate = false
	if activater:
		var node = get_node(activater)
		if node and node.has_method('deactivate'):
			node.deactivate()
