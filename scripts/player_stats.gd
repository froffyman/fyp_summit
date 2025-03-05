extends Resource

class_name PlrStats

#Health
@export var health: int
@export var max_health: int

#Skills
@export var fishing_lvl: int
@export var fishing_exp: int

@export var combat_level: int
@export var combat_exp: int
#EXP Level Curve: exp = 100 * (1+0.2)^lvl
