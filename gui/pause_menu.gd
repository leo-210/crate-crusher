extends Control


@onready var audio: AudioStreamPlayer2D = $Click
@onready var settings: Control = $Settings


func _ready() -> void:
	settings.visible = false


func _on_resume_pressed() -> void:
	get_tree().paused = false
	visible = false


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://gui/main_menu.tscn")


func _on_resume_mouse_entered() -> void:
	audio.play()


func _on_menu_mouse_entered() -> void:
	audio.play()


func _on_settings_pressed() -> void:
	settings.visible = true


func _on_settings_mouse_entered() -> void:
	audio.play()
