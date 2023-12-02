extends Control

signal quit_pressed
signal resume_pressed

func _ready() -> void:
	pass

func _on_button_resume_pressed() -> void:
	emit_signal("resume_pressed")

func _on_button_quit_pressed() -> void:
	emit_signal("quit_pressed")
