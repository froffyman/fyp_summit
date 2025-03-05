extends AnimatableBody2D

@onready var rod = %Rod

signal done_swinging

func play_swing():
	rod.play("swing")

func flip():
	rod.flip_h = not rod.flip_h

func _on_rod_animation_finished():
	done_swinging.emit()

func clear_out(held_item):
	held_item.visible = true
	queue_free()
