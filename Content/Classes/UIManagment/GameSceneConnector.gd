extends Node2D
#
#@onready var player = $Player
#
#@onready var game_hud = $Player/HUD
#
#func _ready () -> void:
	#game_hud.Init_bars(player.stat_health, player.current_health, player.stat_mana, player.current_mana)
	#player._on_health_changed.connect(game_hud.Update_health_bar)
	#player._on_ability_used.connect(game_hud.Start_cooldown)
	#
#func _input(event) -> void:
	#if (player and event.is_action_pressed("take")):
		#player.Take_damage(10)
		#print("took")
