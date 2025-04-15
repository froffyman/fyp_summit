extends Control
class_name DialogueComponent

@export_file("*.json") var dialogue_data 
var dialogue = []
var current_line = -1

var line_length = 0

@onready var box_name = %Name
@onready var content = %Content

signal custom_sig
signal dialogue_ended
signal offer_quest

# Called when the node enters the scene tree for the first time.
func _ready():
	var ddata_open = FileAccess.open(dialogue_data, FileAccess.READ)
	dialogue = JSON.parse_string(ddata_open.get_as_text())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if content.visible_characters < line_length:
		content.visible_characters += 1

func dialogue_init():
	SignalManager.chat_update.emit(true)
	visible = true
	current_line = -1
	next_line()

func dialogue_end():
	SignalManager.chat_update.emit(false)
	visible = false
	dialogue_ended.emit()
	

func next_line():
	if content.visible_characters == line_length:
		if current_line != -1 and dialogue[current_line]["type"] == "quest":
				offer_quest.emit()
		else:
			if current_line < len(dialogue) - 1:
				current_line += 1
				box_name.text = dialogue[current_line]["name"]
				content.text = dialogue[current_line]["content"]
				line_length = len(dialogue[current_line]["content"])
				content.visible_characters = 0
			else:
				dialogue_end()
	else: #Skip to the end of a line
		content.visible_characters = line_length
