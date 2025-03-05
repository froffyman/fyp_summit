extends CharacterBody2D

@onready var label_animator = %LabelAnimator

var can_chat: bool = false

func _process(_delta):
	if can_chat and Input.is_action_just_released("interact"):
		print("we're talking now!")

func _on_area_2d_body_entered(body):
	if body is Player:
		can_chat = true
		label_animator.play("text_rise")


func _on_area_2d_body_exited(body):
	if body is Player:
		can_chat = false
		label_animator.play("text_fall")
