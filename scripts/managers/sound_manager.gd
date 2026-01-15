extends Node

@export var max_players: int = 6

var _players: Array[AudioStreamPlayer] = []
var _player_index := 0
var _rng := RandomNumberGenerator.new()

var _sfx := {
	"basic_attack": preload("res://assets/sounds/sfx/basicAttack.wav"),
	"click": preload("res://assets/sounds/sfx/click.wav"),
	"click2": preload("res://assets/sounds/sfx/click2.wav"),
	"error": preload("res://assets/sounds/sfx/error.wav"),
	"jewelry": preload("res://assets/sounds/sfx/jewelry.wav"),
	"light": preload("res://assets/sounds/sfx/light.wav"),
	"potion": preload("res://assets/sounds/sfx/potion.wav"),
	"shieldM": preload("res://assets/sounds/sfx/shieldM.wav"),
	"silver_tongue": preload("res://assets/sounds/sfx/silver_tongue.wav"),
	"sturdyshield": preload("res://assets/sounds/sfx/sturdyShield.wav"),
	"sword": preload("res://assets/sounds/sfx/sword.wav"),
	"wind_bullet": preload("res://assets/sounds/sfx/wind_bullet.wav")
}

func _ready() -> void:
	_rng.randomize()
	for i in range(max_players):
		var player := AudioStreamPlayer.new()
		add_child(player)
		_players.append(player)

func play_sfx(sound_id: String) -> void:
	var stream: AudioStream = _sfx.get(sound_id, null)
	if not stream:
		return
	var player := _players[_player_index]
	_player_index = (_player_index + 1) % _players.size()
	player.stream = stream
	player.play()

func play_random_click() -> void:
	var pick := "click" if _rng.randi_range(0, 1) == 0 else "click2"
	play_sfx(pick)
