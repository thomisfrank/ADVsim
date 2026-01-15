extends Control

@export var action_bar_attack: NodePath
@export var action_bar_speak: NodePath

var _action_bar_attack_node: Node
var _action_bar_speak_node: Node

func _ready() -> void:
	_action_bar_attack_node = _resolve_node(action_bar_attack)
	_action_bar_speak_node = _resolve_node(action_bar_speak)
	var attack_button = get_node_or_null("AttackAction")
	if attack_button:
		attack_button.pressed.connect(_on_attack_pressed)
	var speak_button = get_node_or_null("SpeakAction")
	if speak_button:
		speak_button.pressed.connect(_on_speak_pressed)

func _resolve_node(path: NodePath) -> Node:
	if path.is_empty():
		return null
	return get_node(path)

func _on_attack_pressed() -> void:
	visible = false
	if _action_bar_attack_node:
		_action_bar_attack_node.visible = true

func _on_speak_pressed() -> void:
	visible = false
	if _action_bar_speak_node:
		_action_bar_speak_node.visible = true
