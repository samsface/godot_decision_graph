extends Object
class_name BayNode

var id           := ""
var display_name := ""
var values       := [0, 1]
var cpt_table    := [{"inputs": [], "prob": values.duplicate()}]
var inputs       := {}
var output_slots := [{}, {}]
var position     := Vector2()
var test_value   := -1
var value        := -1

func get_output_slot_idx(node : BayNode) -> int:
	for i in range(0, output_slots.size()):
		if node in output_slots[i]:
			return i
			
	return -1
	
func is_connected_to(node : BayNode) -> bool:
	if node == self: return true
	if get_output_slot_idx(node) != -1: return true
	return inputs.has(node)

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
	
	#print(inputs)
	#print(cp)
	
	for row in cp:
		new_cpt_table.append({"inputs": row, "prob": values.duplicate()})
		
	cpt_table = new_cpt_table
