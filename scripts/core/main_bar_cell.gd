extends Panel

signal cell_pressed

@export var selected := false

@onready var sprite = $OuterShell/InnerShell/You
@onready var label = $Label
@onready var button = get_node_or_null("Button")
@onready var selected_fill = get_node_or_null("Selected_fill")

func _ready():
	_apply_selected()
	if button:
		button.pressed.connect(_on_button_pressed)

func set_selected(value: bool):
	selected = value
	_apply_selected()

func _apply_selected():
	if selected_fill:
		selected_fill.visible = selected

func _on_button_pressed():
	cell_pressed.emit()

func set_cell_data(image_path: String, text: String):
	var texture = load(image_path)
	if texture:
		sprite.texture = texture
	label.text = text
