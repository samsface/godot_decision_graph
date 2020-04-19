extends Object
class_name BayNode

var id           := ""
var display_name := ""
var values       := [0, 1]
var inputs       := {}
var output_slots := [{}, {}]
var position     := Vector2()
var test_value   := -1
var value        := -1

func is_uniform() -> bool:
	return inputs.size() == 0

func is_leaf() -> bool:
	return output_slots[0].size() + output_slots[1].size() == 0

func get_output_slot_idx(node : BayNode) -> int:
	for i in range(0, output_slots.size()):
		if node in output_slots[i]:
			return i
			
	return -1
	
func is_connected_to(node : BayNode) -> bool:
	if node == self: return true
	if get_output_slot_idx(node) != -1: return true
	return inputs.has(node)
