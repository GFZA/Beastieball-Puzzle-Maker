@tool
extends Trait


func get_attack_mult(_attacker : Beastie, _defender : Beastie, _attack : Attack, \
					 _attacker_team_controller : TeamController = null,\
					 _defender_team_controller : TeamController = null) -> float: # Overwrite
	# TODO Trait condition : Musclebrain. oh god...
	return 1.0
