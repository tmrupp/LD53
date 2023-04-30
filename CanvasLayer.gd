extends CanvasLayer

var game
func set_game(_game):
	game = _game

func _input(event):
	if event.is_action_pressed("Menu"):
		$"..".visible = !$"..".visible
		game.visible = !$"..".visible
