extends Button

@onready var river = $"../../../River"

func _pressed():
	river.full_restart()
