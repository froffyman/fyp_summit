extends Node2D

@onready var player_detection = %PlayerDetectComponent
@export var spawn_zone: Path2D
@export var enemy_list: EnemyList

@export var detection_zone: CollisionShape2D

func _ready():
	if detection_zone:
		player_detection.add_child(detection_zone)

func _on_player_detect_component_player_entered():
	if spawn_zone:
		if spawn_zone.has_method("update_enemy_list"):
			spawn_zone.update_enemy_list(enemy_list)
