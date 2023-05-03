extends CharacterBody2D


@export var speed: float = 80
@export var acceleration: float = 600
@export var friction: float = 18

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hammer_cooldown: Timer = $HammerCooldown
@onready var range_: Area2D = $Range
@onready var damage_timer: Timer = $DamageTimer
@onready var hit_timer: Timer = $HitTimer
@onready var collection_box: Area2D = $CollectionBox
@onready var ScoreLabel = preload("res://utils/score_label.tscn")
@onready var heart_audio: AudioStreamPlayer2D = $HeartAudio
@onready var speed_up_timer: Timer = $SpeedUpTimer
@onready var fast_hammer_cooldown: Timer = $FastHammerCooldown

var hitting = false
var hit = false
var dead = false
var speed_modifier = 1.0

signal lost_health
signal gained_health

signal slow_camera
signal fast_hammer_start
signal fast_hammer_end
signal speed_up_start
signal speed_up_end


func _ready() -> void:
	sprite.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var dir = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	)
	
	if Input.is_action_just_pressed("hammer") and hitting == false and hit == false and dead == false:
		sprite.play("hammer")
		hitting = true
		hammer_cooldown.start()
		velocity = Vector2.ZERO
		
		var bodies = range_.get_overlapping_bodies()
		if len(bodies) > 0:
			var body
			if len(bodies) > 1:
				if Input.is_action_pressed("right"):
					var bodies2 = bodies
					for x in bodies2:
						if not Globals.tile_map.local_to_map(x.position).x > Globals.tile_map.local_to_map(position).x:
							bodies2.erase(x)
					
					if len(bodies2) == 1:
						body = bodies[0]
					else:
						bodies.sort_custom(_getBottomBody)
						body = bodies[0]
				elif Input.is_action_pressed("up"):
					var bodies2 = bodies
					for x in bodies2:
						if not Globals.tile_map.local_to_map(x.position).y < Globals.tile_map.local_to_map(position).y:
							bodies2.erase(x)
					if len(bodies2) == 1:
						body = bodies[0]
					else:
						bodies.sort_custom(_getBottomBody)
						body = bodies[0]
				elif Input.is_action_pressed("down"):
					var bodies2 = bodies
					for x in bodies2:
						if not Globals.tile_map.local_to_map(x.position).y > Globals.tile_map.local_to_map(position).y:
							bodies2.erase(x)
					
					if len(bodies2) == 1:
						body = bodies[0]
					else:
						bodies.sort_custom(_getBottomBody)
						body = bodies[0]
				else:
					bodies.sort_custom(_getBottomBody)
					body = bodies[0]
			else:
				body = bodies[0]
			
			if body is WoodenCrate:
				body.detroy()
			if body is Bomb:
				hit_timer.start()
				body.detroy()
			if body is MetalCrate:
				body.audio.play()
	
	if hitting or hit or dead:
		dir = Vector2.ZERO
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	else:
		velocity = velocity.move_toward(dir * speed * speed_modifier, acceleration * delta)
		
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
		if velocity.length_squared() < 100:
			sprite.play("default")
		else:
			sprite.play("walk")
	
	move_and_slide()
	
	var powerups = collection_box.get_overlapping_bodies()
	for powerup in powerups:
		if powerup is Heart:
			if Globals.player_health == 3:
				var instance = ScoreLabel.instantiate()
				instance.position = powerup.global_position
				instance.score = 1000
				get_tree().get_root().add_child(instance)
		
				EventBus.score_up.emit(1000)
			else:
				gained_health.emit()
		elif powerup is SlowCamera:
			slow_camera.emit()
		
		elif powerup is SpeedUp:
			speed_up_timer.start()
			speed_modifier = 1.5
			speed_up_start.emit()
		
		elif powerup is FastHammer:
			fast_hammer_cooldown.start()
			hammer_cooldown.wait_time = 0.05
			fast_hammer_start.emit()
		
		powerup.queue_free()
		heart_audio.play()
	
	if dead:
		sprite.play("hit")


func _on_hammer_cooldown_timeout() -> void:
	hitting = false


func _on_animated_sprite_2d_animation_finished() -> void:
	sprite.play("default")


func _getBottomBody(a: Node2D, b: Node2D) -> bool:
	if a is MetalCrate:
		return false
	if b is MetalCrate:
		return true
	if a.position.x == b.position.x:
		return a.position.y > b.position.y
	return a.position.x > b.position.x


func _hit() -> void:
	sprite.play("hit")
	damage_timer.start()
	velocity = Vector2(-100, 0)
	lost_health.emit()


func _on_damage_timer_timeout() -> void:
	sprite.play("default")


func _on_speed_up_timer_timeout() -> void:
	speed_modifier = 1.0
	speed_up_end.emit()


func _on_fast_hammer_cooldown_timeout() -> void:
	hammer_cooldown.wait_time = 0.5
	fast_hammer_end.emit()
