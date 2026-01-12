class_name BulletsManager
extends Node2D

var bullets : Dictionary[int, Bullet]

const SYNC_SPEED : float = 40.0

func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	GAME_DATA.mutexBulletsPosition.lock()
	for key : int in GAME_DATA.bullets_position.keys():
		if !bullets.has(key):
			bullets[key] = create_bullet(key, GAME_DATA.bullets_position[key])
			#print("<Bullet Manager> : created bullet")
		#print("<Bullet Manager> : bullets: ", bullets)
		bullets[key].global_position = GAME_DATA.bullets_position[key]
	GAME_DATA.mutexBulletsPosition.unlock()

func create_bullet(id : int, bullet_position : Vector2) -> Bullet:
	var bullet : Bullet = load("uid://djhqphnkj3oof").instantiate()
	add_child(bullet)
	bullet.GLOBAL_ID = id
	bullet.global_position = bullet_position
	return bullet
