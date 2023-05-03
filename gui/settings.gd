extends Control


@onready var music_slider: HSlider = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/MusicSlider
@onready var sound_slider: HSlider = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer2/SoundSlider
@onready var audio: AudioStreamPlayer2D = $audio
@onready var sound_timer: Timer = $SoundTimer
@onready var check_box: CheckButton = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CheckBox

var music_sliding = false
var sound_sliding = false


func _ready() -> void:
	check_box.button_pressed = Globals.screen_shake


func _process(delta: float) -> void:
	if music_sliding:
		if music_slider.value == 0:
			AudioServer.set_bus_mute(1, true)
		else:
			AudioServer.set_bus_mute(1, false)
		AudioServer.set_bus_volume_db(1, (music_slider.value - 75)/100 * 60)
	if sound_sliding: 
		if sound_slider.value == 0:
			AudioServer.set_bus_mute(2, true)
		else:
			AudioServer.set_bus_mute(2, false)
		AudioServer.set_bus_volume_db(2, (sound_slider.value - 75)/100 * 60)


func _on_music_slider_drag_ended(value_changed: bool) -> void:
	music_sliding = false


func _on_sound_slider_drag_ended(value_changed: bool) -> void:
	sound_sliding = false
	sound_timer.stop()


func _on_music_slider_drag_started() -> void:
	music_sliding = true


func _on_sound_slider_drag_started() -> void:
	sound_sliding = true
	sound_timer.start()
	audio.play()


func _on_sound_timer_timeout() -> void:
	audio.play()


func _click() -> void:
	audio.play()


func _on_button_pressed() -> void:
	visible = false


func _on_check_box_toggled(button_pressed: bool) -> void:
	Globals.screen_shake = button_pressed
	print(Globals.screen_shake)
