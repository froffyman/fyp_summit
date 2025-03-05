extends StaticBody2D

@export var item: InvSlot
var can_collect : bool = true
@export var can_collide: bool = true

@onready var sprite = %Sprite2D
@onready var anim_player = %AnimationPlayer

func _ready():
	if not sprite.texture and item:
		sprite.texture = item.item.texture 

func _on_area_2d_body_entered(body):
	if body.has_method("collect") and can_collect:
		for i in range(item.amount):
			body.collect(item.item)
		queue_free()
	elif body.has_method("combine") and body != self and body.item.item.name == item.item.name and body.can_collide and can_collide:
		can_collide = false
		body.can_collide = false
		body.combine(self)

func constructor(slot): #Called by the main game when a new collectible is instantiated
	item = slot
	sprite.texture = ImageTexture.create_from_image(item.item.texture.get_image())
	anim_player.play("drop")

func combine(target):
	var total_items: int = target.item.amount + item.amount
	if total_items > item.max:
		target.item.amount = item.max
		item.amount = total_items - item.amount
	else:
		target.item.amount = total_items
		target.can_collide = true
		queue_free()
