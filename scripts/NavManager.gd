extends Node

const village = preload("res://scenes/game.tscn")
const forest = preload("res://scenes/forest.tscn")
const home = preload("res://scenes/home.tscn")

var spawn_door_tag
var current_scene: String = "village"


signal on_trigger_player_spawn

func go_to_level(level_tag, destination_tag):
	var scene_to_load
	var current_lvl = PackedScene.new()
	current_lvl.pack(get_tree().current_scene)
	
	match current_scene:
		"village":
			SaveManager.save(null, null, null, current_lvl, null, null)
		"forest":
			SaveManager.save(null, null, null, null, current_lvl, null)
		"home":
			SaveManager.save(null, null, null, null, null, current_lvl)
	
	match level_tag:
		"village":
			var loaded = SaveManager.load_village() as PackedScene
			if loaded == null:
				scene_to_load = village
			else:
				scene_to_load = loaded
			current_scene = "village"
		"forest":
			var loaded = SaveManager.load_forest() as PackedScene
			if loaded == null:
				scene_to_load = forest
			else:
				scene_to_load = loaded
			current_scene = "forest"
		"home":
			var loaded = SaveManager.load_home() as PackedScene
			if loaded == null:
				scene_to_load = home
			else:
				scene_to_load = loaded
			current_scene = "home"
		
	if scene_to_load != null:
		call_deferred("scene_switch", destination_tag, scene_to_load)

func scene_switch(destination_tag, scene_to_load):
	spawn_door_tag = destination_tag
	get_tree().change_scene_to_packed(scene_to_load)

func trigger_player_spawn(position: Vector2, direction: String):
	on_trigger_player_spawn.emit(position, direction)
