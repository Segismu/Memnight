extends CharacterBody2D

var enemy_in_attack_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true

var attacking = false
var last_input_dir = Vector2.ZERO  # Variable para guardar la última dirección de movimiento

# Coyote time
var coyote_time = 0.1  # Duración del tiempo de gracia para mover después de atacar
var coyote_time_timer = 0.0

@export var speed: float = 100.0

func _ready():
	$AnimatedSprite2D.play("front_idle")

func _physics_process(delta):
	if not attacking:  # Si no estamos atacando, permitimos el movimiento
		player_movement()
		move_and_slide()
	elif coyote_time_timer > 0:  # Si estamos en coyote time, permitimos mover al jugador
		coyote_time_timer -= delta
		player_movement()  # Permitimos el movimiento en coyote time
		move_and_slide()

	# Actualizamos la animación y verificamos el ataque solo si no estamos en coyote time
	if coyote_time_timer <= 0:
		update_animation()
		attack()

	enemy_attack()

	if health <= 0:
		player_alive = false # die end respawn
		health = 0
		print("You died")
		self.queue_free()

func player_movement():
	# Obtiene la dirección del input
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Aplica la velocidad directamente
	velocity = input_dir * speed
	last_input_dir = input_dir  # Guardamos la última dirección de movimiento

func update_animation():
	var anim = $AnimatedSprite2D
	
	# Si está atacando, no se actualiza la animación de caminar
	if attacking:
		# Las animaciones de ataque se deben ejecutar independientemente de la dirección de movimiento
		if last_input_dir.x > 0:
			anim.flip_h = false
			anim.play("side_attack")
		elif last_input_dir.x < 0:
			anim.flip_h = true
			anim.play("side_attack")
		elif last_input_dir.y > 0:
			anim.play("front_attack")
		elif last_input_dir.y < 0:
			anim.play("back_attack")
		return  # Salimos de la función para evitar sobreescribir con "idle"
	
	# Si no está atacando, cambiamos la animación según el movimiento
	if velocity.x > 0:
		anim.flip_h = false
		anim.play("side_walk")
	elif velocity.x < 0:
		anim.flip_h = true
		anim.play("side_walk")
	elif velocity.y > 0:
		anim.play("front_walk")
	elif velocity.y < 0:
		anim.play("back_walk")
	else:
		# Cambia a idle si no se está moviendo
		if last_input_dir.x == 0 and last_input_dir.y == 0:  # Solo entramos en idle si no hay movimiento
			if anim.animation == "side_walk":
				anim.play("side_idle")
			elif anim.animation == "front_walk":
				anim.play("front_idle")
			elif anim.animation == "back_walk":
				anim.play("back_idle")

func _on_player_hitbox_area_entered(area):
	# Asegurar que es enemy_hitbox y no otra área
	if area.name == "enemy_hitbox":
		print("¡Detectó un enemigo para atacar!")
		enemy_in_attack_range = true

func _on_player_hitbox_area_exited(area):
	if area.name == "enemy_hitbox":
		enemy_in_attack_range = false

func enemy_attack():
	if enemy_in_attack_range and enemy_attack_cooldown:
		health = health - 20
		enemy_attack_cooldown = false
		$attack_cooldown.start()
		print(health)

func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true

func attack():
	# Obtiene la dirección de movimiento (para saber a qué dirección atacar)
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Solo atacamos si no estamos ya en un estado de ataque
	if Input.is_action_just_pressed("attack") and not attacking:
		Global.player_current_attack = true
		attacking = true  # Activamos el estado de ataque
		coyote_time_timer = coyote_time  # Activamos el coyote time
		
		# Cambiamos la animación según la dirección del input
		if input_dir.x > 0:  # Movimiento hacia la derecha
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("side_attack")
		elif input_dir.x < 0:  # Movimiento hacia la izquierda
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("side_attack")
		elif input_dir.y > 0:  # Movimiento hacia abajo
			$AnimatedSprite2D.play("front_attack")
		elif input_dir.y < 0:  # Movimiento hacia arriba
			$AnimatedSprite2D.play("back_attack")
		
		# Inicia el temporizador de ataque
		$deal_attack_timer.start()

func _on_deal_attack_timer_timeout() -> void:
	$deal_attack_timer.stop()
	Global.player_current_attack = false
	attacking = false
