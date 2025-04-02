extends Node2D


@onready var dialogue = %DialogueComponent

func _ready():
	dialogue.custom_sig.connect(drop_rod)

func drop_rod(sig):
	if sig == "give_rod":
		var rod = InvSlot.new()
		rod.item = preload("res://resources/items/fishing_rod.tres")
		rod.amount = 1
		SignalManager.make_item_collectible.emit(rod)
