extends GraphNode

onready var controller_ := get_node("/root/controller")

var data = null

func add_input() -> void:
	var label := Label.new()
	add_child(label)
	set_slot(data.inputs.size(), true, 0, Color.green, false, 0, Color.green)
	
func remove_input() -> void:
	remove_child(get_child(get_child_count() - 1))

func _ready():
	set_slot(0, true, 0, Color.green, true, 0, Color.green)

func _on_close_request():
	controller_.remove_node(data)
