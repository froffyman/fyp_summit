extends Node2D

@onready var hitbox: HitboxComponent = %HitboxComponent

var SPEED = 100
var RANGE = 300

var travelled_distance = 0

func _ready():
	hitbox.completed.connect(queue_free)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta
	
	travelled_distance += SPEED * delta
	if travelled_distance > RANGE:
		queue_free()

func add_to_whitelist(hurtbox: HurtboxComponent):
	hitbox.add_to_whitelist(hurtbox)
