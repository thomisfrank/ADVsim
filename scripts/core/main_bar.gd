extends Control

@export var you: NodePath
@export var inventory: NodePath
@export var abilities: NodePath
@export var activities: NodePath
@export var actions: NodePath
@export var selected_you := false
@export var selected_inventory := false
@export var selected_abilities := false
@export var selected_activities := false
@export var you_bar: NodePath
@export var inventory_bar: NodePath

var you_cell: Node
var inventory_cell: Node
var abilities_cell: Node
var activities_cell: Node
var you_bar_node: Node
var inventory_bar_node: Node

func _resolve_node(path: NodePath) -> Node:
	if path.is_empty():
		return null
	return get_node(path)

func _ready():
	you_cell = _resolve_node(you)
	if you_cell:
		you_cell.set_cell_data("res://assets/icons/you.png", "YOU")
	inventory_cell = _resolve_node(inventory)
	if inventory_cell:
		inventory_cell.set_cell_data("res://assets/icons/inventory.png", "INVENTORY")
	abilities_cell = _resolve_node(abilities)
	if abilities_cell:
		abilities_cell.set_cell_data("res://assets/icons/abilities.png", "ABILITIES")
	activities_cell = _resolve_node(activities)
	if activities_cell:
		activities_cell.set_cell_data("res://assets/icons/activities.png", "ACTIVITIES")
	var actions_node = _resolve_node(actions)
	if actions_node:
		var label = actions_node.get_node("Label")
		if label:
			label.text = "ACTIONS"
	you_bar_node = _resolve_node(you_bar)
	inventory_bar_node = _resolve_node(inventory_bar)

	if you_cell and you_cell.has_signal("cell_pressed"):
		you_cell.cell_pressed.connect(_on_you_pressed)
	if inventory_cell and inventory_cell.has_signal("cell_pressed"):
		inventory_cell.cell_pressed.connect(_on_inventory_pressed)

	_apply_selection()

func _on_you_pressed():
	_select("you")

func _on_inventory_pressed():
	_select("inventory")

func _select(which: String):
	selected_you = which == "you"
	selected_inventory = which == "inventory"
	selected_abilities = false
	selected_activities = false
	_apply_selection()

func _apply_selection():
	if you_cell:
		you_cell.set_selected(selected_you)
	if inventory_cell:
		inventory_cell.set_selected(selected_inventory)
	if abilities_cell:
		abilities_cell.set_selected(selected_abilities)
	if activities_cell:
		activities_cell.set_selected(selected_activities)
	if you_bar_node:
		you_bar_node.visible = selected_you
	if inventory_bar_node:
		inventory_bar_node.visible = selected_inventory
