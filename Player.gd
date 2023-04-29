extends Node2D

@onready var river:Node = $"../River"
@onready var ui_speed:Node = $"../UI/Speed"
@onready var ui_souls_carried:Node = $"../UI/SoulsCarried"
@onready var move_unit_size:int = $"../River".move_unit_size

var hasEmbarked:bool = false
var max_speed:int = 3 # the value we reset 'speedcurrent_moves_remaining' to after the river flows
var current_moves_remaining:int = max_speed

var soul_capacity:int = 4 # max number of souls you can carry at once
var current_soul_count:int = 0 # number of souls currently being carried

func _ready():
	position = Vector2i(-move_unit_size, 0)

func _process(delta):
	river.player_position = position
	
func _input(event):
	# movement
	if event.is_action_pressed("MoveRight") and position.x < (river.map_size.x - 1) * move_unit_size and current_moves_remaining > 0:
		position.x += move_unit_size
		on_move()
		if not hasEmbarked:
			hasEmbarked = true
	elif event.is_action_pressed("MoveLeft") and position.x > 0 and current_moves_remaining > 0:
		position.x -= move_unit_size
		on_move()
	elif event.is_action_pressed("MoveUp") and position.y > 0:
		position.y -= move_unit_size
		on_move()
	elif event.is_action_pressed("MoveDown") and position.y < (river.map_size.y - 1) * move_unit_size and current_moves_remaining > 0:
		position.y += move_unit_size
		on_move()
	
	# soul collection
	if not hasEmbarked:
		if event.is_action_pressed("CollectSouls"):
			pass
		elif event.is_action_pressed("DropSouls"):
			pass

func on_move():
	if hasEmbarked:
		current_moves_remaining -= 1
		if current_moves_remaining <= 0:
			river.river_flow()
			current_moves_remaining = max_speed
	
func on_river_flow():
	current_moves_remaining = max_speed
