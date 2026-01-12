extends Node

signal GameStateChanged (game_state : int)
signal PlayerDamaged (global_id : int, health : int, damage : int) # health - how many health player have
signal PlayerKilled (global_id : int)
signal ChatStateChanged (is_open : bool)
signal ChatMessageWasGet(global_id : int, text : String)
signal LeaderboardWasget(global_id : int, leaders : Array [Leader])
