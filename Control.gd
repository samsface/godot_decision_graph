extends Control

onready var controller_            := get_node("/root/controller")
onready var name_   : LineEdit      = $vbox/grid/name_edit
onready var test_   : OptionButton  = $vbox/grid/test
onready var values_ : LineEdit      = $vbox/grid/values
onready var grid_   : GridContainer = $vbox/scroll/grid

var number_edit_ := preload("NumberEdit.tscn")
var node_ = null

func select_node(node):
	node_ = node
	
	if node_ == null:
		name_.text     = ""
		name_.editable = false
		

		return
	
	name_.editable = true
	name_.text     = node.display_name
	
	$vbox/condition_text.text = ""
	for input in node.inputs:
		if node in input.output_slots[0]:
			$vbox/condition_text.text += input.display_name + "\n"
		else:
			$vbox/condition_text.text += "NOT " + input.display_name + "\n"
	
	#values_.text = PoolStringArray(node_.values).join(",")

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

func _on_values_text_changed(new_values : String):
	controller_.set_node_values(node_, new_values.split(","))

func _on_test_edit_item_selected(id):
	controller_.set_node_test_value(node_, id - 1)
