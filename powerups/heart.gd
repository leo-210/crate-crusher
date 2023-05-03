extends AnimatableBody2D
class_name Heart


@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play("default")
