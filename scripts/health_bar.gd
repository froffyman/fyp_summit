extends NinePatchRect

@export var health: HealthComponent

@onready var bar = %ProgressBar

func _ready():
	if health:
		bar.max_value = health.MAX_HEALTH
		bar.value = health.MAX_HEALTH
		health.hurt.connect(update_progress)
		health.dead.connect(update_progress)
		health.healed.connect(update_progress)

func update_progress():
	bar.value = health.current_health
