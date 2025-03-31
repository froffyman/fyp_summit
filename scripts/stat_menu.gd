extends Control

@export var stats_resource: PlrStats
@export var plr: Player

@onready var fish_lvl = %FishingLvl
@onready var fish_exp = %FishingEXP
@onready var cmbt_lvl = %CombatLvl
@onready var cmbt_exp = %CombatEXP

func update(fl, cl, fe, ce):
	print("Update Detected!")
	fish_lvl.text = str(fl)
	cmbt_lvl.text = str(cl)
	
	fish_exp.max_value = fl * 100
	fish_exp.value = fe
	
	cmbt_exp.max_value = cl * 100
	cmbt_exp.value = ce

