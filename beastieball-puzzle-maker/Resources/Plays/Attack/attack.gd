@tool
class_name Attack
extends Plays

enum Target {STRAIGHT, SIDEWAYS, FRONT_ONLY, BACK_ONLY}
enum UseCondition {NORMAL, FRONT_ONLY, BACK_ONLY}

@export var name : String = "Free Ball"
@export var target : Target = Target.STRAIGHT
@export var use_condition : UseCondition = UseCondition.NORMAL
@export_range(0, 300) var base_pow : int = 1
@export var show_in_indicator : bool = true
@export_multiline var descrition : String = "Can hit without volleying. Pass to an opponent and skip your turn. Can always be used."
@export var manual_condition_name : String = ""

var manually_activated : bool = false


func _init() -> void:
	self.type = Type.ATTACK_BODY


func get_attack_pow(_attacker : Beastie, _defender : Beastie) -> int: # Overwrite this
	return base_pow
