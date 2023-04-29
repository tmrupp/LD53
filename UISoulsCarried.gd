extends Label

@onready var player = $"../../Player"
	
func _process(delta):
	text = "Carrying " + str(player.current_soul_count) + " souls"
