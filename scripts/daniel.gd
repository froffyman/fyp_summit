extends Node2D


@onready var dialogue = %DialogueComponent

func _ready():
	dialogue.custom_sig.connect(drop_sword)

func drop_sword(sig):
	if sig == "give_sword":
		print("dropping sword!")
		var sword = InvSlot.new()
		sword.item = preload("res://resources/items/daniels_sword.tres")
		sword.amount = 1
		SignalManager.make_item_collectible.emit(sword)
