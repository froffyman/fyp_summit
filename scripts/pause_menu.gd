extends NinePatchRect

signal quit_to_menu

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func unpause():
	Engine.time_scale = 1.0
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("pause"):
		unpause()
		call_deferred("queue_free")



func _on_quit_gui_input(event):
	if Input.is_action_just_pressed("click"):
		Engine.time_scale = 1.0
		quit_to_menu.emit()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_resume_gui_input(event):
	if Input.is_action_just_pressed("click"):
		unpause()
