extends Area3D


@onready var areaToBlock = $toBlock/StaticBody3d/CollisionShape3d
@onready var blockMesh = $toBlock/StaticBody3d/CollisionShape3d/MeshInstance3d

var activated = false
func _process(_delta):
	areaToBlock.disabled = not activated
	blockMesh.set_visible(activated)

func _on_trigger_block_area_body_entered(body):
	if (body.name == "PlayerCharacter") :
		activated = true
