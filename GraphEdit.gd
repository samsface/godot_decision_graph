extends GraphEdit

onready var controller_ := get_node("/root/controller")

var selected_   = null
var node_gui_  := preload("GraphNode.tscn")
var node_guis_ := {}

func invalidate() -> void:
	for node_gui in node_guis_.values():
		node_gui.invalidate()

func add_node(node : BayNode) -> void:
	var node_gui := node_gui_.instance()
	node_gui.data   = node
	add_child(node_gui)
	node_gui.offset = node.position
	node_guis_[node.id] = node_gui
	rename_node(node)

func remove_node(node : BayNode) -> void:
	remove_child(node_guis_[node.id])
	update()

func select_node(node : BayNode) -> void:
	selected_ = node
	for n in node_guis_:
		node_guis_[n].focus(node_guis_[n].data.is_connected_to(node))

func rename_node(node : BayNode) -> void:
	node_guis_[node.id].title = node.display_name
	
func set_node_test_value(node : BayNode, new_test_value) -> void:
	node_guis_[node.id].invalidate()

func connect_nodes(node_a : BayNode, slot_a : int, node_b : BayNode) -> void:
	connect_node(node_guis_[node_a.id].name, slot_a, node_guis_[node_b.id].name, node_b.inputs.size() - 1)
	node_guis_[node_b.id].invalidate()

func disconnect_nodes(node_a : BayNode, node_b : BayNode) -> void:
	var node_a_name = node_guis_[node_a.id].name
	var node_b_name = node_guis_[node_b.id].name

	for connection in get_connection_list():
		if connection.from == node_a_name and connection.to == node_b_name:
			disconnect_node(connection.from, connection.from_port, connection.to, connection.to_port)
	
	for input in node_b.inputs:
		for i in range(0, node_b.inputs.size() + 1):
			for j in range(node_b.values.size()):
				disconnect_node(node_guis_[input.id].name, j, node_guis_[node_b.id].name, i)

	var i := 0
	for input in node_b.inputs:
		for o in range(0, input.output_slots.size()):
			if node_b in input.output_slots[o]:
				connect_node(node_guis_[input.id].name, o, node_guis_[node_b.id].name, i)

		i += 1

	node_guis_[node_b.id].invalidate()

func _ready():
	pass

func _on_node_selected(graph_node : GraphNode) -> void:
	controller_.select_node(graph_node.data)

func _on_connection_request(from : String, from_slot : int, to : String, to_slot : int) -> void:
	if from == to: return
	controller_.connect_nodes(get_node(from).data, from_slot, get_node(to).data)

func _on_gui_input(event) -> void:
	if event is InputEventMouseButton:
		if event.doubleclick:
			controller_.add_node(get_global_mouse_position() + scroll_offset)


func _on_disconnection_request(from, from_slot, to, to_slot):
	controller_.disconnect_nodes(get_node(from).data, get_node(to).data)

func _on_end_node_move():
	var new_positions = []
	for node_gui in node_guis_.values():
		new_positions.append({"node": node_gui.data, "position": node_gui.offset})
	controller_.move_node(new_positions)
