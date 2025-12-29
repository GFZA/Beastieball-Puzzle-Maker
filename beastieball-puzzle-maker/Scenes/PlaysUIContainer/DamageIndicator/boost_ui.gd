@tool
class_name BoostUI
extends MarginContainer

## Only support displaying 2 types of boosts!

const PLACEHOLDER_TEXT := "No BOOSTs"

@export var beastie : Beastie = null :
	set(value):
		if not value:
			if beastie.current_boosts_updated.is_connected(_update_boost_label):
				beastie.current_boosts_updated.disconnect(_update_boost_label)
			_update_boost_label({})
			beastie = value

		beastie = value
		beastie.current_boosts_updated.connect(_update_boost_label)
		_update_boost_label(beastie.current_boosts)

@onready var boost_label: RichTextLabel = %BoostLabel


func _update_boost_label(new_boost_dict : Dictionary[Beastie.Stats, int]) -> void:
	if not is_node_ready():
		await ready

	if not new_boost_dict or new_boost_dict.is_empty():
		boost_label.text = PLACEHOLDER_TEXT
		return

	var new_text : String = ""
	var keys := new_boost_dict.keys() as Array[Beastie.Stats]
	var count : int = 0
	for key : Beastie.Stats in keys:
		var icon_text : String = ""
		match (key):
			Beastie.Stats.B_POW, Beastie.Stats.B_DEF:
				icon_text = "BODY" + " "
			Beastie.Stats.S_POW, Beastie.Stats.S_DEF:
				icon_text = "SPIRIT" + " "
			Beastie.Stats.M_POW, Beastie.Stats.M_DEF:
				icon_text = "MIND" + " "

		var middle_text : String = ""
		match (key):
			Beastie.Stats.B_POW, Beastie.Stats.S_POW, Beastie.Stats.M_POW:
				middle_text = "POW" + " "
			Beastie.Stats.B_DEF, Beastie.Stats.S_DEF, Beastie.Stats.M_DEF:
				middle_text = "DEF" + " "

		new_text += icon_text + middle_text + _get_boost_icon_keyword(new_boost_dict[key])
		if count != keys.size() - 1:
			new_text += " \n "

	new_text = Global.get_iconified_text(new_text, false)
	new_text = new_text.replace(" ", "")
	boost_label.text = new_text


func _get_boost_icon_keyword(amount : int) -> String:
	var result : String = ""
	var base_keyword : String = "UP" if signi(amount) > 0 else "DOWN"

	if amount == 0:
		return ""

	amount = abs(amount)
	if amount > 9:
		result += base_keyword + str(amount) # Don't make icon as it should't be possible
		return result

	var stack : int = floori(float(amount) / 3.0)
	var fraction : int = amount - (stack * 3)
	if stack > 0:
		for i in stack:
			result += base_keyword + "3" + " "
	if fraction > 0:
		result += base_keyword + str(fraction)

	return result
