extends NinePatchRect

@onready var giver_img = %QuestGiver
@onready var title = %QuestTitle
@onready var prog_title = %QuestProg_title
@onready var prog = %QuestProg

@onready var sig_list = SignalManager.get_signal_list()

var prog_num: int = 0
var max_prog: int = 1

var sig_name: String
var completed: bool = false
var stat: String

func complete():
	completed = true
	title.modulate = Color.CHARTREUSE
	prog_title.modulate = Color.CHARTREUSE
	prog.modulate = Color.CHARTREUSE

func make_quest_save():
	var quest_data: quest = quest.new()
	
	quest_data.quest_giver = giver_img.texture
	quest_data.title = title.text
	quest_data.prog_title = prog_title.text
	quest_data.prog = prog_num
	quest_data.goal = max_prog
	quest_data.signal_name = sig_name
	quest_data.stat = stat
	
	return quest_data

func set_quest(quest_res: quest):
	var new_giver: CompressedTexture2D = quest_res.quest_giver
	var new_title: String = quest_res.title
	var new_prog_title: String = quest_res.prog_title
	var new_max: int = quest_res.goal
	
	sig_name = quest_res.signal_name
	SignalManager.connect(sig_name, increment_prog)
	
	prog_num = quest_res.prog
	prog.text = str(prog_num)
	max_prog = new_max
	if prog_num >= max_prog:
		complete()
	stat = quest_res.stat
	
	giver_img.texture = new_giver
	title.text = new_title
	prog_title.text = new_prog_title

func increment_prog():
	if prog_num < max_prog:
		prog_num += 1
		prog.text = str(prog_num)
	
	if prog_num >= max_prog:
		complete()


func _on_gui_input(event):
	if Input.is_action_just_pressed("click") and completed:
		SignalManager.quest_reward.emit(stat, 30)
		queue_free()
