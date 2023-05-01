extends Label

@onready var player = $"../../Player"
	
func _process(delta):
	text = "Moves Remaining: " + str(player.speed.current) + " (boat state: " + str(player.state) + ")"
