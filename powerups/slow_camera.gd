extends AnimatableBody2D
class_name SlowCamera


@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play("default")
