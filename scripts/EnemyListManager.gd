extends Node

const list_disct = {
	"Basic_Enemies" = BASIC_ENEMIES
}

const BASIC_ENEMIES = [
	preload("res://scenes/red_slime.tscn")
]

func get_list(list_key: String):
	if list_disct[list_key]:
		return list_disct[list_key]
	else:
		return null
