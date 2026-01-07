@tool
extends Trait


func special_cal_formula(damage : int, _attacker : Beastie, _defender : Beastie, _attack : Attack) -> int: # Overwrite
	# TODO Trait condition : Stagecraft
	#if RALLY or DREAD:
		#return min(66, damage)
	return damage
