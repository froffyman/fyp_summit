extends Node2D

@onready var plr = %Player

func _ready():
	SignalManager.make_item_collectible.connect(collectible_generation)
	if NavManager.spawn_door_tag != null:
		_on_level_spawn(NavManager.spawn_door_tag)

func collectible_generation(slot):
	var new_collectible = preload("res://scenes/collectible.tscn").instantiate()
	add_child(new_collectible)
	var plr_pos: Vector2 = plr.global_position
	new_collectible.global_position = plr_pos
	var direction: int = 1
	if plr.anim_sprite.flip_h:
		direction = -1
	new_collectible.scale.x = direction
	new_collectible.item = slot
	new_collectible.constructor(slot)
	
func _on_level_spawn(destination_tag: String):
	var gate = get_node("Gates/" + destination_tag) as Gate
	NavManager.trigger_player_spawn(gate.spawn.global_position, gate.spawn_direction)
	
