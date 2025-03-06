extends Path2D

var enemy_list
var can_spawn: bool = false

@export var scene_parent: Node2D

@onready var path_follow: PathFollow2D = %PathFollow2D
@onready var spawn_timer: Timer = %EnemySpawn

func update_enemy_list(new_list):
	enemy_list = new_list

func spawn_toggle(val: bool):
	can_spawn = val
	if can_spawn:
		spawn_timer.start()
	else:
		spawn_timer.stop()


func _on_enemy_spawn_timeout():
	if scene_parent:
		if can_spawn:
			var spawn_chance = randi_range(1, 2)
			if spawn_chance == 1:
				var enemy = enemy_list.pick_random().instantiate()
				path_follow.progress_ratio = randf()
				scene_parent.add_child(enemy)
				enemy.global_position = path_follow.global_position
			
