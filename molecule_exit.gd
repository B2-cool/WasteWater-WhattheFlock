extends Area2D
class_name MoleculeExit

var outflows = {
	"ammonia": 0,
	"carbon": 0,
	"nitrate": 0,
	"nitrite": 0,
	"phosphorus": 0,
}

func _on_body_entered(body: Node2D) -> void:
	for moleculeType in outflows:
		if body.is_in_group("outflow_" + moleculeType):
			outflows[moleculeType] += 1
			#print("Molecule exited: " + moleculeType)
	
	body.queue_free()

func clear():
	for moleculeType in outflows:
		outflows[moleculeType] = 0
