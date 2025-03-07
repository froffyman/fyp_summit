extends CharacterBody2D

@onready var slime = %Slime
@onready var player_detection = %PlayerDetectComponent
@onready var atk_cooldown = %AtkCooldown
@onready var hurtbox = %HurtboxComponent

var is_player: bool = false
var player: Player

var SPEED = 50

const BULLET = preload("res://scenes/slime_bullet.tscn")

func _ready():
	player_detection.player_entered.connect(player_found)
	player_detection.player_left.connect(player_lost)

func _physics_process(delta):
	if is_player:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * SPEED
		move_and_slide()

func player_found(plr: Player):
	play_anim("walk")
	is_player = true
	player = plr
	atk_cooldown.start()

func player_lost():
	is_player = false
	player = null
	play_anim("idle")
	atk_cooldown.stop()

func play_anim(anim: String):
	if slime.sprite_frames.get_animation_names().has(anim):
		slime.play(anim)

func _on_slime_animation_finished():
	if slime.animation == "hurt":
		if is_player:
			play_anim("walk")
		else:
			play_anim("idle")
	elif slime.animation == "death":
		SignalManager.enemy_died.emit()
		queue_free()

func _on_atk_cooldown_timeout():
	if is_player:
		for i in range(0, 4):
			var new_bullet = BULLET.instantiate()
			add_sibling(new_bullet)
			new_bullet.global_position = global_position
			new_bullet.global_rotation = global_rotation + deg_to_rad((90 * i))
			
			
			new_bullet.add_to_whitelist(hurtbox)
