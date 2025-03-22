extends Node

signal make_item_collectible
signal can_drop_item_on_ground
signal active_inventory
signal dragged

signal enemy_died

signal chat_update

signal set_origin_inventory
signal set_current_inventory
var current_inventory: base_inv_ui
var origin_inventory: base_inv_ui
var current_inventory_id: String
var origin_inventory_id: String

func _ready():
	set_current_inventory.connect(new_current_inventory)
	set_origin_inventory.connect(new_origin_inventory)

func new_current_inventory(new: base_inv_ui, id: String):
	current_inventory = new
	current_inventory_id = id
func new_origin_inventory(new: base_inv_ui, id: String):
	origin_inventory = new
	origin_inventory_id = id

#The dreaded inter-inventory transfer
signal inter_inventory_send
signal inter_inventory_receive
