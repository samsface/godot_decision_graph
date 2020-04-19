extends Control

onready var graph_edit_ : GraphEdit = get_node("/root/controller/vbox/splitter/graph_edit")
onready var properties_ : GraphEdit = get_node("/root/controller/vbox/splitter/properties")

var graph_    := DecisionGraph.new()
var messages_ := []

func save_() -> void:
	var nodes := []
	for node in graph_.nodes:
		var n := { 
			"id":           node.id, 
			"display_name": node.display_name,
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
		var node          := BayNode.new()
		node.id            = n.id
		node.display_name  = n.display_name
		node.position      = Vector2(n.x, n.y)
		#node.test_value   = n.get("test_value")
		ids[node.id]       = node
		graph_.nodes[node] = node

		graph_edit_.add_node(node)
		set_node_test_value(node, node.test_value)

	for n in net:
		for os in range(0, n.output_slots.size()):
			for output in n.output_slots[os]:
				if ids.has(n.id) and ids.has(output):
					var node_a = ids[n.id]
					var node_b = ids[output]
					connect_nodes(node_a, os, node_b)

func test_() -> void:
	graph_.test()
	graph_edit_.invalidate()

func clear_test_values_() -> void:
	graph_.clear_values()
	graph_edit_.invalidate()

func _ready():
	randomize()
	load_()

func add_node(position : Vector2) -> void:
	var node := graph_.add_node(position)
	graph_edit_.add_node   (node)
	properties_.select_node(node)
	
func remove_node(node : BayNode) -> void:
	for input in node.inputs:
		disconnect_nodes(input, node)

	for output_slot in node.output_slots:
		for output in output_slot:
			disconnect_nodes(node, output)

	graph_.nodes.erase(node)
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
	graph_edit_.connect_nodes(node_a, slot_a, node_b)
	properties_.select_node(node_b)

func disconnect_nodes(node_a : BayNode, node_b : BayNode) -> void:
	node_a.output_slots[node_a.get_output_slot_idx(node_b)].erase(node_b)
	node_b.inputs.erase(node_a)
	graph_edit_.disconnect_nodes(node_a, node_b)

func set_node_test_value(node : BayNode, new_test_value) -> void:
	node.test_value = new_test_value
	graph_edit_.set_node_test_value(node, new_test_value)
	test_()

func _on_save_button_up() -> void:
	save_()

func _on_test_button_up():
	test_()

func _on_clear_test_values_button_up():
	clear_test_values_()

var opacity_ = 1.0
func _on_only_show_selected_toggled(button_pressed : bool):
	opacity_ = 0.1 if button_pressed else 1.0
	graph_edit_.invalidate()

func _on_make() -> void:
	graph_.make()
