extends Node

@export var label_for_kills : Label
@export var label_for_deaths : Label
@export var label_for_killstreak : Label
@export var label_for_score : Label
@export var label_for_result :  Label

func _ready () -> void:
	Show_results()
	
func SERVER_Get_match_results () -> MatchResults:
	var results = MatchResults.new()
	results.isWin = 0
	results.kills_count = 0
	results.deaths_count = 0
	results.best_killstreak = 0
	results.score_count = 0
	# --- # ---
	# SERVER Request
	# --- # ---
	return results

func Show_results () -> void:
	var results = SERVER_Get_match_results()
	label_for_kills.text = str(results.kills_count)
	label_for_deaths.text = str(results.deaths_count)
	label_for_killstreak.text = str(results.best_killstreak)
	label_for_score.text = str(results.score_count)
	if (results.isWin == false):
		label_for_result.text = "ПОРАЖЕНИЕ"
	else:
		label_for_result.text = "ПОБЕДА"
