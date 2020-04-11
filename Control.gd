extends Control

onready var controller_          := get_node("/root/controller")
onready var name_ : LineEdit      = $vbox/grid/name
onready var test_ : OptionButton  = $vbox/grid/test
onready var grid_ : GridContainer = $vbox/scroll/grid

var number_edit_ := preload("NumberEdit.tscn")
var node_ = null

func select_node(node):
	node_ = node
	
	if node_ == null:
		name_.text     = ""
		name_.editable = false
		
		for child in grid_.get_children():
			grid_.remove_child(child)
		
		return
	
	name_.editable = true
	name_.text     = node.display_name

	test_.clear()
	test_.add_item("")
	var s = 0
	for value in node_.values:
		test_.add_item(String(value))
		
		if node_.test_value == value:
			s = test_.get_item_count() - 1

	test_.select(s)

	grid_.columns  = node_.inputs.size() + node_.values.size()
	
	for child in grid_.get_children():
		grid_.remove_child(child)
	
	for n in node_.inputs:
		grid_.add_child(make_label_(n.display_name))
		
	for v in node_.values:
		grid_.add_child(make_label_("P(" + String(v) + ")"))
		
	for r in range(node_.cpt_table.size()):
		for value in node_.cpt_table[r].inputs:
			grid_.add_child(make_label_(value))
			
		for v in range(node_.cpt_table[r].prob.size()):
			var edit  = number_edit_.instance()
			edit .text = String(node_.cpt_table[r].prob[v])
			edit .connect("value_changed", self, "_on_cpt_value_changed", [r, v])
			grid_.add_child(edit )

func make_label_(value) -> Label:
	var label  = LineEdit.new()
	label.text = String(value)
	label.editable = false
	return label

func _ready():
	select_node(null)

func _on_name_text_changed(new_text : String):
	controller_.rename_node(node_, new_text)

func _on_cpt_value_changed(new_value : float, r : int, v : int) -> void:
	controller_.set_node_cpt_value(node_, r, v, new_value)

func _on_test_item_selected(id : int):
	var value = node_.values[test_.selected - 1] if test_.selected > 0 else null
	controller_.set_node_test_value(node_, value)
