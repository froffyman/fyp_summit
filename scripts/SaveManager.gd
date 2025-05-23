extends Node

var file_id: int = 1

func update_file_id(new_id: int):
	file_id = new_id

func save(stats=null, backpack=null, hotbar=null, village=null, forest=null, home=null, quests=null, spoken_npcs=null):
	var data = ResourceLoader.load(str("user://file", file_id, ".tres")) as save_file
	if data == null:
		data = save_file.new()
	
	if stats != null:
		data.stats = stats
	if backpack != null:
		data.backpack = backpack
	if hotbar != null:
		data.hotbar = hotbar
	if village != null:
		data.village = village
	if forest != null:
		data.forest = forest #PackedScene.new().pack(forest)
	if home != null:
		data.home = home #PackedScene.new().pack(home)
	if quests != null:
		data.quests = quests
	if spoken_npcs != null:
		data.spoken_npcs = spoken_npcs

	ResourceSaver.save(data, str("user://file", file_id, ".tres"))
func load_plr():
	var data = ResourceLoader.load(str("user://file", file_id, ".tres")) as save_file
	
	var plr_val_dict = {
		"stats": data.stats as PlrStats,
		"backpack": data.backpack as Inv,
		"hotbar": data.hotbar as Inv
	}
	
	return plr_val_dict

func load_village():
	var data = ResourceLoader.load(str("user://file", file_id, ".tres")) as save_file
	return data.village

func load_forest():
	var data = ResourceLoader.load(str("user://file", file_id, ".tres")) as save_file
	return data.forest

func load_home():
	var data = ResourceLoader.load(str("user://file", file_id, ".tres")) as save_file
	return data.home

func load_quests():
	var data = ResourceLoader.load(str("user://file", file_id, ".tres")) as save_file
	return data.quests

func load_spoken_npcs():
	var data = ResourceLoader.load(str("user://file", file_id, ".tres")) as save_file
	return data.spoken_npcs
