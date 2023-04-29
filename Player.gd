extends Node2D

@onready var river:Node = $"../River"
@onready var move_unit_size:int = $"../River".move_unit_size

var hasEmbarked:bool = false

func _ready():
	position = Vector2i(-move_unit_size, 0)

func _process(delta):
	river.player_position = position
	pass
	
func _input(event):
	if event.is_action_pressed("MoveRight") and position.x < (river.map_size.x - 1) * move_unit_size:
		position.x += move_unit_size
	elif event.is_action_pressed("MoveLeft") and not hasEmbarked and position.x > 0:
		position.x -= move_unit_size
	elif event.is_action_pressed("MoveUp") and position.y > 0:
		position.y -= move_unit_size
	elif event.is_action_pressed("MoveDown") and position.y < (river.map_size.y - 1) * move_unit_size:
		position.y += move_unit_size
	pass
