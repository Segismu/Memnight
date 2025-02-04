extends CharacterBody2D

var enemy_in_attack_range = false
var enemy_attack_cooldown = true
var health = 200
var player_alive = true

var attacking = false
var last_input_dir = Vector2.ZERO  # Guarda la última dirección de movimiento

# Coyote time (permite mover después de atacar)
var coyote_time = 0.1
var coyote_time_timer = 0.0

@export var speed: float = 100.0

func _ready():
	$AnimatedSprite2D.play("front_idle")

func _physics_process(delta):
	if not attacking or coyote_time_timer > 0:
		coyote_time_timer = max(0, coyote_time_timer - delta)
		player_movement()
		move_and_slide()
		current_camera()

	if coyote_time_timer <= 0:
		update_animation()
		attack()

	enemy_attack()

	if health <= 0:
		die()

func player_movement():
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed
	
	# Solo actualizamos `last_input_dir` si el jugador se está moviendo
	if input_dir != Vector2.ZERO:
		last_input_dir = input_dir

func update_animation():
	var anim = $AnimatedSprite2D
	
	if attacking:
		play_attack_animation()
		return
	
	if velocity.x != 0:
		anim.flip_h = velocity.x < 0
		anim.play("side_walk")
	elif velocity.y > 0:
		anim.play("front_walk")
	elif velocity.y < 0:
		anim.play("back_walk")
	else:
		play_idle_animation()

func play_idle_animation():
	var anim = $AnimatedSprite2D
	if anim.animation == "side_walk":
		anim.play("side_idle")
	elif anim.animation == "front_walk":
		anim.play("front_idle")
	elif anim.animation == "back_walk":
		anim.play("back_idle")

func play_attack_animation():
	var anim = $AnimatedSprite2D
	if last_input_dir.x != 0:
		anim.flip_h = last_input_dir.x < 0
		anim.play("side_attack")
	elif last_input_dir.y > 0:
		anim.play("front_attack")
	elif last_input_dir.y < 0:
		anim.play("back_attack")

func attack():
	if Input.is_action_just_pressed("attack") and not attacking:
		Global.player_current_attack = true
		attacking = true
		coyote_time_timer = coyote_time
		play_attack_animation()
		$deal_attack_timer.start()

func _on_deal_attack_timer_timeout():
	$deal_attack_timer.stop()
	Global.player_current_attack = false
	attacking = false

func _on_player_hitbox_area_entered(area):
	if area.name == "enemy_hitbox":
		enemy_in_attack_range = true

func _on_player_hitbox_area_exited(area):
	if area.name == "enemy_hitbox":
		enemy_in_attack_range = false

func enemy_attack():
	if enemy_in_attack_range and enemy_attack_cooldown:
		health -= 20
		enemy_attack_cooldown = false
		$attack_cooldown.start()
		print(health)

func _on_attack_cooldown_timeout():
	enemy_attack_cooldown = true

func die():
	player_alive = false
	health = 0
	print("You died")
	queue_free()
	
func current_camera():
	if Global.current_scene == "world":
		$world_camera.enabled = true
		$cliftside_camera.enabled = false
	elif Global.current_scene == "clift_side":
		$world_camera.enabled = false
		$cliftside_camera.enabled = true
