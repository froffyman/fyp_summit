extends Path2D

var enemy_list: EnemyList
var can_spawn: bool = false

@onready var path_follow: PathFollow2D = %PathFollow2D
@onready var spawn_timer: Timer = %EnemySpawn

func update_enemy_list(new_list: EnemyList):
	enemy_list = new_list

func spawn_toggle(val: bool):
	can_spawn = val


func _on_enemy_spawn_timeout():
	if can_spawn:
		var spawn_chance = randi_range(1, 2)
		if spawn_chance == 1:
			const enemy_path = "res://scenes/red_slime.tscn"
			var enemy = preload(enemy_path)
