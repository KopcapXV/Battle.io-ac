extends Node

var mutexPlayersPosition : Mutex = Mutex.new()
var players_position : Dictionary[int, Vector2]

var mutexPlayersDirection : Mutex = Mutex.new()
var players_direction : Dictionary[int, Vector2]

var players : Dictionary[int, Player]
