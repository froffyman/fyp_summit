extends Node

const village = preload("res://scenes/game.tscn")
const forest = preload("res://scenes/forest.tscn")
const home = preload("res://scenes/home.tscn")

var spawn_door_tag

signal on_trigger_player_spawn

func go_to_level(level_tag, destination_tag):
	var scene_to_load
	
	match level_tag:
		"village":
			scene_to_load = village
		"forest":
			scene_to_load = forest
		"home":
			scene_to_load = home
		
	if scene_to_load != null:
		call_deferred("scene_switch", destination_tag, scene_to_load)

func scene_switch(destination_tag, scene_to_load):
	spawn_door_tag = destination_tag
	get_tree().change_scene_to_packed(scene_to_load)

func trigger_player_spawn(position: Vector2, direction: String):
	on_trigger_player_spawn.emit(position, direction)
