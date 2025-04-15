extends CharacterBody2D

@onready var label_animator = %LabelAnimator

@export var player_detect: PlayerDetectComponent
@export var dialogue_component: DialogueComponent
@export var quest_dialogue: QuestDialogueComponent

var can_chat: bool = false
var chatting: bool = false

func _ready():
	if player_detect:
		player_detect.player_entered.connect(_on_area_2d_body_entered)
		player_detect.player_left.connect(_on_area_2d_body_exited)
	dialogue_component.dialogue_ended.connect(dialogue_finished)
	if quest_dialogue:
		quest_dialogue.quest_accepted.connect(dialogue_finished)
		quest_dialogue.quest_denied.connect(dialogue_finished)
		dialogue_component.offer_quest.connect(quest_offering)

func quest_offering():
	dialogue_component.visible = false
	quest_dialogue.visible = true

func _process(_delta):
	if can_chat and Input.is_action_just_released("interact"):
		if not chatting:
			label_animator.play("text_fall")
			chatting = true
			dialogue_component.dialogue_init()
		else:
			dialogue_component.next_line()

func _on_area_2d_body_entered(body):
	if body is Player:
		can_chat = true
		label_animator.play("text_rise")

func dialogue_finished():
	chatting = false
	can_chat = true
	label_animator.play("text_rise")

func _on_area_2d_body_exited(body):
	if body is Player:
		can_chat = false
		if not chatting: #Stop disappear animation playing when the label is already invisible
			label_animator.play("text_fall")
