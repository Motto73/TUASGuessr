extends Node2D

#root should always be the game node
@onready var game : Game = $".."

func _on_play_button_down():
	game.startGame()
