extends Object
class_name DecisionGraph

var nodes := {}

func add_node(position : Vector2) -> BayNode:
	var node          := BayNode.new()
	node.id            = String(randi())
	node.display_name  = "node_" + String(nodes.size())
	node.position      = position
	nodes[node]        = node
	
	return node

func clear_values() -> void:
	for node in nodes:
		node.value = -1

func make():
	var uniforms := []
	var leafs    := []
	
	for node in nodes:
		if node.is_uniform(): uniforms.append(node)
		if node.is_leaf   (): leafs   .append(node)

	print(uniforms, leafs)

func test_node_(node : BayNode, collect : bool) -> int:
	var value = node.test_value if node.test_value != -1 else node.value
	
	if value == -1:
		for input in node.inputs:
			value = test_node_(input, true)
			if value == -1: break
			
			if input.output_slots[1].has(node):
				value = 1 if value == 0 else 0

			if value == 0: break
	
	if value == -1:           return value
	if node.test_value == -1: node.value = value
	
	if not collect:
		for output in node.output_slots[1 - value]:
			test_node_(output, false)
			
	return value

func test() -> void:
	var entry_node = null
	clear_values()
	
	for node in nodes:
		if node.display_name == "advr_known":
			entry_node = node
			break
			
	if	not entry_node:
		return

	test_node_(entry_node, false)
