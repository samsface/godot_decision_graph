extends GraphNode

onready var controller_ := get_node("/root/controller")

var data    = null
var color_ := Color.green

func invalidate() -> void:
	if data.test_value != null:
		$test.text = String(data.test_value)
	else:
		$test.text = ""

func add_input() -> void:
	var label := Label.new()
	add_child(label)
	set_slot(data.inputs.size(), true, 0, color_, false, 0, color_)

func remove_input() -> void:
	remove_child(get_child(get_child_count() - 1))

func _ready():
	set_slot(0, true, 0, color_, true, 0, color_)

func _on_close_request():
	controller_.remove_node(data)
