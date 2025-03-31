extends AnimatedSprite2D

func _on_animation_finished():
	if animation == "death":
		queue_free()
