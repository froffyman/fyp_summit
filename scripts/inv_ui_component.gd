extends Control
class_name InvUIComponent

var inv_resource: Inv
@export var columns: int
@export var inv_size: int
@export var drag_texture: TextureRect

@onready var slot_container = %SlotContainer
@onready var slots = []

var equip_block: bool = false
var equipped_slot: int = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	slot_container.columns = columns

func set_inv(res: Inv):
	inv_resource = res
	inv_resource.update.connect(update_slots)
	for i in inv_size:
		var new_slot = preload("res://scenes/inventory_slot.tscn").instantiate()
		slot_container.add_child(new_slot)
		
		new_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		new_slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
		
		new_slot.init(drag_texture, inv_resource, i)
		new_slot.update_slots.connect(update_slots)
		slots.append(new_slot)

func equip_block_toggle(val: bool):
	equip_block = val

func show_equipped(index):
	if equip_block == false:
		if equipped_slot != -1:
			slots[equipped_slot]._equipped(false)
		
		slots[index]._equipped(true)
		equipped_slot = index

func update_slots():
	for i in range(inv_size):
		slots[i].update(inv_resource.slots[i])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
