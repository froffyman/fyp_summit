extends AspectRatioContainer

@onready var item_display: TextureRect = %item_display
@onready var amount_text: Label = %Label
@onready var active_outline: TextureRect = %active_outline

signal item_dragging
signal item_dropped
signal item_empty

signal is_active

signal update_slots

@export var active: bool = false
var equipped: bool = false
@export var current_item: InvSlot = InvSlot.new()
var is_following: bool = false

var inv_resource: Inv
var inv_index: int

var drag_texture: TextureRect

func update(slot: InvSlot):
	if slot:
		if !slot.item or slot.amount <= 0:
			item_display.visible = false
			amount_text.visible = false
			amount_text.text = "0"
			tooltip_text = ""
			current_item = null
		else:
			current_item = slot
			item_display.visible = true
			item_display.texture = slot.item.texture
			if slot.amount > 1:
				amount_text.visible = true
			else:
				amount_text.visible = false
			amount_text.text = str(slot.amount)
			
			tooltip_text = slot.item.name
	if slot.amount <= 0:
		clear_item()
		item_empty.emit()
		tooltip_text = ""

func clear_item():
	current_item = null
	item_display.texture = null
	amount_text.visible = false
	tooltip_text = ""
	inv_resource.slots[inv_index] = InvSlot.new()
	if equipped:
		inv_resource.hold_item(InvSlot.new())

func init(drag: TextureRect, i: Inv, index: int):
	drag_texture = drag
	inv_resource = i
	inv_index = index



#func _get_drag_data(at_position):
	#
	#var preview_texture = TextureRect.new()
	#
	#preview_texture.texture = item_display.texture
	#preview_texture.expand_mode = 1
	#preview_texture.size = size
	#
	#var preview = Control.new()
	#preview.add_child(preview_texture)
	#
	#item_dragging.emit()
	#active = true
	#set_drag_preview(preview)
	#
	#return item_display.texture

#func _can_drop_data(at_position, data):
	#item_dropped.emit()
	#return data is Texture2D
#
#func _drop_data(at_position, data):
	##item_display.texture = data
	#pass

#func _physics_process(delta):
#	if is_following and item_display.visible:
#		item_display.position = get_global_mouse_position()


#func _on_center_container_gui_input(event):
#	if Input.is_action_pressed("click"):
#		is_following = true
#	if Input.is_action_just_released("click"):
#		is_following = false
#		print("released!")

func _active(val: bool):
	active = val
	if not equipped:
		active_outline.visible = val
	#if val:
		#active_outline.modulate = Color.hex(0xffffff)

#ON EQUIP, SET ACTIVE_OUTLINE COLOR: active_outline.modulate = Color.hex(0xf873ff)

func _equipped(val: bool):
	equipped = val
	active_outline.visible = val
	#if val:
		#active_outline.modulate = Color.hex(0xf873ff)

func _on_mouse_entered():
	_active(true)
	is_active.emit()


func _on_mouse_exited():
	_active(false)


func _on_panel_mouse_entered():
	print("true")
	DragManager.can_drop = true
	_active(true)
	is_active.emit()



func _on_panel_mouse_exited():
	print("false")
	DragManager.can_drop = false
	_active(false)



func _on_panel_gui_input(event):
	if Input.is_action_just_released("drop_one") and current_item != null:
		inv_resource.drop_one(inv_index)
	if Input.is_action_just_released("click") and current_item != null and DragManager.item_being_dragged == null and DragManager.can_drag:
		DragManager.start_drag.emit()
		drag_texture.texture = current_item.item.texture
		DragManager.item_being_dragged = inv_resource.slots[inv_index]
		DragManager.dragged_inv_origin = inv_resource
		DragManager.dragged_slot_index = inv_index
		clear_item()
	elif Input.is_action_just_released("click") and DragManager.item_being_dragged != null and DragManager.can_drop:
		DragManager.stop_drag.emit()
		var leftover = inv_resource.insert(DragManager.item_being_dragged.item, inv_index, DragManager.item_being_dragged.amount)
		
		if equipped:
			inv_resource.hold_item(current_item)
		
		if leftover != null:
			print("Leftovers")
			DragManager.dragged_inv_origin.insert(leftover.item, DragManager.dragged_slot_index, leftover.amount)
		DragManager.item_being_dragged = null
		drag_texture.texture = null
