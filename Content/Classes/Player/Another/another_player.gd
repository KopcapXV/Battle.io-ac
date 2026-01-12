class_name AnotherPlayer
extends Player


func _ready() -> void:
	add_to_group("AnotherPlayer")

func shoot():
	pass 

func get_damage(player_id : int, health : int, damage : int):
	if player_id == id:
		print("<Player> : id ", id,  " getted ", damage)
		
func dead(player_id : int):
	if player_id == id:
		print("<Player> : id ", id,  " dead")
