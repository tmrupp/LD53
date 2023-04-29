extends Label

@onready var river_bank = $"../../River/Riverbanks"
	
func _process(delta):
	text = "Right Bank: " + str(river_bank.right_bank_souls) + " Souls"
