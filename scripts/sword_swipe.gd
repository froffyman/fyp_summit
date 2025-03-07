extends AnimatedSprite2D

@onready var hitbox = %HitboxComponent

func add_to_whitelist(area: HurtboxComponent):
	hitbox.add_to_whitelist(area)



func _on_animation_finished():
	queue_free()
