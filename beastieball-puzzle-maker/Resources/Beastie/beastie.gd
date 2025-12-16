class_name Beastie
extends Resource

enum Sprite {IDLE, READY, SPIKE, GOOD, BAD}

@export_group("Internal Infos")
@export var name : String = "Sprecko"
@export_range(1, 150) var body_base_pow : int = 45
@export_range(1, 150) var spirit_base_pow : int = 43
@export_range(1, 150) var mind_base_pow : int = 42
@export_range(1, 150) var body_base_def : int = 50
@export_range(1, 150) var spirit_base_def : int = 67
@export_range(1, 150) var mind_base_def : int = 55
@export var possible_plays : Array[Plays] = []
@export var possible_traits : Array[Trait] = []
@export var sprites : Dictionary[Sprite, Texture2D] = {}

@export_group("My infos")
@export_range(0, 30) var body_invest_pow : int = 0
@export_range(0, 30) var spirit_invest_pow : int = 0
@export_range(0, 30) var mind_invest_pow : int = 0
@export_range(0, 30) var body_invest_def : int = 0
@export_range(0, 30) var spirit_invest_def : int = 0
@export_range(0, 30) var mind_invest_def : int = 0
@export var my_plays : Array[Plays] = []
@export var my_trait : Trait = possible_traits.front()
