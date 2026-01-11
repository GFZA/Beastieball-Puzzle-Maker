@tool
extends Attack


func get_attack_pow(_attacker : Beastie, _defender : Beastie, \
					 _attacker_team_controller : TeamController = null,\
					 _defender_team_controller : TeamController = null) -> int: # Overwrite
	# TODO Attack condition : Comeback
	return base_pow
