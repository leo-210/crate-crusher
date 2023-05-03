extends Node2D


@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var score = 0


func _ready() -> void:
	label.text = str(score)
	
	position = position + -label.size / 2
	
	animation_player.play("default")
