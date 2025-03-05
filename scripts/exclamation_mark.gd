extends AnimatableBody2D

@onready var anim_player = %AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Input.is_action_just_released("click"):
		fade()

func fade():
	anim_player.play("fade")
