extends Resource
class_name ItemData

@export var id: String
@export var name: String
@export var type: String
@export var equippable: bool = true
@export var consumable: bool = false
@export var rarity: String
@export var price: int = 0
@export var icon: Texture2D
@export var description: String
@export var stats := {
	"attack": 0,
	"defense": 0,
	"magic_defense": 0,
	"charisma": 0,
	"health_restore": 0,
	"magic_restore": 0
}
