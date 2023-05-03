extends Control


@onready var sprite: Sprite2D = $Sprite2D
@onready var button_hover: AudioStreamPlayer2D = $ButtonHover
@onready var music: AudioStreamPlayer2D = $Music
@onready var settings: Control = $Settings

const speed = 7


func _ready() -> void:
	get_tree().paused = false
	
	music.volume_db = -20
	
	var tweeen: Tween = get_tree().create_tween()
	tweeen.set_ease(Tween.EASE_OUT)
	tweeen.tween_property(music, "volume_db", 0, 1)


func _process(delta: float) -> void:
	sprite.position += Vector2(-1, -sprite.get_rect().size.y/sprite.get_rect().size.x) * delta * speed
	if sprite.position <= Vector2.ZERO:
		sprite.position = sprite.get_rect().size / 2


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://main/main.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _click() -> void:
	button_hover.play()


func _on_settings_pressed() -> void:
	settings.visible = true

