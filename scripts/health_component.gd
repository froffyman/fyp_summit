extends Node2D
class_name HealthComponent

@export var MAX_HEALTH: int
@export var animated_sprite: AnimatedSprite2D

var current_health: float 

func play_anim(anim: String):
	if animated_sprite != null and animated_sprite.has_method("play_anim"):
		animated_sprite.play_anim(anim)

func _ready():
	current_health = MAX_HEALTH

func take_damage(dmg: float):
	current_health -= dmg
	if (current_health) <= 0:
		play_anim("death")
	else:
		play_anim("hurt")
	
