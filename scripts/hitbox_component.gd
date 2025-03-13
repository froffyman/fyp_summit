extends Area2D
class_name HitboxComponent

@export var damage: float
@export var max_hit_count: int
@export var player_only: bool

var times_hit: int = 0
var whitelist = []


signal completed

func _ready():
	monitoring = true

func deal_damage(area):
	area.take_damage(damage)
	times_hit += 1
	if times_hit >= max_hit_count:
		completed.emit()
		queue_free()

func _on_area_entered(area):
	if area is HurtboxComponent and whitelist.has(area) == false:
		if player_only:
			if area.is_player == true:
				deal_damage(area)
		else:
			deal_damage(area)
			

func add_to_whitelist(new_entry: HurtboxComponent):
	whitelist.append(new_entry)
