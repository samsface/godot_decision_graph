extends LineEdit

signal value_changed

var regex            := RegEx.new()
var last_good_text_ := ""

func _ready() -> void:
	regex.compile("(^$|[0-9.])")

func _on_text_changed(new_text : String) -> void:
	emit_signal("value_changed", float(new_text))
