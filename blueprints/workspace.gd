extends Viewport

func _on_value_pressed():
	addblock(preload("res://blueprints/blocks/value.tscn").instance())
func addblock(block:Panel):
	add_child(block)
	block.rect_position=$camera.position


func _on_method_pressed():
	addblock(preload("res://blueprints/blocks/function.tscn").instance())
