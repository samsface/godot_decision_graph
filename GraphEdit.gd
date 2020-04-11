extends GraphEdit

onready var controller_ := get_node("/root/controller")

var selected_   = null
var node_gui_  := preload("GraphNode.tscn")
var	node_guis_ := {}

func add_node(node : BayNode) -> void:
	var node_gui := node_gui_.instance()
	add_child(node_gui)
	node_gui.data   = node
	node_gui.offset = node.position
	node_guis_[node.id] = node_gui
	rename_node(node)

func remove_node(node : BayNode) -> void:
	for n in node.inputs:
		disconnect_node(node_guis_[n.id].name, 0, node_guis_[node.id].name, 0)

	for n in node.outputs:
		disconnect_node(node_guis_[node.id].name, 0, node_guis_[n.id].name, 0)

	remove_child(node_guis_[node.id])
	update()

func select_node(node : BayNode) -> void:
	selected_ = node

func rename_node(node : BayNode) -> void:
	node_guis_[node.id].title = node.display_name
	
func set_node_test_value(node : BayNode, new_test_value) -> void:
	node_guis_[node.id].invalidate()

func connect_nodes(node_a : BayNode, node_b : BayNode) -> void:
	connect_node(node_guis_[node_a.id].name, 0, node_guis_[node_b.id].name, node_b.inputs.size() - 1)
	node_guis_[node_b.id].add_input()

func disconnect_nodes(node_a : BayNode, node_b : BayNode) -> void:
	for input in node_b.inputs:
		for i in range(0, node_b.inputs.size()):
			disconnect_node(node_guis_[input.id].name, 0, node_guis_[node_b.id].name, i)

	var i := 0
	for input in node_b.inputs:
		if input != node_a:
			connect_node(node_guis_[input.id].name, 0, node_guis_[node_b.id].name, i)
			i += 1

	node_guis_[node_b.id].remove_input()

func _ready():
	pass

func _on_node_selected(graph_node : GraphNode) -> void:
	controller_.select_node(graph_node.data)

func _on_connection_request(from : String, from_slot, to, to_slot) -> void:
	if from == to: return
	controller_.connect_nodes(get_node(from).data, get_node(to).data)

func _on_gui_input(event) -> void:
	if event is InputEventMouseButton:
		if event.doubleclick:
			controller_.add_node(get_global_mouse_position() + scroll_offset)

func _on_disconnection_request(from, from_slot, to, to_slot):
	controller_.disconnect_nodes(get_node(from).data, get_node(to).data)

func _on_end_node_move():
	controller_.move_node(selected_, node_guis_[selected_.id].offset)
