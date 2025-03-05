extends base_inv_ui

func _ready():
	inv_size = 12
	inv_id = "backpack"
	super._ready()
	close()
	SignalManager.can_drop_item_on_ground.connect(global_item_ground_perms)

func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		if is_open:
			close()
		else:
			open()

func global_item_ground_perms(sig: bool):
	can_place_on_ground = sig

func _on_mouse_entered():
	SignalManager.active_inventory.emit(inv)
	SignalManager.can_drop_item_on_ground.emit(false)
	SignalManager.set_current_inventory.emit(self, inv_id)
	can_place_on_ground = false


func _on_mouse_exited():
	SignalManager.can_drop_item_on_ground.emit(true)
	can_place_on_ground = true
