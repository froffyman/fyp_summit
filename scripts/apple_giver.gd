extends Area2D

@export var item: InvItem

func _on_body_entered(body):
	if body.has_method("collect"):
		body.collect(item)
