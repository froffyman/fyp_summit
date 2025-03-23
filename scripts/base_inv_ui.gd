extends Control
class_name base_inv_ui

@export var inv: Inv #Inventory resource bound to the scene
@onready var slots: Array #Array to store instances of the inventory slot scene
@onready var drag_texture = %DragTexture #Empty sprite, used to show what item the player is dragging

var inv_size: int
var inv_id: String

#Set to true when mouse leaves inventory UI
var can_place_on_ground = false

#Dragging stuff
var item_being_dragged: InvSlot
var dragged_slot_origin: int
var item_being_dropped: InvSlot

var can_inter_check: bool = false

var is_open = false

func _ready():
	inv.update.connect(update_slots)
	inv.dropped.connect(item_dropped)
	SignalManager.inter_inventory_send.connect(received_inter_inventory)
	SignalManager.inter_inventory_receive.connect(inter_inventory_response)
	update_slots()
	
	for i in inv_size:
		var new_slot = preload("res://scenes/inventory_slot.tscn").instantiate()
		new_slot.gui_input.connect(slot_clicked)
		new_slot.item_empty.connect(slot_emptied)
		new_slot.is_active.connect(slot_made_active)
		%GridContainer.add_child(new_slot)
	slots = %GridContainer.get_children()

func update_slots():
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])

func open():
	visible = true
	is_open = true

func close():
	visible = false
	is_open = false

func slot_made_active():
	SignalManager.active_inventory.emit(inv)



func get_empty_item():
	for i in range(len(slots)):
		if inv.slots[i].amount <= 0:
			return i
	return -1

func slot_emptied():
	var empty_slot: int = get_empty_item()
	if empty_slot != -1:
		var slot = slots[empty_slot]
		slot.clear_item()
		inv.slots[empty_slot] = InvSlot.new()

func item_dropped():
	var inter_inventory = SignalManager.current_inventory_id == SignalManager.origin_inventory_id
	
	var active_slot: int = inv.get_active_item(slots)
	var slot: Panel
	if item_being_dragged != null:
		drag_texture.visible = false
		if active_slot != -1: #Checks if there's a slot to be dropped into
			
			slot = slots[active_slot]
			
			if inv.slots[active_slot].item != null: #Checking if there's an item in the slot to be dropped into
				#Checking if the items match for item stacking
				if inv.slots[active_slot].item.name == item_being_dragged.item.name:
					
					var combined_total: int = item_being_dragged.amount + inv.slots[active_slot].amount 
					#Checking if the active slot has enough space for all the items being dragged
					if combined_total > inv.slots[active_slot].max:
						item_being_dragged.amount = inv.slots[active_slot].max
						inv.slots[active_slot].amount = combined_total - inv.slots[active_slot].max
						inv.direct_insert(dragged_slot_origin, inv.slots[active_slot])
					else:
						item_being_dragged.amount += inv.slots[active_slot].amount
				else:
					inv.direct_insert(dragged_slot_origin, inv.slots[active_slot])
				slot.clear_item()
			inv.direct_insert(active_slot, item_being_dragged)
			item_being_dragged = null
		else: #Now checks whether to drop the item on the ground or not
			print(inter_inventory)
			if inter_inventory == false:
				#let's try this again.
				var inv_b: base_inv_ui = SignalManager.current_inventory
				
				print("we've finally made it!")
				
				var active_slot_b: int = inv_b.inv.get_active_item(inv_b.slots)
				
				if inv_b.inv.slots[active_slot_b].item != null:
					if inv_b.inv.slots[active_slot_b].item.name == item_being_dragged.item.name:
						var combined_total: int = item_being_dragged.amount + inv_b.inv.slots[active_slot_b].amount
						if combined_total > inv_b.inv.slots[active_slot_b].max:
							item_being_dragged.amount = inv_b.inv.slots[active_slot_b].max
							inv_b.inv.slots[active_slot_b].amount = combined_total - inv_b.inv.slots[active_slot_b].max
							inv.direct_insert(dragged_slot_origin, inv_b.inv.slots[active_slot_b])
						else:
							item_being_dragged.amount += inv_b.inv.slots[active_slot_b].amount
					else:
						inv.direct_insert(dragged_slot_origin, inv_b.inv.slots[active_slot_b])
					slot.clear_item()
				inv_b.inv.direct_insert(active_slot_b, item_being_dragged)
				item_being_dragged = null
			elif can_place_on_ground:
				SignalManager.make_item_collectible.emit(item_being_dragged)
			else:
				inv.direct_insert(dragged_slot_origin, item_being_dragged)
			

func received_inter_inventory(item: InvSlot):
	var active_slot: int = inv.get_active_item(slots)
	if active_slot != -1:
		var slot: Panel = slots[active_slot]
		
		if inv.slots[active_slot].item != null:
			if inv.slots[active_slot].item.name == item.item.name:
				var combined_total: int = item.amount + inv.slots[active_slot].amount
				if combined_total > inv.slots[active_slot].max:
					item.amount = inv.slots[active_slot].max
					inv.slots[active_slot].amount = combined_total - inv.slots[active_slot].max
					SignalManager.inter_inventory_receive.emit(true, inv.slots[active_slot])
				else:
					item.amount += inv.slots[active_slot].amount
			else:
				SignalManager.inter_inventory_receive.emit(true, inv.slots[active_slot])
			slot.clear_item()
		else:
			SignalManager.inter_inventory_receive.emit(true, null)
		inv.direct_insert(active_slot, item)
	else:
		if can_place_on_ground:
			SignalManager.make_item_collectible.emit(item)
		else:
			SignalManager.inter_inventory_receive.emit(true, item)

func inter_inventory_response(flag, item: InvSlot):
	if can_inter_check:
		can_inter_check = false
		if flag:
			if item != null:
				inv.direct_insert(dragged_slot_origin, item)
		else:
			SignalManager.make_item_collectible.emit(item_being_dragged)

func slot_clicked(event):
	if Input.is_action_just_pressed("click"):
		
		var active_slot: int = inv.get_active_item(slots)
		var slot: Panel
		
		if active_slot != -1 and inv.slots[active_slot].item != null:
			inv.dragged.emit()
			SignalManager.dragged.emit()
			SignalManager.set_origin_inventory.emit(self, inv_id)
			
			slot = slots[active_slot]
			item_being_dragged = inv.slots[active_slot].duplicate()
			
			drag_texture.visible = true
			drag_texture.texture  = inv.slots[active_slot].item.texture
			
			dragged_slot_origin = active_slot
			
			slot.clear_item()
			inv.slots[active_slot] = InvSlot.new()
		else:
			pass
	elif Input.is_action_just_pressed("drop_one"):
		var active_slot: int = inv.get_active_item(slots)
		var slot: AspectRatioContainer = slots[active_slot]
		
		if active_slot != -1 and inv.slots[active_slot].item != null:
			var item_for_collectible: InvSlot = InvSlot.new()
			item_for_collectible.item = inv.slots[active_slot].item
			item_for_collectible.amount = 1
			
			SignalManager.make_item_collectible.emit(item_for_collectible)
			inv.slots[active_slot].amount -= 1
			if inv.slots[active_slot].amount <= 0:
				slot.clear_item()
				inv.slots[active_slot] = InvSlot.new()
			update_slots()

func _on_mouse_entered():
	SignalManager.active_inventory.emit(inv)
	SignalManager.set_current_inventory.emit(self, inv_id)
	can_place_on_ground = false


func _on_mouse_exited():
	can_place_on_ground = true
