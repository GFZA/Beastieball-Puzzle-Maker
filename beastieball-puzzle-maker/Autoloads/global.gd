@tool
extends Node

enum MySide {LEFT, RIGHT}

#region Icon Datas
enum Icon {
	ERROR,
	BODY, SPIRIT, MIND, ALL_TYPE,
	VOLLEY, SUPPORT, DEFENSE,
	UP_1, UP_2, UP_3, DOWN_1, DOWN_2, DOWN_3,
	WIPED, TRIED, SHOOK, JAZZED, BLOCKED, WEEPY,
	TOUGH, TENDER, SWEATY, NOISY, ANGRY, NERVOUS, STRESSED,
}
const ICON_PATHS : Dictionary[Icon, String] = {
	Icon.BODY : "res://Autoloads/Icons/icon_body.png",
	Icon.SPIRIT : "res://Autoloads/Icons/icon_spirit.png",
	Icon.MIND : "res://Autoloads/Icons/icon_mind.png",
	#Icon.ALL_TYPE : Will manually add all three icons later
	Icon.VOLLEY : "res://Autoloads/Icons/icon_volley.png",
	Icon.SUPPORT : "res://Autoloads/Icons/icon_support.png",
	Icon.DEFENSE : "res://Autoloads/Icons/icon_defense.png",
	Icon.UP_1 : "res://Autoloads/Icons/icon_up.png",
	Icon.UP_2 : "res://Autoloads/Icons/icon_up_2.png",
	Icon.UP_3 : "res://Autoloads/Icons/icon_up_3.png",
	Icon.DOWN_1 : "res://Autoloads/Icons/icon_down.png",
	Icon.DOWN_2 : "res://Autoloads/Icons/icon_down_2.png",
	Icon.DOWN_3 : "res://Autoloads/Icons/icon_down_3.png",
	Icon.WIPED : "res://Autoloads/Icons/icon_wiped.png",
	Icon.TRIED : "res://Autoloads/Icons/icon_tired.png",
	Icon.SHOOK : "res://Autoloads/Icons/icon_shook.png",
	Icon.JAZZED : "res://Autoloads/Icons/icon_jazzed.png",
	Icon.BLOCKED : "res://Autoloads/Icons/icon_blocked.png",
	Icon.WEEPY : "res://Autoloads/Icons/icon_weepy.png",
	Icon.TOUGH : "res://Autoloads/Icons/icon_tough.png",
	Icon.TENDER : "res://Autoloads/Icons/icon_tender.png",
	Icon.SWEATY : "res://Autoloads/Icons/icon_sweaty.png",
	Icon.NOISY : "res://Autoloads/Icons/icon_noisy.png",
	Icon.ANGRY : "res://Autoloads/Icons/icon_angry.png",
	Icon.NERVOUS : "res://Autoloads/Icons/icon_nervous.png",
	Icon.STRESSED : "res://Autoloads/Icons/icon_stressed.png"
}

const ICON_KEYWORDS : Dictionary[String, Icon] = {
	"BODY" : Icon.BODY,
	"SPIRIT" : Icon.SPIRIT,
	"MIND" : Icon.MIND,
	"ALL_TYPE" : Icon.ALL_TYPE,
	"VOLLEY" : Icon.VOLLEY,
	"SUPPORT" : Icon.SUPPORT,
	"DEFENSE" : Icon.DEFENSE,
	"UP1" : Icon.UP_1,
	"UP2" : Icon.UP_2,
	"UP3" : Icon.UP_3,
	"DOWN1" : Icon.DOWN_1,
	"DOWN2" : Icon.DOWN_2,
	"DOWN3" : Icon.DOWN_3,
	"WIPED" : Icon.WIPED,
	"TRIED" : Icon.TRIED,
	"SHOOK" : Icon.SHOOK,
	"JAZZED" : Icon.JAZZED,
	"BLOCKED" : Icon.BLOCKED,
	"WEEPY" : Icon.WEEPY,
	"TOUGH" : Icon.TOUGH,
	"TENDER" : Icon.TENDER,
	"SWEATY" : Icon.SWEATY,
	"NOISY" : Icon.NOISY,
	"ANGRY" : Icon.ANGRY,
	"NERVOUS" : Icon.NERVOUS,
	"STRESSED" : Icon.STRESSED
}


func get_iconified_text(text : String, have_full_stop : bool = true) -> String:
	var new_text : String = ""
	var words_array := text.split(" ")

	var count : int = 0
	for word : String in words_array:
		var full_stop : String = "." if have_full_stop else ""
		var ending : String = full_stop if count == words_array.size() - 1 else " "
		var icon : Icon = _convert_word_to_icon_enum(word)
		match icon:
			Icon.ERROR:
				new_text += word
			Icon.UP_1, Icon.UP_2, Icon.UP_3, Icon.DOWN_1, Icon.DOWN_2, Icon.DOWN_3, \
			Icon.BODY, Icon.SPIRIT, Icon.MIND:
				new_text += _add_img_bbcode(icon) # Replace keyword entirely
			Icon.ALL_TYPE:
				new_text += _add_img_bbcode(Icon.BODY) + _add_img_bbcode(Icon.SPIRIT) + _add_img_bbcode(Icon.MIND)
							# Replace keyword entirely but special
			_:
				new_text += _add_img_bbcode(icon) + word # Add icon before keyword
		new_text += ending
		count += 1

	return new_text


func _convert_word_to_icon_enum(word : String) -> Icon:
	word = word.to_upper()
	if word.ends_with(","):
		word = word.trim_suffix(",")
	if word.ends_with("."):
		word = word.trim_suffix(".")

	return ICON_KEYWORDS.get(word, Icon.ERROR)


func _get_icon_path(icon : Icon) -> String:
	assert(icon != Icon.ERROR, "Tried to get path of non-existing icon!")
	return ICON_PATHS.get(icon, )


func _add_img_bbcode(icon : Icon) -> String:
	return "[img]" + _get_icon_path(icon) + "[/img]"
#endregion
