extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	global_position = get_global_mouse_position()
	
	#var vec = get_viewport().get_mouse_position() - self.position # getting the vector from self to the mouse
	#vec = vec.normalized() * delta * SPEED # normalize it and multiply by time and speed
	#position += vec # move by that vector
	#print(position)

