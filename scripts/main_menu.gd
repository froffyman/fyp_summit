extends Control

@onready var main_buttons = %MainButtons
@onready var save_file_container = %SaveFileContainer
@onready var save_file_scrollbox = %SaveFileScrollbox
@onready var add_file = %AddFile

func _on_play_gui_input(event):
	if Input.is_action_just_pressed("click"):
		main_buttons.visible = false
		save_file_container.visible = true


func _on_back_gui_input(event):
	if Input.is_action_just_pressed("click"):
		main_buttons.visible = true
		save_file_container.visible = false

func go_to_village(event):
	if Input.is_action_just_pressed("click"):
		get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_add_file_gui_input(event):
	if Input.is_action_just_pressed("click"):
		var new_file = preload("res://scenes/save_file_container.tscn").instantiate()
		new_file.size_flags_horizontal = Control.SIZE_FILL
		new_file.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		new_file.gui_input.connect(go_to_village)
		save_file_scrollbox.add_child(new_file)
		var index = add_file.get_index()
		save_file_scrollbox.move_child(new_file, index)
		
