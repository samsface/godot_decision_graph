extends GraphNode

onready var controller_ := get_node("/root/controller")

var data        = null
var is_focused_ := false
var temp_focus_ := false

var input_colors_  = [Color.purple]
var output_colors_ = [Color.green, Color.red]

func focus(value : bool) -> void:
	is_focused_ = value
	invalidate()

func invalidate() -> void:
	var inputs_count        = data.inputs.size() + 1
	var outputs_count       = data.values.size()
	var invalid_child_count = get_children().size()
	var size                = max(inputs_count, outputs_count)
	var is_focused          = is_focused_ or temp_focus_
	var value               = data.test_value if data.test_value != -1 else data.value

	$test_1_button.visible = inputs_count == 1
	$test_0_button.visible = inputs_count == 1
	
	#$test_1_button.pressed = data.test_value == 1
	#$test_0_button.pressed = data.test_value == 0

	for i in range(0, size):
		if i >= invalid_child_count:
			var label := Label.new()
			add_child(label)
		var color_a = input_colors_[i % input_colors_.size()]
		var color_b = output_colors_[i % output_colors_.size()]
		color_a[3] = 1.0 if is_focused else pow(controller_.opacity_, 2)
		color_b[3] = 1.0 if is_focused else pow(controller_.opacity_, 2)
		set_slot(i, i < inputs_count, 0, color_a, i < outputs_count, 0, color_b)

	for i in range(size, invalid_child_count):
		remove_child(get_children()[i])

	modulate = Color.white

	if value == 0:
		modulate[0] = 2
	elif value == 1:
		modulate[1] = 2

	if is_focused:
		modulate[3] = 1
	else:
		modulate[3] = controller_.opacity_

func _ready():
	invalidate()

func _on_close_request():
	controller_.remove_node(data)

func _on_mouse_entered():
	temp_focus_ = true
	invalidate()

func _on_mouse_exited():
	temp_focus_ = false
	invalidate()

func _on_test_1_button_mouse_entered():
	temp_focus_ = true
	invalidate()

func _on_test_0_button_mouse_entered():
	temp_focus_ = true
	invalidate()

func _on_test_1_button_mouse_exited():
	temp_focus_ = false
	invalidate()

func _on_test_0_button_mouse_exited():
	temp_focus_ = false
	invalidate()

func _on_test_0_button_toggled(button_pressed : bool):
	if button_pressed:
		$test_1_button.pressed = false
	controller_.set_node_test_value(data, 0 if button_pressed else - 1)

func _on_test_1_button_toggled(button_pressed : bool):
	if button_pressed:
		$test_0_button.pressed = false
	controller_.set_node_test_value(data, 1 if button_pressed else - 1)

