extends Sprite2D

@export_enum("Red", "Blue", "Yellow", "Green", "Purple", "Orange") var color
@export var ID : String

var _pressed : bool
var _overlapping_players : Array[CharacterBody2D]

signal button_on
signal button_off

func _ready() -> void:
	_init_button()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("ActivePlayers"):
		_overlapping_players.append(body)
	if _overlapping_players.size() > 0:
		_pressed = true
		frame = frame + 1
		emit_signal("button_on")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if !body.is_in_group("ActivePlayers"):
		return
	var where = _overlapping_players.find(body)
	if where != -1:
		_overlapping_players.remove_at(where)
	if _overlapping_players.size() <= 0:
		_pressed = false
		frame = frame - 1
		emit_signal("button_off")

func _init_button(btn_color = "Red", btn_id = 0) -> void:
	color = btn_color
	ID = btn_id
	_pressed = false
	match color:
		"Red":
			frame = 0
		"Blue":
			frame = 2
		"Yellow":
			frame = 4
		"Green":
			frame = 6
		"Purple":
			frame = 8
		"Orange":
			frame = 10

func is_pressed() -> bool:
	return _pressed



