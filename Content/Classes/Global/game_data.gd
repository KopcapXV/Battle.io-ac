extends Node

var mutexPlayersPosition : Mutex = Mutex.new()
var players_position : Dictionary[int, Vector2]

var mutexPlayersDirection : Mutex = Mutex.new()
var players_direction : Dictionary[int, Vector2]

var mutexBulletsPosition : Mutex = Mutex.new()
var bullets_position : Dictionary[int, Vector2]

func clear():
	players_position.clear()
	players_direction.clear()
	bullets_position.clear()
	mutexPlayersPosition = Mutex.new()
	mutexPlayersDirection = Mutex.new()
	mutexBulletsPosition = Mutex.new()
