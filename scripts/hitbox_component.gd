extends Area2D
class_name HitboxComponent

@export var damage: float
@export var max_hit_count: int

var times_hit: int = 0
var whitelist = []

signal completed

func _ready():
	monitoring = true

func _on_area_entered(area):
	if area is HurtboxComponent and whitelist.has(area) == false:
		area.take_damage(damage)
		times_hit += 1
		if times_hit >= max_hit_count:
			completed.emit()
			queue_free()

func add_to_whitelist(new_entry: HurtboxComponent):
	whitelist.append(new_entry)
