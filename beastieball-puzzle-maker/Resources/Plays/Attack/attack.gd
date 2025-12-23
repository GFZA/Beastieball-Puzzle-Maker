@tool
class_name Attack
extends Plays


@export var name : String = "Free Ball"
@export_range(0, 150) var base_pow : int = 1
@export_multiline var descrition : String = "Can hit without volleying. Pass to an opponent and skip your turn. Can always be used."


func _init() -> void:
	self.type = Type.ATTACK_BODY
