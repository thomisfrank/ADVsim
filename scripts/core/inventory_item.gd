extends Control
class_name InventoryItem

signal equip_changed(item: ItemData, equipped: bool)
signal consume_requested(item: ItemData)

@export var image_panel_scene: PackedScene = preload("res://scene/core/image_panel.tscn")

@onready var _name_label: RichTextLabel = $Name/ItemName
@onready var _type_label: RichTextLabel = $Type/ItemType
@onready var _desc_label: RichTextLabel = $Desc/ItemDesc
@onready var _rarity_panel: Panel = $Rarity
@onready var _stars := [
	$Rarity/Star,
	$Rarity/Star2,
	$Rarity/Star3,
	$Rarity/Star4
]
@onready var _consume_button: Button = $Consume
@onready var _equip_button: Button = $Equip

var item_data: ItemData
var _preview_panel: Control
var _long_press_timer: Timer
var _long_press_position: Vector2

var _equip_sfx_by_id := {
	"W_1": "sword",
	"A_1": "sturdyshield",
	"A_2": "jewelry",
	"A_3": "jewelry"
}

func _ready() -> void:
	_consume_button.pressed.connect(_on_consume_pressed)
	_equip_button.toggle_mode = true
	_equip_button.toggled.connect(_on_equip_toggled)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_long_press_timer = Timer.new()
	_long_press_timer.one_shot = true
	_long_press_timer.wait_time = 0.4
	add_child(_long_press_timer)
	_long_press_timer.timeout.connect(_on_long_press_timeout)

func set_item_data(item: ItemData) -> void:
	item_data = item
	_name_label.text = item.name
	_type_label.text = item.type
	_desc_label.text = item.description
	_apply_rarity(item.rarity)
	_consume_button.visible = item.consumable
	_equip_button.visible = item.equippable and not item.consumable
	_equip_button.disabled = not item.equippable
	_equip_button.button_pressed = false

func _on_equip_toggled(pressed: bool) -> void:
	if not item_data or not item_data.equippable:
		_play_error()
		return
	if pressed:
		_play_equip_sound(item_data.id)
	equip_changed.emit(item_data, pressed)

func _on_consume_pressed() -> void:
	if not item_data or not item_data.consumable:
		_play_error()
		return
	_play_potion()
	consume_requested.emit(item_data)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_long_press_position = touch.position
			_long_press_timer.start()
		else:
			_long_press_timer.stop()
			_hide_preview()

func _on_long_press_timeout() -> void:
	_show_preview_at(_long_press_position)

func _on_mouse_entered() -> void:
	_show_preview_at(get_viewport().get_mouse_position())

func _on_mouse_exited() -> void:
	_hide_preview()

func _show_preview_at(global_pos: Vector2) -> void:
	if not item_data or not item_data.icon or not image_panel_scene:
		return
	if not _preview_panel:
		_preview_panel = image_panel_scene.instantiate()
		_preview_panel.top_level = true
		_preview_panel.z_as_relative = false
		_preview_panel.z_index = 100
		var root := get_tree().current_scene
		if root:
			root.add_child(_preview_panel)
	var image := _preview_panel.get_node_or_null("IMAGE")
	if image and image is Sprite2D:
		image.texture = item_data.icon
	var pos := global_pos
	var viewport_rect := get_viewport().get_visible_rect()
	if _preview_panel is Control:
		var panel := _preview_panel as Control
		var panel_size := panel.size
		if panel_size == Vector2.ZERO:
			panel_size = panel.get_combined_minimum_size()
		var max_x := viewport_rect.position.x + viewport_rect.size.x - panel_size.x
		var max_y := viewport_rect.position.y + viewport_rect.size.y - panel_size.y
		if pos.x > max_x:
			pos.x = max_x
		if pos.y > max_y:
			pos.y = max_y
		if pos.x < viewport_rect.position.x:
			pos.x = viewport_rect.position.x
		if pos.y < viewport_rect.position.y:
			pos.y = viewport_rect.position.y
	_preview_panel.global_position = pos
	_preview_panel.visible = true

func _hide_preview() -> void:
	if _preview_panel:
		_preview_panel.visible = false

func _play_equip_sound(item_id: String) -> void:
	var sound = get_node_or_null("/root/SoundManager")
	if not sound:
		return
	var sfx: String = _equip_sfx_by_id.get(item_id, "")
	if sfx != "":
		sound.play_sfx(sfx)

func _play_potion() -> void:
	var sound = get_node_or_null("/root/SoundManager")
	if sound:
		sound.play_sfx("potion")

func _play_error() -> void:
	var sound = get_node_or_null("/root/SoundManager")
	if sound:
		sound.play_sfx("error")

func _apply_rarity(rarity_text: String) -> void:
	var stars := _rarity_to_star_count(rarity_text)
	for i in range(_stars.size()):
		_stars[i].visible = i < stars
	if stars == 2:
		_set_rarity_color(Color8(0x08, 0x1F, 0x0C))
	elif stars == 3:
		_set_rarity_color(Color8(0x24, 0x15, 0x33))
	elif stars == 4:
		_set_rarity_color(Color8(0x33, 0x25, 0x0A))

func _set_rarity_color(color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(1, 1, 1, 1)
	_rarity_panel.add_theme_stylebox_override("panel", style)

func _rarity_to_star_count(text: String) -> int:
	var lower := text.strip_edges().to_lower()
	if "4" in lower or "four" in lower:
		return 4
	if "3" in lower or "three" in lower:
		return 3
	if "2" in lower or "two" in lower:
		return 2
	return 1
