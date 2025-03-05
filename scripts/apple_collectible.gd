extends StaticBody2D

@export var item: InvItem

func _on_area_2d_body_entered(body):
	if body.has_method("collect"):
		body.collect(item)
		queue_free()

