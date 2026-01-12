extends Control

class_name LeaderboardManager

# -- Array of labels for places
@export var places : Array [Label]
# -- CONST Number of places
const MAX_PLACES : int = 6
# -- CONST Placeholder for no player
const NO_PLAYER : String = "NoName --"

func _ready () -> void:
	var leaders : Array [Leader]
	Initialize_leaderboard(leaders)
	Signals.LeaderboardWasget.connect(SERVER_Get_leaders)

# --- Function server request for the lead places
func SERVER_Get_leaders (id : int, leaders : Array [Leader]) -> Array [Leader]:
	Initialize_leaderboard(leaders)
	return leaders

# --- Function for initializing places
func Initialize_leaderboard (leaders : Array [Leader]) -> void:
	for index in range (MAX_PLACES):
		places[index].text = NO_PLAYER
	leaders.sort_custom(func(a, b): return a.score > b.score)
	var got_data_size = leaders.size()
	for index in range (got_data_size):
		if (leaders[index]):
			places[index].text = (leaders[index].nickname) + (" %d" % leaders[index].score)


# -+- NOT FOR PROD | TEST ONLY FUNCTION -+-
func _input(event) -> void:
	if event.is_action_pressed("take"):
		var leaders1 : Array [Leader]
		var l1 = Leader.new()
		l1.nickname = "Player1"
		l1.score = randi_range(10, 100)
		leaders1.append(l1)
		var l2 = Leader.new()
		l2.nickname = "Player?"
		l2.score = randi_range(5, 99)
		leaders1.append(l2)
		var l3 = Leader.new()
		l3.nickname = "Player?"
		l3.score = randi_range(10, 50)
		leaders1.append(l3)
		var l4 = Leader.new()
		l4.nickname = "Player?"
		l4.score = randi_range(19, 99)
		leaders1.append(l4)
		var l5 = Leader.new()
		l5.nickname = "Player?"
		l5.score = randi_range(10, 39)
		leaders1.append(l5)
		var l6 = Leader.new()
		l6.nickname = "Player?"
		l6.score = randi_range(10, 500)
		leaders1.append(l6)
		Initialize_leaderboard(leaders1)
