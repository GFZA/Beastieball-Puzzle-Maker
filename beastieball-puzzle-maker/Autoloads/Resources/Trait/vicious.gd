@tool
extends Trait


func special_cal_formula(damage : int, attacker : Beastie, _defender : Beastie, _attack : Attack) -> int: # Overwrite
	if attacker.my_trait.name.to_lower() == "vicious":
		return max(damage, 30)
	return damage
