extends NinePatchRect

@export var plr: Player

@onready var quest_container = %VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.new_quest.connect(add_quest)
	var saved_quests = SaveManager.load_quests()
	for i in range(len(saved_quests)):
		add_quest(saved_quests[i])

func all_quest_data():
	if quest_container.get_child_count() > 0:
		var active_quests = quest_container.get_children()
		var quest_arr: Array[quest]
		quest_arr.resize(quest_container.get_child_count())
		
		for i in range(quest_container.get_child_count()):
			quest_arr[i] = active_quests[i].make_quest_save()
		return quest_arr
	return null

func add_quest(q: quest):
	var new_quest_info = preload("res://scenes/quest_info.tscn").instantiate()
	quest_container.add_child(new_quest_info)
	new_quest_info.set_quest(q)

func _on_v_box_container_child_entered_tree(node):
	if not visible:
		visible = true


func _on_v_box_container_child_exiting_tree(node):
	if quest_container.get_child_count() == 0:
		visible = false 
