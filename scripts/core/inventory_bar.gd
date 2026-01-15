extends Control

@export var item_catalog: ItemCatalog = preload("res://scripts/data/ItemCatalog.tres")
@export var item_scene: PackedScene = preload("res://scene/core/item.tscn")
@export var owned_item_ids: Array[String] = []
@export var you_bar: NodePath

@onready var _inventory_list: VBoxContainer = $InventoryScroll/InventoryList

var _equipped_items: Dictionary = {}
var _you_bar_node: Node

func _ready() -> void:
	_you_bar_node = _resolve_node(you_bar)
	_build_inventory()

func _resolve_node(path: NodePath) -> Node:
	if path.is_empty():
		return null
	return get_node(path)

func _build_inventory() -> void:
	_clear_inventory()
	if not item_catalog or not item_scene:
		return
	var items := item_catalog.items.filter(func(item: ItemData) -> bool:
		return owned_item_ids.has(item.id)
	)
	for item in items:
		_add_item_entry(item)
	_update_player_stats()

func _clear_inventory() -> void:
	for child in _inventory_list.get_children():
		child.queue_free()
	_equipped_items.clear()

func _add_item_entry(item: ItemData) -> void:
	var entry := item_scene.instantiate()
	_inventory_list.add_child(entry)
	if entry.has_method("set_item_data"):
		entry.set_item_data(item)
	if entry.has_signal("equip_changed"):
		entry.equip_changed.connect(_on_item_equip_changed)
	if entry.has_signal("consume_requested"):
		entry.consume_requested.connect(_on_item_consumed)

func _on_item_equip_changed(item: ItemData, equipped: bool) -> void:
	if equipped:
		_equipped_items[item.id] = item
	else:
		_equipped_items.erase(item.id)
	_update_player_stats()

func _on_item_consumed(item: ItemData) -> void:
	if _you_bar_node and _you_bar_node.has_method("apply_consumable_stats"):
		_you_bar_node.apply_consumable_stats(item.stats)

func _update_player_stats() -> void:
	var totals := {
		"attack": 0,
		"defense": 0,
		"magic_defense": 0,
		"charisma": 0
	}
	for item in _equipped_items.values():
		var stats: Dictionary = {}
		if item and item.stats:
			stats = item.stats
		totals["attack"] += int(stats.get("attack", 0))
		totals["defense"] += int(stats.get("defense", 0))
		totals["magic_defense"] += int(stats.get("magic_defense", 0))
		totals["charisma"] += int(stats.get("charisma", 0))
	if _you_bar_node and _you_bar_node.has_method("set_equipment_stats"):
		_you_bar_node.set_equipment_stats(totals)
