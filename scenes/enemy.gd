extends CharacterBody2D

@export var speed: float = 40.0
@export var acceleration: float = 3.0 # Controla qué tan rápido acelera y desacelera
var chasing_player = false
var player = null

func _physics_process(delta):
	if chasing_player and player:
		# Calculamos la dirección hacia el jugador
		var direction = (player.position - position).normalized()
		# Aplicamos movimiento suave con lerp()
		velocity = velocity.lerp(direction * speed, acceleration * delta)

		move_and_slide()

		# Animaciones
		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.flip_h = velocity.x < 0
	else:
		$AnimatedSprite2D.play("idle")
		# Reducimos la velocidad poco a poco al perder el objetivo
		velocity = velocity.lerp(Vector2.ZERO, acceleration * delta)
		move_and_slide()

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"): # Aseguramos que solo detecta al jugador
		player = body
		chasing_player = true

func _on_detection_area_body_exited(body):
	if body == player:
		chasing_player = false
