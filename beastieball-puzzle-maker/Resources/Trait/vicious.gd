@tool
extends Trait


func special_cal_formula(damage : int, _attacker : Beastie, _defender : Beastie, _attack : Attack) -> int: # Overwrite
	return max(damage, 30)
