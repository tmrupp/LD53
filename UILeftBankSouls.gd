extends Label

@onready var river_bank = $"../../River/Riverbanks"
	
func _process(delta):
	text = "Left Bank: " + str(river_bank.left_bank_souls) + " Souls"
