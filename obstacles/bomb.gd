extends StaticBody2D
class_name Bomb


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D


func detroy() -> void:
	audio.play()
	sprite.play("explode")
	collision.disabled = true


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
