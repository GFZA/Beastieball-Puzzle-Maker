@tool
extends Trait


func special_cal_formula(damage : int) -> int:
	return max(damage, 30)
