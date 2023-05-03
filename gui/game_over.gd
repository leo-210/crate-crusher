extends Control


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var score_label: Label = %ScoreLabel
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var music: AudioStreamPlayer2D = $Music


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("default")
	score_label.text = "Score : " + str(Globals.score)
	
	music.volume_db = -30
	
	var tweeen: Tween = get_tree().create_tween()
	tweeen.set_ease(Tween.EASE_OUT)
	tweeen.tween_property(music, "volume_db", 0, 5)


func _on_try_again_pressed() -> void:
	get_tree().change_scene_to_file("res://main/main.tscn")


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://gui/main_menu.tscn")


func _click() -> void:
	audio.play()
