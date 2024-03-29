extends Node3D

var enemy_node = {
	'MeleeEnemy':preload("res://Enemy/MeleeEnemy/S_MeleeEnemy.tscn"),
	'RangeEnemy':preload("res://Enemy/RangeEnemy/S_RangeEnemy.tscn"),
	'MortarEnemy':preload("res://Enemy/MortarEnemy/S_MortarEnemy.tscn"),
}
var enemy_list = {}
var activate = false
@export var activater : NodePath
# Called when the node enters the scene tree for the first time.
func _ready():
	for enemy in enemy_node:
		enemy_list[enemy] = []
	enemy_list['MortarRange'] = {}
	for child in get_children():
		if child is MeleeEnemy:
			enemy_list['MeleeEnemy'].append(child.get_position())
		if child is RangeEnemy:
			enemy_list['RangeEnemy'].append(child.get_position())
		if child is MortarEnemy:
			enemy_list['MortarEnemy'].append(child.get_position())
			enemy_list['MortarRange'][child.get_position()]=child.mortarRange


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_child_count() == 0 and not activate:
		trigger()
		activate = true

func trigger():
	var node = get_node(activater)
	if node and node.has_method('activate'):
		node.activate()
		

func respawn():
	for child in get_children():
		child.queue_free()
		
	for enemy in enemy_list:
		if enemy == 'MortarRange':
			continue
		for pos in enemy_list[enemy]:
			var new_enemy = enemy_node[enemy].instantiate()
			add_child(new_enemy)
			new_enemy.set_position(pos)
			if enemy == 'MortarEnemy':
				new_enemy.set_range(enemy_list['MortarRange'][pos])
	
	activate = false
	if activater:
		var node = get_node(activater)
		if node and node.has_method('deactivate'):
			node.deactivate()
