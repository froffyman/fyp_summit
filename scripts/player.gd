extends CharacterBody2D
class_name Player

const SPEED = 130
var speed_modifier = 1 #Changed to speed the player up/slow them down when needed

@onready var anim_sprite = $AnimatedSprite2D
@onready var hold_display = %HeldItem
@onready var tile_marker = %tileMarker
@onready var hurtbox: HurtboxComponent = %HurtboxComponent
@onready var health: HealthComponent = %HealthComponent
@onready var ui_layer = %InventoryLayer
@onready var quest_menu = %QuestMenu

@onready var hotbar_ui = %InvUIComponent
@onready var backpack_ui = %Backpack
@onready var drag_texture = %DragTexture

var inv: Inv
var hotbar: Inv

var slot_inputs = ["slot_1", "slot_2", "slot_3", "slot_4", "slot_5", "slot_6", "slot_7", "slot_8", "slot_9"]
@export var held_item: InvSlot
var held_item_index: int = -1

var active_inv: Inv

#Inter-inventory transfer stuff
var dragged_slot_origin: int
var item_being_dragged: InvSlot

var stats: PlrStats
@onready var stat_menu = %StatMenu
signal stat_update

var inv_dragging: Inv
var item_dragged: bool = false

var can_use_tool: bool = true
var access_mode: String = "" #Lock to allow only one feature to block movement/tools at once

# Fishing State to determine when player is fishing:
var fishing_state: bool = false
# Signal to delete animated fishing rod:
signal delete_anim_rod
# Fishing Bite variables:

var bite_limit: int = 500
var timeout_limit: int = 120

var bite_threshold: int = -1
var bite_counter: int = 0
var has_bite: bool = false
var bite_timeout: int = 0
signal bite_timed_out

func _ready():
	var file_data = SaveManager.load_plr()
	stats = file_data["stats"]
	inv = file_data["backpack"]
	hotbar = file_data["hotbar"]

	hotbar_ui.set_inv(hotbar)
	backpack_ui.set_inv(inv)

	health.MAX_HEALTH = stats.max_health
	health.current_health = stats.current_health
	if health.current_health <= 0:
		health.current_health = health.MAX_HEALTH
	health.healed.emit()
	
	active_inv = inv
	inv.dragged.connect(drag_detect)
	hotbar.hold.connect(hold_item)
	
	inv.update.emit()
	hotbar.update.emit()

	health.dead.connect(kill_player)
	
	DragManager.start_drag.connect(drag_toggle.bind(true))
	DragManager.stop_drag.connect(drag_toggle.bind(false))
	
	SignalManager.dragged.connect(drag_detect)
	SignalManager.active_inventory.connect(update_active_inv)
	SignalManager.enemy_died.connect(exp_gain.bind("combat", randi_range(8, 15)))
	SignalManager.chat_update.connect(chat_update)
	SignalManager.quest_reward.connect(exp_gain)
	
	NavManager.on_trigger_player_spawn.connect(_on_spawn)
	
	stat_menu.update(stats.fishing_lvl, stats.combat_lvl, stats.fishing_exp, stats.combat_exp)
	
	save_health()
	health.healed.connect(save_health)
	health.hurt.connect(save_health)
	health.dead.connect(save_health)

func _on_spawn(position: Vector2, direction: String):
	global_position = position
	if direction == "right" or direction == "down":
		anim_sprite.flip_h = true

func update_active_inv(new_inv):
	active_inv = new_inv

