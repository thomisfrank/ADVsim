extends Control

@export var action_bar: NodePath

var _action_bar_node: Node

func _ready() -> void:
	_action_bar_node = _resolve_node(action_bar)
	var back_button = get_node_or_null("BackButton")
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

func _resolve_node(path: NodePath) -> Node:
	if path.is_empty():
		return null
	return get_node(path)

func _on_back_pressed() -> void:
	visible = false
	if _action_bar_node:
		_action_bar_node.visible = true
