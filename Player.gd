extends Node2D

@onready var river:Node = $"../River"
@onready var riverbanks:Node = $"../River/Riverbanks"
@onready var ui_speed:Node = $"../UI/Speed"
@onready var ui_souls_carried:Node = $"../UI/SoulsCarried"
@onready var move_unit_size:int = $"../River".move_unit_size

enum BOAT_STATE {On_Left, In_River, On_Right}

var state:BOAT_STATE = BOAT_STATE.On_Left
var max_speed:int = 3 # the value we reset 'speedcurrent_moves_remaining' to after the river flows
var current_moves_remaining:int = max_speed

var soul_capacity:int = 4 # max number of souls you can carry at once
var current_soul_count:int = 0 # number of souls currently being carried

var strength:int = 6 # amount of "free pushes"
var strength_capacity:int = 6 # amount to replenish when on shore

func _ready():
	position = Vector2i(-move_unit_size, 0)

#func _process(delta):
#	river.player_position = position
	
func interact_with_unit(direction:Vector2i):
	var lpp = river.player_position_to_local()
	print("lpp=", lpp, " direction=", direction)
	return river.push_units(lpp, lpp+direction)
	
func _input(event):
	# movement
	if event.is_action_pressed("MoveRight") and position.x < river.map_size.x * move_unit_size and current_moves_remaining > 0:
		interact_with_unit(Vector2i(1,0))
		position.x += move_unit_size
		on_move()
		if state == BOAT_STATE.On_Left:
			state = BOAT_STATE.In_River
		elif state == BOAT_STATE.In_River and position.x == river.map_size.x * move_unit_size:
			state = BOAT_STATE.On_Right
			current_moves_remaining = max_speed
			riverbanks.deposit_on_right(current_soul_count)
			current_soul_count = 0
	elif event.is_action_pressed("MoveLeft") and position.x >= 0 and current_moves_remaining > 0:
		interact_with_unit(Vector2i(-1,0))
		position.x -= move_unit_size
		on_move()
		if state == BOAT_STATE.On_Right:
			state = BOAT_STATE.In_River
		elif state == BOAT_STATE.In_River and position.x < 0:
			state = BOAT_STATE.On_Left
			current_moves_remaining = max_speed
	elif event.is_action_pressed("MoveUp") and position.y > 0:
		interact_with_unit(Vector2i(0,-1))
		position.y -= move_unit_size
		on_move()
	elif event.is_action_pressed("MoveDown") and position.y < (river.map_size.y - 1) * move_unit_size and current_moves_remaining > 0:
		interact_with_unit(Vector2i(0, 1))
		position.y += move_unit_size
		on_move()
	
	# soul collection
	if state == BOAT_STATE.On_Left:
		strength = strength_capacity
		if event.is_action_pressed("CollectSouls"):
			riverbanks.collect_from_left(1)
			current_soul_count += 1
		elif event.is_action_pressed("DropSouls"):
			riverbanks.deposit_on_left(1)
			current_soul_count -= 1

func on_move():
	river.player_position = position
	if state == BOAT_STATE.In_River:
		current_moves_remaining -= 1
		if current_moves_remaining <= 0:
			river.river_flow()
			current_moves_remaining = max_speed
	
	
func on_river_flow():
	current_moves_remaining = max_speed
