class_name PlayersManager
extends Node2D

var update_players_direction_timer : Timer

const SYNC_SPEED : float = 4.0

@export var game_hud : Node

func _ready() -> void:
	update_players_direction_timer = Timer.new()
	update_players_direction_timer.one_shot = false
	update_players_direction_timer.autostart = true
	update_players_direction_timer.wait_time = 0.2
	update_players_direction_timer.timeout.connect(_update_players_position)
	add_child(update_players_direction_timer)
	update_players_direction_timer.start()
	
func _process(delta: float) -> void:
	GAME_DATA.mutexPlayersDirection.lock()
	for player_index : int in GAME_DATA.players_direction.keys():
		if !GAME_DATA.players.has(player_index): 
			#print("<Players Manager> : skip set direction, hasn't player index: ", player_index)
			continue
		if player_index == CLIENT.globalId: 
			#print("<Players Manager> : player_index == CLIENT.globalId, player_index is ", player_index, " and globalId is ", CLIENT.globalId)
			continue
		
		if GAME_DATA.players[player_index].state_move.direction != GAME_DATA.players_direction[player_index]:
			GAME_DATA.players[player_index].state_move.direction = GAME_DATA.players_direction[player_index]
			#print("<Global ID> : ",CLIENT.globalId, " <Players Manager> : update player ", player_index, " direction on ", GAME_DATA.players_direction)
	GAME_DATA.mutexPlayersDirection.unlock()
	
	GAME_DATA.mutexPlayersPosition.lock()
	for player_index : int in GAME_DATA.players_position.keys():
		if !GAME_DATA.players.has(player_index):
			GAME_DATA.players[player_index] = create_player(!(CLIENT.globalId == player_index), player_index)
			#print("<Players Manager> : added player with id ", player_index)
			
		GAME_DATA.players[player_index].global_position = lerp(GAME_DATA.players[player_index].global_position, GAME_DATA.players_position[player_index], delta * SYNC_SPEED)
		
		#print("<Players Manager> : update position player at index ", player_index, " to ", GAME_DATA.players[player_index].global_position)
		
	GAME_DATA.mutexPlayersPosition.unlock()

func create_player(another : bool, global_id : int) -> Player:
	var player : Player
	#if another: player = load("uid://sdxyefjbc3rv").instantiate()
	#else: return
	player = load("uid://sdxyefjbc3rv").instantiate() if another else load("uid://4d6xpcythvwe").instantiate()
	if player is AnotherPlayer: print("<Players Manager> : created another player")
	else: print("<Players Manager> : created just player with id ", global_id)
	add_child(player)
	connect_HUD_to_player(player)
	player.id = global_id
	return player

func _update_players_position():
	pass
	
func connect_HUD_to_player (player : Player) -> void:
	if (player is not AnotherPlayer):
		game_hud.Initialize_HUD(player.stat_health, player.current_health, player.stat_mana, player.current_mana)
		player._on_health_changed.connect(game_hud.Update_health_bar)
		player._on_ability_used.connect(game_hud.Start_cooldown)
