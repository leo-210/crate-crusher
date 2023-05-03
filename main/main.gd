extends Node2D


@onready var health_bar: TextureProgressBar = %HealthBar
@onready var score_label: Label = %Score
@onready var player: CharacterBody2D = $Player
@onready var tile_map: TileMap = $TileMap
@onready var camera: Camera2D = $Camera2D
@onready var death_timer: Timer = $DeathTimer
@onready var score_timer: Timer = $ScoreTimer
@onready var music: AudioStreamPlayer2D = $Camera2D/Music
@onready var speed_up: TextureRect = %SpeedUp
@onready var fast_hammer: TextureRect = %FastHammer
@onready var pause_menu: Control = $CanvasLayer/PauseMenu

@onready var wooden_crate = preload("res://obstacles/wooden_crate.tscn")
@onready var metal_crate = preload("res://obstacles/metal_crate.tscn")
@onready var bomb = preload("res://obstacles/bomb.tscn")
@onready var game_over = preload("res://gui/game_over.tscn")

const max_camera_speed = 0.56

var obstacles

var score = 0
var generated = 6
var camera_increment_tick = 0
var camera_increment_index = 0
var camera_speed_factor = 0.5


func _ready() -> void:
	pause_menu.visible = false
	
	obstacles = {
		0.45: 1,
		0.6: 2,
		0.7: 3
	}
	
	Globals.player_health = 3
	health_bar.value = Globals.player_health
	
	EventBus.score_up.connect(_on_score_up)

	_generate_map(generated)
	generated += 20
	
	Globals.tile_map = tile_map


func _physics_process(delta: float) -> void:
	if tile_map.local_to_map(player.position).x >= generated - 20:
		_generate_map(generated)
		generated += 20
	
	camera_increment_index += 1
	Globals.camera_speed = min(
		max_camera_speed * camera_speed_factor * delta * 60 * pow(
			camera_increment_tick * camera_increment_index, 1.0/1.5), max_camera_speed)
	camera.position.x += Globals.camera_speed
	
	if player.position.x < camera.position.x - get_viewport_rect().size.x / 2 - 20:
		Globals.player_health = 0
		health_bar.value = Globals.player_health
	
	if Globals.player_health <= 0 and not player.dead:
		death_timer.start()
		score_timer.stop()
		player.dead = true
	
		var tweeen: Tween = get_tree().create_tween()
		tweeen.set_ease(Tween.EASE_IN)
		tweeen.tween_property(music, "volume_db", -30, 1)
	
	if Input.is_action_just_pressed("pause"):
		pause_menu.visible = true
		get_tree().paused = true


func _on_player_lost_health() -> void:
	Globals.player_health -= 1
	health_bar.value = Globals.player_health
	camera.shake()


func _on_score_up(score_: int) -> void:
	score += score_
	score_label.text = "Score : " + str(score)


func _on_player_gained_health() -> void:
	Globals.player_health = min(health_bar.value + 1, 3)
	health_bar.value = Globals.player_health


func _generate_map(pos_x: int, length: int = 20) -> void:
	var map = [[1, 1, 1, false, false]]
	map[0].shuffle()

	for i in range(length - 1):
		var map_part = []
		while true:
			map_part = _generate_map_part()
			var x = map_part
			x.filter(func (x): return x and x != 2 and x != 3)
			if len(x) == 0:
				continue
			break

		map.append(map_part)
	
	for i in len(map):
		for j in len(map[i]):
			if map[i][j]:
				match map[i][j]:
					1:
						var instance = wooden_crate.instantiate()
						instance.position = tile_map.map_to_local(Vector2i(i + pos_x, j + 2))
						add_child(instance)
					2:
						if j == 0:
							if _check_walls(map, i, j):
								var instance = metal_crate.instantiate()
								instance.position = tile_map.map_to_local(Vector2i(i + pos_x, j + 2))
								add_child(instance)
							else:
								map[i][j] = false
						else:
							var instance = metal_crate.instantiate()
							instance.position = tile_map.map_to_local(Vector2i(i + pos_x, j + 2))
							add_child(instance)
					3:
						var instance = bomb.instantiate()
						instance.position = tile_map.map_to_local(Vector2i(i + pos_x, j + 2))
						add_child(instance)
	for i in len(map):
		tile_map.set_cell(0, Vector2i(pos_x + i, 0), 0, Vector2i(5, 0))
		tile_map.set_cell(0, Vector2i(pos_x + i, 1), 0, Vector2i(5, 1))
		
		for j in len(map[i]):
			if randf() < 0.3:
				tile_map.set_cell(0, Vector2i(pos_x + i, j + 2), 0, Vector2i(4, 3))
			else:
				tile_map.set_cell(0, Vector2i(pos_x + i, j + 2), 0, Vector2i(3, 3))
		
		tile_map.set_cell(0, Vector2i(pos_x + i, 7), 0, Vector2i(5, 2))
	
	Globals.tile_map = tile_map
	Globals.score = score


func _generate_map_part() -> Array:
	var map_part = []
	for j in range(5):
		var rnd = randf()
		map_part.append(false)
		for prob in obstacles.keys():
			if rnd < prob:
				map_part[len(map_part) - 1] = obstacles[prob]
				break
	return map_part


func _on_score_timer_timeout() -> void:
	score += 10
	score_label.text = "Score : " + str(score)


func _on_death_timer_timeout() -> void:
	Globals.score = score
	get_tree().change_scene_to_packed(game_over)


func _on_start_timer_timeout() -> void:
	camera_increment_tick = 0.0005


func _on_player_slow_camera() -> void:
	camera_increment_index = camera_increment_index / 2
	camera_speed_factor += 0.1


func _on_player_fast_hammer_start() -> void:
	fast_hammer.visible = true


func _on_player_fast_hammer_end() -> void:
	fast_hammer.visible = false


func _on_player_speed_up_start() -> void:
	speed_up.visible = true


func _on_player_speed_up_end() -> void:
	speed_up.visible = false


func _check_walls(map: Array, x: int, y: int, direction="") -> bool:
	if x < 0 or x >= len(map) or y < 0 or y >= len(map[x]) \
		or (not map[x][y]) or (map[x][y] and map[x][y] != 2):
		return true
	if y == 4:
		if map[x][y] and map[x][y] == 2:
			return false
		return true
	else:
		if direction != "right" and not _check_walls(map, x - 1, y, "left"):
			return false
		if not _check_walls(map, x - 1, y + 1, "left"):
			return false
		if not _check_walls(map, x, y + 1):
			return false
		if not _check_walls(map, x + 1, y + 1, "right"):
			return false
		if direction != "left" and not _check_walls(map, x + 1, y, "right"):
			return false
	return true
