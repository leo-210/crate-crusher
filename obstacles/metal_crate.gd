extends StaticBody2D
class_name MetalCrate


@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
