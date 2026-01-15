extends Control

@export var base_attack: int = 0
@export var base_defense: int = 0
@export var base_magic_defense: int = 0
@export var base_charisma: int = 0

@onready var _health_bar: ProgressBar = $Stats/HealthStat/HealthBar
@onready var _health_remaining: RichTextLabel = $Stats/HealthStat/HealthBar/RemainingValue
@onready var _health_max: RichTextLabel = $Stats/HealthStat/HealthBar/MaxValue
@onready var _magic_bar: ProgressBar = $Stats/MagicStat/MagicBar
@onready var _magic_remaining: RichTextLabel = $Stats/MagicStat/MagicBar/RemainingValue
@onready var _magic_max: RichTextLabel = $Stats/MagicStat/MagicBar/MaxValue
@onready var _attack_value: RichTextLabel = $Stats/AttackStat/Value
@onready var _defense_value: RichTextLabel = $Stats/DefenseStat/Value
@onready var _magic_defense_value: RichTextLabel = $Stats/MagicDefenseStat/Value
@onready var _charisma_value: RichTextLabel = $Stats/CharismaStat/Value

var _equipment_stats := {
	"attack": 0,
	"defense": 0,
	"magic_defense": 0,
	"charisma": 0
}

func _ready() -> void:
	_update_stat_labels()
	_update_health_magic_labels()

func set_equipment_stats(stats: Dictionary) -> void:
	_equipment_stats = stats
	_update_stat_labels()

func apply_consumable_stats(stats: Dictionary) -> void:
	var health_restore := int(stats.get("health_restore", 0))
	var magic_restore := int(stats.get("magic_restore", 0))
	if health_restore != 0:
		_health_bar.value = clamp(_health_bar.value + health_restore, 0, _health_bar.max_value)
	if magic_restore != 0:
		_magic_bar.value = clamp(_magic_bar.value + magic_restore, 0, _magic_bar.max_value)
	_update_health_magic_labels()

func _update_stat_labels() -> void:
	_attack_value.text = str(base_attack + int(_equipment_stats.get("attack", 0)))
	_defense_value.text = str(base_defense + int(_equipment_stats.get("defense", 0)))
	_magic_defense_value.text = str(base_magic_defense + int(_equipment_stats.get("magic_defense", 0)))
	_charisma_value.text = str(base_charisma + int(_equipment_stats.get("charisma", 0)))

func _update_health_magic_labels() -> void:
	_health_remaining.text = "%d/" % int(_health_bar.value)
	_health_max.text = str(int(_health_bar.max_value))
	_magic_remaining.text = "%d/" % int(_magic_bar.value)
	_magic_max.text = str(int(_magic_bar.max_value))
