extends Node

var player_current_attack = false

var current_scene = "world"
var transition_scene = false	

var player_exit_cliftside_posx = 0
var player_exit_cliftside_posy = 0

var player_start_cliftside_posx = 0
var player_start_cliftside_posy = 0

func	 finish_change_scenes():
	if transition_scene == true:
		transition_scene = false
		if current_scene == "world":
			current_scene = "clift_side"
		else:
			current_scene = "world"
