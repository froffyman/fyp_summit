extends Area2D
class_name PlayerDetectComponent

signal player_entered
signal player_left



func _on_body_entered(body):
	if body is Player:
		player_entered.emit(body)


func _on_body_exited(body):
	if body is Player:
		player_left.emit(body)
