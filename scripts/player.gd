extends CharacterBody2D

var enemy_in_attack_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true

@export var speed: float = 100.0

func _ready():
	$AnimatedSprite2D.play("front_idle")

func _physics_process(delta):
	player_movement()
	update_animation()
	move_and_slide()
	enemy_attack()

func player_movement():
	# Obtiene la dirección del input
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Aplica la velocidad directamente
	velocity = input_dir * speed

func update_animation():
	var anim = $AnimatedSprite2D
	
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
		# Cambia a idle según la última dirección de movimiento
		if anim.animation == "side_walk":
			anim.play("side_idle")
		elif anim.animation == "front_walk":
			anim.play("front_idle")
		elif anim.animation == "back_walk":
			anim.play("back_idle")

func _on_player_hitbox_area_entered(area):
	print("Se activó area_entered con:", area.name)
	
	# Asegurar que es enemy_hitbox y no otra área
	if area.name == "enemy_hitbox":
		print("¡Detectó un enemigo para atacar!")
		enemy_in_attack_range = true

func _on_player_hitbox_area_exited(area):
	if area.name == "enemy_hitbox":
		enemy_in_attack_range = false

func enemy_attack():
	if enemy_in_attack_range:	
		print("-10 HP")
