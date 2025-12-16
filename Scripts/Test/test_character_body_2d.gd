extends CharacterBody2D

@export var speed = 400
var is_attacking = false # Флаг: атакуем мы сейчас или нет?

func _ready():
	# Подключаем сигнал окончания анимации через код (или можно через редактор во вкладке Node)
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)

func get_user_input():
	# Если мы атакуем, запрещаем двигаться
	if is_attacking:
		velocity = Vector2.ZERO
		return

	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	
	var direction = Input.get_axis("left", "right")
	if direction > 0:
		$AnimatedSprite2D.flip_h = false
	elif direction < 0:
		$AnimatedSprite2D.flip_h = true
	
func get_user_animation():
	# Если мы атакуем, не даем сменить анимацию на бег/стойку
	if is_attacking:
		return

	# Нажали атаку
	if Input.is_action_just_pressed("attack"):
		is_attacking = true # Включаем блокировку
		$AnimatedSprite2D.play("attack")
		return

	if velocity.length() > 0:
		$AnimatedSprite2D.play("move")
	else:
		$AnimatedSprite2D.play("idle")

# Эта функция вызывается сама, когда любая анимация доходит до конца
func _on_animation_finished():
	if $AnimatedSprite2D.animation == "attack":
		is_attacking = false # Снимаем блокировку, атака закончилась

func _physics_process(delta):
	get_user_input()
	get_user_animation()
	move_and_slide()
