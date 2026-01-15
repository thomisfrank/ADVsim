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
@export var selected_actions := false
@export var you_bar: NodePath
@export var inventory_bar: NodePath
@export var ability_bar: NodePath
@export var activities_bar: NodePath
@export var action_bar: NodePath
@export var action_bar_attack: NodePath
@export var action_bar_speak: NodePath

var you_cell: Node
var inventory_cell: Node
var abilities_cell: Node
var activities_cell: Node
var actions_cell: Node
var actions_fill: Node
var you_bar_node: Node
var inventory_bar_node: Node
var ability_bar_node: Node
var activities_bar_node: Node
var action_bar_node: Node
var action_bar_attack_node: Node
var action_bar_speak_node: Node

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
	actions_cell = _resolve_node(actions)
	if actions_cell:
		var label = actions_cell.get_node("Label")
		if label:
			label.text = "ACTIONS"
		actions_fill = actions_cell.get_node_or_null("ActionframeFill")
		var button = actions_cell.get_node_or_null("Button")
		if button:
			button.pressed.connect(_on_actions_pressed)
	you_bar_node = _resolve_node(you_bar)
	inventory_bar_node = _resolve_node(inventory_bar)
	ability_bar_node = _resolve_node(ability_bar)
	activities_bar_node = _resolve_node(activities_bar)
	action_bar_node = _resolve_node(action_bar)
	action_bar_attack_node = _resolve_node(action_bar_attack)
	action_bar_speak_node = _resolve_node(action_bar_speak)

	if you_cell and you_cell.has_signal("cell_pressed"):
		you_cell.cell_pressed.connect(_on_you_pressed)
	if inventory_cell and inventory_cell.has_signal("cell_pressed"):
		inventory_cell.cell_pressed.connect(_on_inventory_pressed)
	if abilities_cell and abilities_cell.has_signal("cell_pressed"):
		abilities_cell.cell_pressed.connect(_on_abilities_pressed)
	if activities_cell and activities_cell.has_signal("cell_pressed"):
		activities_cell.cell_pressed.connect(_on_activities_pressed)

	_apply_selection()

func _on_you_pressed():
	_select("you")

func _on_inventory_pressed():
	_select("inventory")

func _on_abilities_pressed():
	_select("abilities")

func _on_activities_pressed():
	_select("activities")

func _on_actions_pressed():
	_select("actions")

func _select(which: String):
	selected_you = which == "you"
	selected_inventory = which == "inventory"
	selected_abilities = which == "abilities"
	selected_activities = which == "activities"
	selected_actions = which == "actions"
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
	if actions_fill:
		actions_fill.visible = selected_actions
	if you_bar_node:
		you_bar_node.visible = selected_you
	if inventory_bar_node:
		inventory_bar_node.visible = selected_inventory
	if ability_bar_node:
		ability_bar_node.visible = selected_abilities
	if activities_bar_node:
		activities_bar_node.visible = selected_activities
	if action_bar_node:
		action_bar_node.visible = selected_actions
	if action_bar_attack_node and not selected_actions:
		action_bar_attack_node.visible = false
	if action_bar_speak_node and not selected_actions:
		action_bar_speak_node.visible = false
