extends Control

@export var long_press_seconds := 0.35
@export var action_bar: NodePath

var _long_press_timers: Dictionary = {}
var _hovered: Dictionary = {}
var _desc_hovered: Dictionary = {}
var _action_bar_node: Node

func _ready() -> void:
	_action_bar_node = _resolve_node(action_bar)
	var back_button = get_node_or_null("BackButton")
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

	var panel = get_node_or_null("Ability Panel")
	if not panel:
		return
	for child in panel.get_children():
		if child is Button:
			_setup_ability_button(child)

func _resolve_node(path: NodePath) -> Node:
	if path.is_empty():
		return null
	return get_node(path)

func _setup_ability_button(button: Button) -> void:
	_set_desc_visible(button, false)
	_hovered[button] = false
	_desc_hovered[button] = false
	button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
	button.mouse_exited.connect(_on_button_mouse_exited.bind(button))
	button.button_down.connect(_on_button_down.bind(button))
	button.button_up.connect(_on_button_up.bind(button))

	var desc_panel = button.get_node_or_null("AbilityDescription")
	if desc_panel:
		desc_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		desc_panel.mouse_entered.connect(_on_desc_mouse_entered.bind(button))
		desc_panel.mouse_exited.connect(_on_desc_mouse_exited.bind(button))
		var desc_label = desc_panel.get_node_or_null("Desc")
		if desc_label is RichTextLabel:
			desc_label.scroll_active = true

	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = long_press_seconds
	timer.timeout.connect(_on_long_press_timeout.bind(button))
	add_child(timer)
	_long_press_timers[button] = timer

func _on_button_mouse_entered(button: Button) -> void:
	_hovered[button] = true
	_set_desc_visible(button, true)

func _on_button_mouse_exited(button: Button) -> void:
	_hovered[button] = false
	if not _desc_hovered.get(button, false):
		_set_desc_visible(button, false)

func _on_button_down(button: Button) -> void:
	var timer = _long_press_timers.get(button)
	if timer:
		timer.start()

func _on_button_up(button: Button) -> void:
	var timer = _long_press_timers.get(button)
	if timer:
		timer.stop()
	if not _hovered.get(button, false) and not _desc_hovered.get(button, false):
		_set_desc_visible(button, false)

func _on_long_press_timeout(button: Button) -> void:
	_set_desc_visible(button, true)

func _on_desc_mouse_entered(button: Button) -> void:
	_desc_hovered[button] = true
	_set_desc_visible(button, true)

func _on_desc_mouse_exited(button: Button) -> void:
	_desc_hovered[button] = false
	if not _hovered.get(button, false):
		_set_desc_visible(button, false)

func _set_desc_visible(button: Button, is_visible: bool) -> void:
	var desc = button.get_node_or_null("AbilityDescription")
	if desc:
		desc.visible = is_visible

func _on_back_pressed() -> void:
	visible = false
	if _action_bar_node:
		_action_bar_node.visible = true
