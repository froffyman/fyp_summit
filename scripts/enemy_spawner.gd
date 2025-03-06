extends Node2D

@export var spawn_zone: Path2D
@export var enemy_list_path: String

var enemy_list

func _ready():
	if enemy_list_path:
		enemy_list = EnemyListManager.get_list(enemy_list_path)
		if enemy_list == null:
			enemy_list = [preload("res://scenes/red_slime.tscn")]


func _on_body_entered(body):
	if body is Player:
		if spawn_zone:
			if spawn_zone.has_method("update_enemy_list"):
				spawn_zone.update_enemy_list(enemy_list)
			if spawn_zone.has_method("spawn_toggle"):
				spawn_zone.spawn_toggle(true)


func _on_body_exited(body):
	if body is Player:
		if spawn_zone:
			if spawn_zone.has_method("spawn_toggle"):
				spawn_zone.spawn_toggle(false)
