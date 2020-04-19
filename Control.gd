extends Control

onready var controller_            := get_node("/root/controller")
onready var name_   : LineEdit      = $vbox/grid/name_edit
onready var test_   : OptionButton  = $vbox/grid/test_edit
var node_                           = null

func select_node(node):
	node_ = node

	if node_ == null:
		name_.text     = ""
		name_.editable = false
		return
	
	test_.disabled = node_.inputs.size() != 0

	name_.editable = true
	name_.text     = node.display_name
	
	$vbox/condition_text.text = ""
	for input in node.inputs:
		if node in input.output_slots[0]:
			$vbox/condition_text.text += input.display_name + "\n"
		else:
			$vbox/condition_text.text += "NOT " + input.display_name + "\n"

func _ready():
	select_node(null)

func _on_name_text_changed(new_text : String):
	controller_.rename_node(node_, new_text)

func _on_test_edit_item_selected(id):
	controller_.set_node_test_value(node_, id - 1)
