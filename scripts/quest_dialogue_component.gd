extends Control
class_name QuestDialogueComponent

@export var quest_res: quest

@onready var quest_name = %Name
@onready var quest_content = %Content

signal quest_accepted
signal quest_denied

func _ready():
	quest_content.text = quest_res.title

func selection_made():
	SignalManager.chat_update.emit(false)
	visible = false

func _on_accept_gui_input(event):
	if Input.is_action_just_pressed("click"):
		SignalManager.new_quest.emit(quest_res)
		quest_accepted.emit()
		selection_made()


func _on_deny_gui_input(event):
	if Input.is_action_just_pressed("click"):
		quest_denied.emit()
		selection_made()
