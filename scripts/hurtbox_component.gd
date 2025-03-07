extends Area2D
class_name HurtboxComponent

@export var animated_sprite: AnimatedSprite2D
@export var health_component: HealthComponent

@onready var cooldown: Timer = %HitCooldown

func play_anim(anim: String):
	if animated_sprite != null and animated_sprite.has_method("play_anim"):
		animated_sprite.play_anim(anim)

func take_damage(dmg: float):
	if health_component:
		if cooldown.is_stopped() == true:
			cooldown.start()
			health_component.take_damage(dmg)
	

