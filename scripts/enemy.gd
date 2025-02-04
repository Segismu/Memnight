extends CharacterBody2D

@export var speed: float = 40.0
@export var acceleration: float = 3.0 # Controla qué tan rápido acelera y desacelera
var chasing_player = false
var player = null

var health = 100
var player_in_attack_range = false
var can_take_damage = true

func _physics_process(delta):
	damage()
	
	if chasing_player and player:
		var direction = (player.position - position).normalized()
		var target_velocity = direction * speed
		velocity = velocity.lerp(target_velocity, acceleration * delta)

		# Intentamos movernos y detectamos si chocamos con algo
		var collision = move_and_collide(velocity * delta)
		
		# Si hay colisión, evitamos seguir empujando al jugador
		if collision:
			velocity = Vector2.ZERO

		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.flip_h = velocity.x < 0
	else:
		velocity = velocity.lerp(Vector2.ZERO, acceleration * delta)
		move_and_slide()
		$AnimatedSprite2D.play("idle")

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"): # Aseguramos que solo detecta al jugador
		player = body
		chasing_player = true

func _on_detection_area_body_exited(body):
	if body == player:
		chasing_player = false

func _on_enemy_hitbox_area_entered(area):
	# Asegurar que es enemy_hitbox y no otra área
	if area.name == "player_hitbox":
		print("¡Detectó al jugador!")
		player_in_attack_range = true


func _on_enemy_hitbox_area_exited(area):
		if area.name == "player_hitbox":
			player_in_attack_range = false

func damage():
	if player_in_attack_range and Global.player_current_attack:
		if can_take_damage:
			health = health - 20
			$take_damage_cooldown.start()
			can_take_damage = false
			print("Slime health =", health)
			if health <= 0:
				self.queue_free()


func _on_take_damage_cooldown_timeout():
	can_take_damage = true
