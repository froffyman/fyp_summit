extends Area2D
class_name Gate

@export var destination_area_tag: String
@export var destination_door_tag: String
@export var spawn_direction = "up"

@onready var spawn = %SpawnPoint


func _on_body_entered(body):
	if body is Player:
		body.save_stats()
		NavManager.go_to_level(destination_area_tag, destination_door_tag)
