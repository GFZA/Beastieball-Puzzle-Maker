class_name Trait
extends Resource

@export var name : String = "Primitive"
@export_multiline var description : String = "This Beastie is traitless"

@export_group("Damage multipliers")
@export_range(0.75, 2.0, 0.05) var damage_dealt_mult : float = 1.0
@export_range(1.0, 1.5, 0.1) var damage_taken_mult : float = 1.0
