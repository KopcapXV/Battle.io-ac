extends Node

signal GameStateIsInit
signal GameStateIsPlay
signal GameStateIsStop
signal GameStateIsQuit
var should_show_results: bool = false

enum GAME_STATES
{
	INIT,
	PLAY,
	STOP, 
	QUIT
}

var game_states : GAME_STATES = GAME_STATES.QUIT:
	get: return game_states
	set(value):
		if value == game_states: return
		game_states = value
		match value:
			GAME_STATES.INIT:
				GameStateIsInit.emit()
			GAME_STATES.PLAY:
				GameStateIsPlay.emit()
			GAME_STATES.STOP:
				GameStateIsStop.emit()
				should_show_results = true
			GAME_STATES.QUIT:
				GameStateIsQuit.emit()
		print("<Global> : game state changed to ", GAME_STATES.keys()[game_states])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.GameStateChanged.connect(func(x : int): game_states = x)
