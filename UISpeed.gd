extends Label

@onready var player = $"../../Player"
	
func _process(delta):
	text = "Moves Remaining: " + str(player.current_moves_remaining)
