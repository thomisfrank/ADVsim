extends Control

@export var ability_catalog: AbilityCatalog = preload("res://scripts/data/AbilityCatalog.tres")
@export var owned_ability_ids: Array[String] = []
@export var max_equipped: int = 4
@export var action_bar_attack: NodePath

var _ability_buttons: Array[Button] = []
var _equipped_ids: Array[String] = []
var _action_bar_attack_node: Node
var _icon_cache: Dictionary = {}

func _ready() -> void:
	_action_bar_attack_node = _resolve_node(action_bar_attack)
	_collect_ability_buttons()
	_build_abilities()

func _resolve_node(path: NodePath) -> Node:
	if path.is_empty():
		return null
	return get_node(path)

func _collect_ability_buttons() -> void:
	_ability_buttons.clear()
	for i in range(1, 9):
		var node_name := "Ability" if i == 1 else "Ability%d" % i
		var button := get_node_or_null(node_name)
		if button is Button:
			_ability_buttons.append(button)

func _build_abilities() -> void:
	if not ability_catalog:
		return
	var abilities: Array[AbilityData] = ability_catalog.abilities.filter(func(ability: AbilityData) -> bool:
		return owned_ability_ids.has(ability.id)
	)
	for button in _ability_buttons:
		button.visible = false
	for i in range(min(abilities.size(), _ability_buttons.size())):
		var ability: AbilityData = abilities[i]
		var button := _ability_buttons[i]
		_apply_ability_to_button(button, ability)
		button.visible = true
	_sync_action_bar()

func _apply_ability_to_button(button: Button, ability: AbilityData) -> void:
	button.text = ability.name
	if ability.icon:
		button.icon = _get_visible_icon(ability.icon)
		button.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		button.expand_icon = false
		button.add_theme_constant_override("icon_max_width", 56)
	var power_label := button.get_node_or_null("PowerValue")
	if power_label is RichTextLabel:
		power_label.visible = true
		power_label.text = "%d P" % ability.power
	var desc_panel := button.get_node_or_null("AbilityDescription")
	if desc_panel:
		var desc_label := desc_panel.get_node_or_null("Desc")
		if desc_label is RichTextLabel:
			desc_label.text = ability.description
		var header := desc_panel.get_node_or_null("Header")
		if header is RichTextLabel:
			header.text = ability.name
	var equip_button := button.get_node_or_null("EquipAbility")
	if equip_button is Button:
		equip_button.toggle_mode = true
		equip_button.button_pressed = _equipped_ids.has(ability.id)
		equip_button.toggled.connect(_on_equip_toggled.bind(ability, equip_button))

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

func _on_equip_toggled(pressed: bool, ability: AbilityData, equip_button: Button) -> void:
	if pressed:
		if _equipped_ids.size() >= max_equipped and not _equipped_ids.has(ability.id):
			equip_button.button_pressed = false
			return
		if not _equipped_ids.has(ability.id):
			_equipped_ids.append(ability.id)
	else:
		_equipped_ids.erase(ability.id)
	_sync_action_bar()

func _sync_action_bar() -> void:
	if not _action_bar_attack_node or not _action_bar_attack_node.has_method("set_selected_abilities"):
		return
	var selected: Array[AbilityData] = []
	for ability in ability_catalog.abilities:
		if _equipped_ids.has(ability.id):
			selected.append(ability)
	_action_bar_attack_node.set_selected_abilities(selected)
