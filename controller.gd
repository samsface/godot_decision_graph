extends Control

onready var graph_edit_ : GraphEdit = get_node("/root/controller/vbox/splitter/graph_edit")
onready var properties_ : GraphEdit = get_node("/root/controller/vbox/splitter/properties")

var net_      := {}
var messages_ := []

func save_() -> void:
	var nodes := []
	for node in net_:
		var n := { 
			"id":           node.id, 
			"display_name": node.display_name,
			"values":       node.values,
			"cpt":          node.cpt_table,
			"inputs":       [], 
			"output_slots": [], 
			"x":            node.position[0],
			"y":            node.position[1],
			"test_value":   node.test_value
		}
		
		for input in node.inputs:
			n.inputs.append(input.id)
			
		for output_slot in node.output_slots:
			var a := []
			for output in output_slot:
				a.append(output.id)
			n.output_slots.append(a)
			
		nodes.append(n)
		
	var res = {
		"nodes": nodes, 
		"graph_edit_scroll_offset_x": graph_edit_.scroll_offset[0], 
		"graph_edit_scroll_offset_y": graph_edit_.scroll_offset[1]
	}
		
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

	var d = parse_json(data)
	graph_edit_.scroll_offset = Vector2(d.graph_edit_scroll_offset_x, d.graph_edit_scroll_offset_y)

	var ids := {}

	var net = d.nodes
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
		for os in range(0, n.output_slots.size()):
			for output in n.output_slots[os]:
				if ids.has(n.id) and ids.has(output):
					var node_a = ids[n.id]
					var node_b = ids[output]
					connect_nodes(node_a, os, node_b)

func test_node_(node : BayNode, collect : bool) -> int:
	var value = node.test_value if node.test_value != -1 else node.value
	
	if value == -1:
		for input in node.inputs:
			value = test_node_(input, true)
			if value == -1:
				break
			
			if input.output_slots[1].has(node):
				value = 1 if value == 0 else 0

			if value == 0:
				break
	
	if value == -1:
		print("not enough test data, can't test")
		return value
	
	if node.test_value == -1:
		node.value = value
	
	if not collect:
		for output in node.output_slots[1 - value]:
			test_node_(output, false)
			
	return value

func test_() -> void:
	var entry_node = null
	
	clear_test_values_()
	
	for node in net_:
		if node.display_name == "advr_known":
			entry_node = node
			break
			
	if	not entry_node:
		print("no entry node")
		return
		
	test_node_(entry_node, false)
	
	graph_edit_.invalidate()

func clear_test_values_() -> void:
	for node in net_:
		node.value = -1
		
	graph_edit_.invalidate()

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
	for input in node.inputs:
		disconnect_nodes(input, node)

	for output_slot in node.output_slots:
		for output in output_slot:
			disconnect_nodes(node, output)

	net_.erase(node)
	graph_edit_.remove_node(node)
	properties_.select_node(null)

func select_node(node : BayNode) -> void:
	graph_edit_.select_node(node)
	properties_.select_node(node)

func move_node(new_positions : Array) -> void:
	for new_position in new_positions:
		new_position.node.position = new_position.position

func rename_node(node : BayNode, new_name : String) -> void:
	node.display_name = new_name
	graph_edit_.rename_node(node)

func connect_nodes(node_a : BayNode, slot_a : int, node_b : BayNode) -> void:
	for output_slot in node_a.output_slots:
		if node_b in output_slot: 
			return

	node_a.output_slots[slot_a][node_b] = node_b
	node_b.inputs [node_a] = node_a
	node_b.update_cpt_table()
	graph_edit_.connect_nodes(node_a, slot_a, node_b)
	properties_.select_node(node_b)

func disconnect_nodes(node_a : BayNode, node_b : BayNode) -> void:
	node_a.output_slots[node_a.get_output_slot_idx(node_b)].erase(node_b)
	node_b.inputs.erase(node_a)
	node_b.update_cpt_table()
	graph_edit_.disconnect_nodes(node_a, node_b)

func set_node_test_value(node : BayNode, new_test_value) -> void:
	node.test_value = new_test_value
	graph_edit_.set_node_test_value(node, new_test_value)
	test_()

func set_node_values(node : BayNode, new_values : Array) -> void:
	node.values = new_values
	node.update_cpt_table()

func set_node_cpt_value(node : BayNode, row_idx : int, value_idx : int, new_value : float) -> void:
	node.cpt_table[row_idx].prob[value_idx] = new_value

func _on_save_button_up() -> void:
	save_()

func _on_test_button_up():
	test_()

func _on_clear_test_values_button_up():
	clear_test_values_()


var opacity_ = 0.5
func _on_opacity_slider_value_changed(value : float) -> void:
	opacity_ = value
	graph_edit_.invalidate()