func return_to_menu():
	save_stats()
	held_item = null
	NavManager.go_to_level(null, null)
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _process(delta):
	
	#Pause Menu
	if Input.is_action_just_pressed("pause") and Engine.time_scale != 0:
		var pause_menu = preload("res://scenes/pause_menu.tscn").instantiate()
		ui_layer.add_child(pause_menu)
		pause_menu.quit_to_menu.connect(return_to_menu)
		Engine.time_scale = 0
	
	#Drop item on the ground
	if Input.is_action_just_released("click") and item_dragged and not DragManager.can_drop:
		DragManager.stop_drag.emit()
		SignalManager.make_item_collectible.emit(DragManager.item_being_dragged)
		DragManager.item_being_dragged = null
		drag_texture.texture = null
	
	if Input.is_action_just_released("inventory"):
		backpack_ui.visible = not backpack_ui.visible
	
	#Hotbar Tool Equip
	for i in range(len(slot_inputs)):
		if Input.is_action_just_pressed(slot_inputs[i]):
			if access_mode == "":
				hotbar_ui.show_equipped(i)
				hotbar.hold_item(hotbar.slots[i])
				held_item_index = i

func drag_toggle(val: bool):
	item_dragged = val

func chat_update(mode):
	blocking("chat", mode)

func blocking(access_password: String, mode: bool):
	if mode:
		access_mode = access_password
		can_use_tool = false
		hotbar_ui.equip_block_toggle(true)
		speed_modifier = 0
		DragManager.can_drag = false
	elif not mode and access_mode == access_password:
		access_mode = ""
		can_use_tool = true
		hotbar_ui.equip_block_toggle(false)
		speed_modifier = 1
		DragManager.can_drag = true

