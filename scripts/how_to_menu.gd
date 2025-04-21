extends NinePatchRect

signal exit

func _on_back_gui_input(event):
	if Input.is_action_just_pressed("click"):
		exit.emit()
		queue_free()
