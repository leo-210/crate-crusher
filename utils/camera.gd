extends Camera2D

@export var shake_strength: float = 2

@onready var shake_cooldown: Timer = $ShakeCooldown

var noise := FastNoiseLite.new()

var shaking := false
var shake_offset: Vector2


func _ready() -> void:
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.fractal_type = FastNoiseLite.FRACTAL_NONE


func _process(delta: float) -> void:
	
	if shaking and Globals.screen_shake:
		offset = Vector2(
				noise.get_noise_1d(Time.get_ticks_msec()) * shake_strength,
				noise.get_noise_1d(Time.get_ticks_msec() + 1000) * shake_strength
		)
	else:
		offset = Vector2.ZERO


func shake() -> void:
	shaking = true
	shake_cooldown.start()


func _on_shake_cooldown_timeout() -> void:
	shaking = false