func _physics_process(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	
	#Get velocity from direction
	velocity = direction * SPEED
	velocity = velocity * speed_modifier
	
	#Flip the sprite if the player can move:
	if speed_modifier > 0:
		if direction.x > 0:
			anim_sprite.flip_h = true
			
			hold_display.flip_h = true
			hold_display.position = Vector2(10, 0)
			hold_display.rotation_degrees = 30
			
			tile_marker.position = Vector2(16, 9)
			
		elif direction.x < 0:
			anim_sprite.flip_h = false
			
			hold_display.flip_h = false
			hold_display.position = Vector2(-10, 0)
			hold_display.rotation_degrees = -30
			
			tile_marker.position = Vector2(-16, 9)
	
	#Play walk anim if moving (and if can move)
	if direction.x == 0 and direction.y == 0:
		anim_sprite.play("idle")
	else:
		if speed_modifier > 0:
			anim_sprite.play("walk")
	
	#Toggle Stat Menu
	if Input.is_action_just_released("tab"):
		stat_menu.visible = not stat_menu.visible
	
	if Input.is_action_just_released("click") and not item_dragged and can_use_tool and held_item != null:
		match held_item.item.use:
			"eat":
				eat()
			"fishing":
				fishing(500, 120, false)
			"spearfishing":
				fishing(250, 30, true)
			"sword":
				sword()
	
	#Fishing Handling
	if fishing_state:
		if not has_bite:
			if bite_threshold == -1:
				bite_threshold = randi_range(0, (bite_limit - (stats.fishing_lvl*30)))
			if bite_counter < bite_threshold:
				bite_counter += 1
			else:
				
				var bite_notif = preload("res://scenes/exclamation_mark.tscn").instantiate()
				add_child(bite_notif)
				bite_notif.position = Vector2(-10, -10)
				bite_timed_out.connect(bite_notif.fade)
				bite_threshold = -1
				bite_counter = 0
				has_bite = true
		else:
			if bite_timeout < (timeout_limit + (stats.fishing_lvl*20)):
				bite_timeout += 1
			else:
				bite_timed_out.emit()
				bite_timeout = 0
				has_bite = false
	
	move_and_slide()

func collect(item):
	var hotbar_result = hotbar.hotbar_insert(item)
	if hotbar_result != null:
		inv.insert(item)

func drag_detect():
	item_dragged = true

func hold_item(item: InvSlot):
	if item.item != null:
		held_item = item
		hold_display.visible = true
		hold_display.texture = item.item.texture
	else:
		held_item = null
		hold_display.visible = false
		hold_display.texture = null

#Stats
func exp_gain(stat: String, amount: int):
	match stat:
		"fishing":
			stats.fishing_exp += amount
			while stats.fishing_exp >= stats.fishing_lvl*100:
				stats.fishing_exp -= (stats.fishing_lvl*100)
				stats.fishing_lvl +=1
				
		"combat":
			stats.combat_exp += amount
			while stats.combat_exp >= stats.combat_lvl*100:
				stats.combat_exp -= (stats.combat_lvl*100)
				stats.combat_lvl +=1
	print("Current Fishing EXP: ", stats.fishing_exp)
	print("Current Combat EXP: ", stats.combat_exp)
	stat_menu.update(stats.fishing_lvl, stats.combat_lvl, stats.fishing_exp, stats.combat_exp)

func save_health():
	stats.current_health = health.current_health
	stats.max_health = health.MAX_HEALTH

func save_stats():
	SaveManager.save(stats, inv, hotbar, null, null, null, quest_menu.all_quest_data())

# Tile Data for Marker
func get_tile_data():
	var tileMap = get_parent().find_child("TileMap") #caution.
	var searchPos = tileMap.local_to_map(tile_marker.global_position)
	var data = tileMap.get_cell_tile_data(0, searchPos)
	
	if data:
		return data.get_custom_data("Type")

# Tool Use Functions -------------------------------------------------------------------------------
func fishing(bl: int, to: int, spear: bool):
	if not fishing_state:
		
		blocking("tool", true)
		hold_display.visible = false
		anim_sprite.play("idle")
		
		var anim_rod
		if spear:
			anim_rod = preload("res://scenes/anim_fishing_spear.tscn").instantiate()
		else: 
			anim_rod = preload("res://scenes/anim_fishing_rod.tscn").instantiate()
		anim_sprite.add_child(anim_rod)
		anim_rod.position = hold_display.position
		
		if hold_display.flip_h:
			anim_rod.flip()
			
		anim_rod.play_swing()
		delete_anim_rod.connect(anim_rod.clear_out.bind(hold_display))
		
		if get_tile_data() == "Water":
			bite_limit = bl
			timeout_limit = to
			anim_rod.done_swinging.connect(start_fishing)
		else:
			anim_rod.done_swinging.connect(cancel_fishing.bind(anim_rod))
	else:
		stop_fishing()
	

#Tool Use: Fishing Extra Methods
func start_fishing():
	can_use_tool = true
	fishing_state = true

func cancel_fishing(anim_rod):
	blocking("tool", false)
	#Bring held item back
	anim_rod.clear_out(hold_display)

func stop_fishing():
	delete_anim_rod.emit()
	fishing_state = false
	blocking("tool", false)
	
	if has_bite:
		has_bite = false
		bite_timeout = 0
		
		var caught_fish: InvSlot = InvSlot.new()
		caught_fish.item = preload("res://resources/items/fish/pinktail_fish.tres")
		caught_fish.amount = 1
		SignalManager.fish_caught.emit()
		SignalManager.make_item_collectible.emit(caught_fish)
		
		exp_gain("fishing", randi_range(5, 10))

func eat():
	if health.current_health != health.MAX_HEALTH:
		health.heal(25)
		hotbar.consume(held_item_index)

#Tool Use: Sword
func sword():
	can_use_tool = false
	hold_display.visible = false
	
	var sword_swipe = preload("res://scenes/sword_swipe.tscn").instantiate()
	anim_sprite.add_child(sword_swipe)
	sword_swipe.add_to_whitelist(hurtbox)
	sword_swipe.position = hold_display.position
	
	if hold_display.flip_h:
		sword_swipe.flip_h = true
	
	sword_swipe.animation_finished.connect(end_sword)

func end_sword():
	can_use_tool = true
	hold_display.visible = true

#Death Handler
func kill_player():
	blocking("death", true)
	var death_menu = preload("res://scenes/death_menu.tscn").instantiate()
	ui_layer.add_child(death_menu)
	#health.heal(health.MAX_HEALTH) #Preventing the player from spawning in at 0
