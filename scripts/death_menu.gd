extends NinePatchRect


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_respawn_gui_input(event):
	if Input.is_action_just_pressed("click"):
		get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_quit_gui_input(event):
	if Input.is_action_just_pressed("click"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
