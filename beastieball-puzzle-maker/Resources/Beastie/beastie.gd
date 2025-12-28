@tool
class_name Beastie
extends Resource

enum Sprite {IDLE, READY, SPIKE, VOLLEY, GOOD, BAD}
enum Feelings {NERVOUS, ANGRY, SHOOK, NOISY, TOUGH, WIPED, SWEATY, JAZZED, BLOCKED, TIRED, TENDER, STRESSED, WEEPY}
enum Stats {B_POW, S_POW, M_POW, B_DEF, S_DEF, M_DEF}

const MAX_NAME_LENGTH : int = 12
const MAX_NUNBER_LENGTH : int = 3
#const INVEST_MAX : int = 60

signal my_name_updated(my_name : String)
signal sport_number_updated(sport_number : int)
signal stats_updated(stats : Dictionary[String, Array])
signal my_plays_updated(updated_plays : Array[Plays])
signal my_trait_updated(updated_trait : Trait)

#var invest_point_left : int = INVEST_MAX
@export var is_at_net : bool = false # TEMPORARY EXPORTED
@export var is_stacked : bool = false # TEMPORARY EXPORTED

@export var my_name : String = "" :
	set(value):
		value = value.substr(0, MAX_NAME_LENGTH)
		my_name = value
		my_name_updated.emit(my_name)

@export_range(0, 999) var sport_number : int = 1:
	set(value):
		clamp(value, 0, 999)
		sport_number = value
		sport_number_updated.emit(sport_number)

@export var my_plays : Array[Plays] = get_empty_slot_plays_array() :
	set(value):
		if value.size() != 3:
			value.resize(3) # Just to be safe
		value.sort_custom(
			func(a : Plays, b : Plays):
				var a_value : int = int(a.type) if not a == null else 9999
				var b_value : int = int(b.type) if not b == null else 9999
				return a_value < b_value
		)
		my_plays = value
		my_plays_updated.emit(my_plays)

@export var my_trait : Trait = null :
	set(value):
		my_trait = value
		my_trait_updated.emit(my_trait)

@export var current_boosts : Dictionary[Stats, int] = {
	Stats.B_POW : 0,
	Stats.S_POW : 0,
	Stats.M_POW : 0,
	Stats.B_DEF : 0,
	Stats.S_DEF : 0,
	Stats.M_DEF : 0,
}

@export var current_feelings : Dictionary[Feelings, int] = {
		Feelings.WIPED : 0,
		Feelings.TIRED : 0,
		Feelings.SHOOK : 0,
		Feelings.JAZZED : 0,
		Feelings.BLOCKED : 0,
		Feelings.WEEPY : 0,
		Feelings.TOUGH : 0,
		Feelings.TENDER : 0,
		Feelings.SWEATY : 0,
		Feelings.NOISY : 0,
		Feelings.ANGRY : 0,
		Feelings.NERVOUS : 0,
		Feelings.STRESSED : 0,
	}

@export_group("Invests")
@export_range(0, 30) var body_invest_pow : int = 0 :
	set(value):
		body_invest_pow = value
		stats_updated.emit(get_stats_dict())
@export_range(0, 30) var spirit_invest_pow : int = 0 :
	set(value):
		spirit_invest_pow = value
		stats_updated.emit(get_stats_dict())
@export_range(0, 30) var mind_invest_pow : int = 0 :
	set(value):
		mind_invest_pow = value
		stats_updated.emit(get_stats_dict())
@export_range(0, 30) var body_invest_def : int = 0 :
	set(value):
		body_invest_def = value
		stats_updated.emit(get_stats_dict())
@export_range(0, 30) var spirit_invest_def : int = 0 :
	set(value):
		spirit_invest_def = value
		stats_updated.emit(get_stats_dict())
@export_range(0, 30) var mind_invest_def : int = 0 :
	set(value):
		mind_invest_def = value
		stats_updated.emit(get_stats_dict())

@export_group("Internal Infos")
@export var specie_name : String = "Sprecko"
@export_color_no_alpha var bar_color : Color = Color.GREEN
@export_range(1, 150) var body_base_pow : int = 45 :
	set(value):
		body_base_pow = value
		stats_updated.emit(get_stats_dict())
@export_range(1, 150) var spirit_base_pow : int = 43 :
	set(value):
		spirit_base_pow = value
		stats_updated.emit(get_stats_dict())
@export_range(1, 150) var mind_base_pow : int = 42 :
	set(value):
		mind_base_pow = value
		stats_updated.emit(get_stats_dict())
@export_range(1, 150) var body_base_def : int = 50 :
	set(value):
		body_base_def = value
		stats_updated.emit(get_stats_dict())
@export_range(1, 150) var spirit_base_def : int = 67 :
	set(value):
		spirit_base_def = value
		stats_updated.emit(get_stats_dict())
@export_range(1, 150) var mind_base_def : int = 55 :
	set(value):
		mind_base_def = value
		stats_updated.emit(get_stats_dict())
@export var possible_plays : Array[Plays] = []
@export var possible_traits : Array[Trait] = []
@export var sprites : Dictionary[Sprite, Texture2D] = {
	Sprite.IDLE : null,
	Sprite.READY : null,
	Sprite.SPIKE : null,
	Sprite.VOLLEY : null,
	Sprite.GOOD : null,
	Sprite.BAD : null,
}
@export var y_offset : int = 0


func get_stats_dict() -> Dictionary[Stats, Array]:
	var stats : Dictionary[Stats, Array] = {}
	stats.get_or_add(Stats.B_POW, [body_base_pow, body_invest_pow])
	stats.get_or_add(Stats.S_POW, [spirit_base_pow, spirit_invest_pow])
	stats.get_or_add(Stats.M_POW, [mind_base_pow, mind_invest_pow])
	stats.get_or_add(Stats.B_DEF, [body_base_def, body_invest_def])
	stats.get_or_add(Stats.S_DEF, [spirit_base_def, spirit_invest_def])
	stats.get_or_add(Stats.M_DEF, [mind_base_def, mind_invest_def])
	return stats


func get_total_stats_value(stats_type : Stats) -> int:
	var stats : Dictionary[Stats, Array] = get_stats_dict()
	return stats.get(stats_type)[0] + stats.get(stats_type)[1]


func get_sprite(sprite_type : Sprite) -> Texture2D:
	return sprites.get(sprite_type)


static func get_empty_stats_dict() -> Dictionary[String, Array]:
	# Due to typing, we need this convoluted function, bruh
	return {}


static func get_empty_plays_array() -> Array[Plays]:
	# Due to typing, we need this convoluted function, bruh
	return []


static func get_empty_slot_plays_array() -> Array[Plays]:
	var array : Array[Plays] = []
	array.resize(3)
	return array


static func get_empty_trait_array() -> Array[Trait]:
	# Due to typing, we need this convoluted function, bruh
	return []
