extends StaticBody2D
class_name WoodenCrate


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var heart = preload("res://powerups/heart.tscn")
@onready var speed_up = preload("res://powerups/speed_up.tscn")
@onready var fast_hammer = preload("res://powerups/fast_hammer.tscn")
@onready var slow_camera = preload("res://powerups/slow_camera.tscn")
@onready var ScoreLabel = preload("res://utils/score_label.tscn")
@onready var timer: Timer = $Timer
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D


func detroy() -> void:
	sprite.play("detroyed")
	collision.disabled = true 
	timer.start()
	audio.play()


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()


func _on_timer_timeout() -> void:
	var heart_prob = 1.0/float(2 * Globals.player_health + 1) / 1.5
	var fast_hammer_prob = 0.05
	var speed_up_prob = 0.01
	var slow_camera_prob = (max(Globals.camera_speed, 0.35) - 0.349999)
	
	var rnd = randf()
	
	if rnd < heart_prob:
		var instance = heart.instantiate()
		instance.position = position
		get_tree().get_root().add_child(instance)
	elif rnd < speed_up_prob + heart_prob:
		var instance = speed_up.instantiate()
		instance.position = position
		get_tree().get_root().add_child(instance)
	elif rnd < fast_hammer_prob + speed_up_prob + heart_prob:
		var instance = fast_hammer.instantiate()
		instance.position = position
		get_tree().get_root().add_child(instance)
	elif rnd < slow_camera_prob + fast_hammer_prob + speed_up_prob + heart_prob:
		var instance = slow_camera.instantiate()
		instance.position = position
		get_tree().get_root().add_child(instance)
	else:
		var instance = ScoreLabel.instantiate()
		instance.position = global_position
		instance.score = 100
		get_tree().get_root().add_child(instance)
		
		EventBus.score_up.emit(100)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
