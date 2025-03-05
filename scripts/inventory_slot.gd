extends Panel

@onready var item_display: Sprite2D = %item_display
@onready var amount_text: Label = %Label
@onready var active_outline: Sprite2D = %active_outline

signal item_dragging
signal item_dropped
signal item_empty

signal is_active

@export var active: bool = false
var equipped: bool = false
@export var current_item: InvSlot = InvSlot.new()
var is_following: bool = false

func update(slot: InvSlot):
	if slot:
		if !slot.item:
			item_display.visible = false
			amount_text.visible = false
			amount_text.text = "0"
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

func clear_item():
	item_display.texture = null
	amount_text.visible = false

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

func _equipped(val):
	equipped = val
	active_outline.visible = val
	#if val:
		#active_outline.modulate = Color.hex(0xf873ff)

func _on_mouse_entered():
	_active(true)
	is_active.emit()


func _on_mouse_exited():
	_active(false)
