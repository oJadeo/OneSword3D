extends Node3D

func _ready():
	deactivate()
func activate():
	for e in self.get_children() :
		if e is MeshInstance3D :
			e.set_visible(true)
		if e is Transporter :
			e.activate()
		while not (e is CollisionShape3D) :
			e = e.get_children()[0]
		e.disabled = false
func deactivate():
	for e in self.get_children() :
		if e is MeshInstance3D :
			e.set_visible(false)
		if e is Transporter :
			e.deactivate()
		while not (e is CollisionShape3D) :
			e = e.get_children()[0]
		e.disabled = true
