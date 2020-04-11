extends Control

onready var graph_edit_ : GraphEdit = get_node("/root/controller/vbox/splitter/graph_edit")
onready var properties_ : GraphEdit = get_node("/root/controller/vbox/splitter/properties")

var net_      := {}
var messages_ := []

func save_() -> void:
	var res := []
	for node in net_:
		var n := { 
			"id":           node.id, 
			"display_name": node.display_name,
			"values":       node.values,
			"cpt":          node.cpt_table,
			"inputs":       [], 
			"outputs":      [], 
			"x":            node.position[0],
			"y":            node.position[1],
			"test_value":   node.test_value
		}
		
		for input in node.inputs:
			n.inputs.append(input.id)
			
		for outputs in node.outputs:
			n.outputs.append(outputs.id)
			
		res.append(n)
		
	var file = File.new()
	file.open("ting.save", File.WRITE)
	file.store_line(to_json(res))
	file.close()

func load_() -> void:
	var file := File.new()
	if not file.file_exists("ting.save"):
		return
		
	var data := ""
	file.open("ting.save", File.READ)
	while not file.eof_reached():
		data += file.get_line()

	var ids := {}

	var net = parse_json(data)
	for n in net:
		var node         := BayNode.new()
		node.id           = n.id
		node.display_name = n.display_name
		node.values       = n.values
		node.cpt_table    = n.cpt
		node.position     = Vector2(n.x, n.y)
		node.test_value   = n.get("test_value")
		ids[node.id]      = node
		net_[node]        = node

		graph_edit_.add_node(node)
		set_node_test_value(node, node.test_value)
		
	for n in net:
		for output in n.outputs:
			if ids.has(n.id) and ids.has(output):
				var node_a = ids[n.id]
				var node_b = ids[output]
				node_a.outputs[node_b] = node_b
				node_b.inputs [node_a] = node_a
				graph_edit_.connect_nodes(node_a, node_b)
				properties_.select_node(node_b)

func query_() -> void:
	print(0)
	

func _ready():
	randomize()
	load_()
	
	query_()

func add_node(position : Vector2) -> void:
	var node          := BayNode.new()
	node.id            = String(randi())
	node.display_name  = "node_" + String(net_.size())
	node.position      = position
	
	net_[node] = node
	
	graph_edit_.add_node   (node)
	properties_.select_node(node)
	
func remove_node(node : BayNode) -> void:
	net_.erase(node)
	graph_edit_.remove_node(node)
	properties_.select_node(null)

func select_node(node : BayNode) -> void:
	graph_edit_.select_node(node)
	properties_.select_node(node)

func move_node(node : BayNode, new_position : Vector2) -> void:
	node.position = new_position

func rename_node(node : BayNode, new_name : String) -> void:
	node.display_name = new_name
	graph_edit_.rename_node(node)

func connect_nodes(node_a : BayNode, node_b : BayNode) -> void:
	if node_b in node_a.outputs: return

	node_a.outputs[node_b] = node_b
	node_b.inputs [node_a] = node_a
	node_b.update_cpt_table()
	graph_edit_.connect_nodes(node_a, node_b)
	properties_.select_node(node_b)
	
func disconnect_nodes(node_a : BayNode, node_b : BayNode) -> void:
	graph_edit_.disconnect_nodes(node_a, node_b)
	node_a.outputs.erase(node_b)
	node_b.inputs .erase(node_a)
	node_b.update_cpt_table()

func set_node_test_value(node : BayNode, new_test_value) -> void:
	node.test_value = new_test_value
	graph_edit_.set_node_test_value(node, new_test_value)

func set_node_cpt_value(node : BayNode, row_idx : int, value_idx : int, new_value : float) -> void:
	node.cpt_table[row_idx].prob[value_idx] = new_value

func _on_save_button_up() -> void:
	save_()
