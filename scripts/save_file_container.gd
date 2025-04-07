extends NinePatchRect

@export var id: int

@onready var file_num = %FileNum
@onready var fish_lvl = %FishingLvl
@onready var cmbt_lvl = %CombatLvl

func _ready():
	var data = ResourceLoader.load(str("user://file", id, ".tres")) as save_file
	var stats = data.stats as PlrStats
	file_num.text = str("File", id)
	fish_lvl.text = str(stats.fishing_lvl)
	cmbt_lvl.text = str(stats.combat_lvl)
