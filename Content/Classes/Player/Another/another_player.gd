extends Player

class_name AnotherPlayer

func _ready ():
	var state_machine : Node = preload("uid://cex6e23a5xqun").instantiate()
	add_child(state_machine)
	
	state_move = get_node("StateMachine/StateMove") 
	
	for_animation_object = $AnimatedSprite2D
	for_collision_object = $CollisionShape2D
	current_health = stat_health
	current_mana = stat_mana

func Take_damage (damage_amount : float) -> void:
	current_health -= damage_amount
	current_health = clamp(current_health, 0, stat_health)
	_on_health_changed.emit(current_health)
	
func Heal (heal_amount : float) -> void:
	current_health += heal_amount
	current_health = clamp(current_health, 0, stat_health) 
	_on_health_changed.emit(current_health)
	
func Die () -> void:
	_on_player_died.emit()
