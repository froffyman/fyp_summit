extends Node2D
class_name HealthComponent

signal healed
signal hurt
signal dead

@export var MAX_HEALTH: int
@export var anim_handler: CharacterBody2D

var current_health: float = 0

func play_anim(anim: String):
	if anim_handler:
		if anim_handler.has_method("play_anim"):
			anim_handler.play_anim(anim)

func _ready():
	if current_health == 0:
		current_health = MAX_HEALTH

func heal(amount: float):
	if current_health < MAX_HEALTH:
		current_health += amount
		if current_health > MAX_HEALTH:
			current_health = MAX_HEALTH
		healed.emit()

func take_damage(dmg: float):
	current_health -= dmg
	if (current_health) <= 0:
		play_anim("death")
		dead.emit()
	else:
		play_anim("hurt")
		hurt.emit()
	
