extends base_inv_ui

var hotbar_slots = []
var slot_inputs = ["slot_1", "slot_2", "slot_3", "slot_4", "slot_5", "slot_6", "slot_7", "slot_8", "slot_9"]
var equipped_slot: int = -1

func _ready():
	inv_size = 9
	inv_id = "hotbar"
	inv.update.connect(update_slots)
	inv.dropped.connect(item_dropped)
	update_slots()
	
	for i in inv_size:
		var new_slot = preload("res://scenes/inventory_slot.tscn").instantiate()
		new_slot.gui_input.connect(slot_clicked)
		new_slot.item_empty.connect(slot_emptied)
		new_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		new_slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
		%GridContainer.add_child(new_slot)
		hotbar_slots.append(new_slot)
		
		
	slots = %GridContainer.get_children()

func get_active_item():
	for i in range(len(slots)):
		if slots[i].active:
			return i	
	return -1

func update_slots():
	super.update_slots()
	if equipped_slot != -1:
		inv.hold_item(inv.slots[equipped_slot])

func item_dropped():
	super.item_dropped()
	if equipped_slot != -1:
		inv.hold_item(inv.slots[equipped_slot])

func _process(delta): #Used for equip function
	for i in range(0, inv_size):
		if Input.is_action_just_pressed(slot_inputs[i]):
			if equipped_slot != -1:
				hotbar_slots[equipped_slot]._equipped(false)
			hotbar_slots[i]._equipped(true)
			equipped_slot = i
			inv.hold_item(inv.slots[i])
			

func slot_equipped(event):
	if Input.is_action_just_pressed("slot_1"):
		print("hi!")
