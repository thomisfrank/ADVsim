extends Control

@export var long_press_seconds := 0.35
@export var action_bar: NodePath

var _long_press_timers: Dictionary = {}
var _hovered: Dictionary = {}
var _desc_hovered: Dictionary = {}
var _action_bar_node: Node
var _icon_cache: Dictionary = {}

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

func set_selected_abilities(abilities: Array[AbilityData]) -> void:
	var panel = get_node_or_null("Ability Panel")
	if not panel:
		return
	var buttons: Array = []
	for child in panel.get_children():
		if child is Button:
			buttons.append(child)
	for i in range(buttons.size()):
		var button := buttons[i] as Button
		if i < abilities.size():
			var ability: AbilityData = abilities[i]
			button.visible = true
			button.text = ability.name
			if ability.icon:
				button.icon = _get_visible_icon(ability.icon)
				button.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
				button.expand_icon = false
				button.add_theme_constant_override("icon_max_width", 56)
			var power_label := button.get_node_or_null("PowerValue")
			if power_label is RichTextLabel:
				power_label.visible = true
				power_label.text = "%d P" % int(ability.power)
			var desc_panel := button.get_node_or_null("AbilityDescription")
			if desc_panel:
				var desc_label := desc_panel.get_node_or_null("Desc")
				if desc_label is RichTextLabel:
					desc_label.text = ability.description
				var header := desc_panel.get_node_or_null("Header")
				if header is RichTextLabel:
					header.text = ability.name
			_set_desc_visible(button, false)
		else:
			button.visible = false

func _get_visible_icon(texture: Texture2D) -> Texture2D:
	if not texture:
		return null
	if _icon_cache.has(texture):
		return _icon_cache[texture]
	var image := texture.get_image()
	if not image:
		return texture
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var c := image.get_pixel(x, y)
			if c.a > 0.0:
				image.set_pixel(x, y, Color(1, 1, 1, c.a))
	var tex := ImageTexture.create_from_image(image)
	_icon_cache[texture] = tex
	return tex

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
	var sound = get_node_or_null("/root/SoundManager")
	if sound:
		sound.play_random_click()
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

func _set_desc_visible(button: Button, show_desc: bool) -> void:
	var desc = button.get_node_or_null("AbilityDescription")
	if desc:
		desc.visible = show_desc

func _on_back_pressed() -> void:
	var sound = get_node_or_null("/root/SoundManager")
	if sound:
		sound.play_random_click()
	visible = false
	if _action_bar_node:
		_action_bar_node.visible = true
