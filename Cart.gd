extends Object
class_name CarNode

var id           := ""
var display_name := ""
var values       := [0, 1]
var cpt_table    := [{"inputs": [], "prob": values.duplicate()}]
var inputs       := {}
var outputs      := {}
var position     := Vector2()
var test_value    = null

func cartesian_product_(pools : Array) -> Array:
	var results = [[]]
	for p in pools:
		var temp = []
		for res in results:
			for element in p:
				temp.append(res + [element])
		results = temp
	
	return results

func update_cpt_table() -> void:
	var pools := []
	for input in inputs:
		pools.append(input.values)

	var cp := cartesian_product_(pools)
	
	var new_cpt_table := []
	
	for row in cp:
		new_cpt_table.append({"inputs": row, "prob": values.duplicate()})
		
	cpt_table = new_cpt_table
