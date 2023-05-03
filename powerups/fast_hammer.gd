extends AnimatableBody2D
class_name FastHammer


@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play("default")
