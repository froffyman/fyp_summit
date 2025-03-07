extends Node2D
class_name HealthComponent

@export var MAX_HEALTH: int
@export var anim_handler: CharacterBody2D

var current_health: float 

func play_anim(anim: String):
	if anim_handler:
		if anim_handler.has_method("play_anim"):
			anim_handler.play_anim(anim)

func _ready():
	current_health = MAX_HEALTH

func take_damage(dmg: float):
	current_health -= dmg
	if (current_health) <= 0:
		play_anim("death")
	else:
		play_anim("hurt")
	
