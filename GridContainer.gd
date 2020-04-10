extends GridContainer

var node_ = null

func _ready():
	pass

func set_node(node):
	node_ = node
	
	if node_ == null: return
	
	columns = node_.connections.size()
