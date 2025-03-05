extends CharacterBody2D
class_name Player

const SPEED = 130
var speed_modifier = 1 #Changed to speed the player up/slow them down when needed

@onready var anim_sprite = $AnimatedSprite2D
@onready var hold_display = %HeldItem
@onready var tile_marker = %tileMarker

@export var inv: Inv
@export var hotbar: Inv

@export var held_item: InvSlot

var active_inv: Inv

#Inter-inventory transfer stuff
var dragged_slot_origin: int
var item_being_dragged: InvSlot

@export var stats: PlrStats

var inv_dragging: Inv
var item_dragged: bool = false

var can_use_tool: bool = true

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
var bite_timeout: int = timeout_limit
signal bite_timed_out

func _ready():
	active_inv = inv
	inv.dragged.connect(drag_detect)
	hotbar.hold.connect(hold_item)
	
	inv.update.emit()
	hotbar.update.emit()
	
	SignalManager.dragged.connect(drag_detect)
	SignalManager.active_inventory.connect(update_active_inv)
	
	NavManager.on_trigger_player_spawn.connect(_on_spawn)

func _on_spawn(position: Vector2, direction: String):
	global_position = position
	if direction == "right" or direction == "down":
		anim_sprite.flip_h = true

func update_active_inv(new_inv):
	active_inv = new_inv

func _process(delta):
	pass

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
	
	if Input.is_action_just_released("click") and item_dragged:
		item_dragged = false
		active_inv.dropped.emit()
	elif Input.is_action_just_released("click") and not item_dragged and can_use_tool and held_item != null:
		match held_item.item.use:
			"eat":
				eat()
			"fishing":
				fishing(500, 120, false)
			"spearfishing":
				fishing(250, 30, true)
	
	#Fishing Handling
	if fishing_state:
		if not has_bite:
			if bite_threshold == -1:
				bite_threshold = randi_range(0, bite_limit)
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
			if bite_timeout >= 0:
				bite_timeout -= 1
			else:
				bite_timed_out.emit()
				bite_timeout = timeout_limit
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
func exp_gain(skill: String, amount: int):
	var stat_to_change: String
	match skill:
		"fishing":
			stats.fishing_exp += amount
		"combat":
			stats.combat_exp += amount
	print("Current Fishing EXP: ", stats.fishing_exp)
	
	var limit = 100 * (1 + 0.2)**stats.fishing_lvl
	while stats.fishing_exp >= limit:
		stats.fishing_exp -= limit
		stats.fishing_lvl += 1
		print("Level up! You are now level ", stats.fishing_lvl)
		


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
		
		speed_modifier = 0
		can_use_tool = false
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
			bite_timeout = to
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
	can_use_tool = true
	speed_modifier = 1
	#Bring held item back
	anim_rod.clear_out(hold_display)

func stop_fishing():
	delete_anim_rod.emit()
	fishing_state = false
	speed_modifier = 1
	
	if has_bite:
		has_bite = false
		bite_timeout = 120
		
		var caught_fish: InvSlot = InvSlot.new()
		caught_fish.item = preload("res://resources/items/fish/pinktail_fish.tres")
		caught_fish.amount = 1
		SignalManager.make_item_collectible.emit(caught_fish)
		
		exp_gain("fishing", randi_range(5, 10))

func eat():
	print("deeelicious!")

#Tool Use: Spearfishing
