extends Resource

class_name Inv
#For updating slots
signal update
#For dragging and dropping
signal dragged
signal dropped
signal abandon_drop
#Can't say I know if this one is ever used
signal full
#For visually representing an equipped hotbar slot
signal hold

@export var slots: Array[InvSlot] #Slots where items are stored

func insert(item: InvItem, slot = null, amount: int = 1):
	var leftover: InvSlot = null
	if slot == null:
		## First checks if any item slots already contain the desired item.
		var item_slots = slots.filter(func(slot): return slot.item == item and slot.amount < slot.max)
		if !item_slots.is_empty():
			print("Space found in existing slot!")
			item_slots[0].amount += amount
		else:
			## Otherwise, gets the first empty slot and inserts the item
			var empty_slots = slots.filter(func(slot): return slot.item == null)
			if !empty_slots.is_empty():
				print("Empty slot found!")
				empty_slots[0].item = item
				empty_slots[0].amount = amount
			else:
				print("No space found.")
				var ground_slot: InvSlot = InvSlot.new()
				ground_slot.item = item
				ground_slot.amount = amount
				SignalManager.make_item_collectible.emit(ground_slot)
	else:
		if slots[slot].item == item:
			if slots[slot].item != null:
				leftover = slots[slot]
			slots[slot].item = item
			slots[slot].amount = amount
		else:
			if slots[slot].item == item:
				slots[slot].amount += amount
				if slots[slot].amount > slots[slot].max:
					slots[slot].amount == slots[slot].max
					leftover = InvSlot.new()
					leftover.item = item
					leftover.amount = slots[slot].amount - slots[slot].max
				
	update.emit()
	return leftover

func direct_insert(index: int, item: InvSlot):
	slots[index] = item
	update.emit()

func get_active_item(slots):
	for i in range(len(slots)):
		if slots[i].active:
			print(i)
			return i	
	return -1

func hold_item(item: InvSlot):
	hold.emit(item)

func consume(index: int):
	slots[index].amount -= 1
	if slots[index].amount <= 0:
		slots[index] = InvSlot.new()
		hold.emit(InvSlot.new())
	update.emit()

func hotbar_insert(item: InvItem): 
	#Instead of dropping an item on the ground, this function will return the item so the player
	#can attempt to place it in their backpack.
	## First checks if any item slots already contain the desired item.
	var item_slots = slots.filter(func(slot): return slot.item == item and slot.amount < slot.max)
	if !item_slots.is_empty():
		item_slots[0].amount += 1
	else:
		## Otherwise, gets the first empty slot and inserts the item
		var empty_slots = slots.filter(func(slot): return slot.item == null)
		if !empty_slots.is_empty():
			empty_slots[0].item = item
			empty_slots[0].amount = 1
		else:
			return item
	update.emit()
	return null
	
