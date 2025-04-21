extends Control

@onready var main_buttons = %MainButtons
@onready var save_file_container = %SaveFileContainer
@onready var save_file_scrollbox = %SaveFileScrollbox
@onready var add_file = %AddFile

var current_file = 1

func _ready():
	var user_files = DirAccess.open("user://").get_files()
	for file in user_files:
		var new_file = preload("res://scenes/save_file_container.tscn").instantiate()
		new_file.id = current_file
		new_file.size_flags_horizontal = Control.SIZE_FILL
		new_file.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		save_file_scrollbox.add_child(new_file)
		var index = add_file.get_index()
		save_file_scrollbox.move_child(new_file, index)
		
		new_file.gui_input.connect(load_file.bind(new_file.id))
		
		current_file += 1
	if current_file > 3:
		add_file.visible = false
			

func load_file(event, id: int):
	if Input.is_action_just_pressed("click"):
		SaveManager.file_id = id
		var village = SaveManager.load_village()
		if village != null:
			get_tree().change_scene_to_packed(village)
		else:
			get_tree().change_scene_to_file("res://scenes/game.tscn")
		
	

func _on_play_gui_input(event):
	if Input.is_action_just_pressed("click"):
		main_buttons.visible = false
		save_file_container.visible = true

func _on_back_gui_input(event):
	if Input.is_action_just_pressed("click"):
		main_buttons.visible = true
		save_file_container.visible = false

func _on_add_file_gui_input(event):
	if Input.is_action_just_pressed("click"):
		SaveManager.file_id = current_file
		
		var inv = Inv.new()
		inv.slots.resize(16)
		for i in range(inv.slots.size()):
			inv.slots[i] = InvSlot.new()
		var hotbar = Inv.new()
		hotbar.slots.resize(9)
		for i in range(hotbar.slots.size()):
			hotbar.slots[i] = InvSlot.new()
		
		SaveManager.save(PlrStats.new(), inv, hotbar)
		get_tree().change_scene_to_file("res://scenes/game.tscn")
		


func _on_quit_gui_input(event):
	if Input.is_action_just_pressed("click"):
		get_tree().quit()

func display_buttons():
	main_buttons.visible = true

func _on_how_to_gui_input(event):
	if Input.is_action_just_pressed("click"):
		var how_to_menu = preload("res://scenes/how_to_menu.tscn").instantiate()
		main_buttons.visible = false
		add_child(how_to_menu)
		how_to_menu.exit.connect(display_buttons)
