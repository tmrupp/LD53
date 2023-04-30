extends Node2D

class_name Player

@onready var river:Node = $"../River"
@onready var riverbanks:Node = $"../River/Riverbanks"
@onready var ui_speed:Node = $"../UI/Speed"
@onready var ui_souls_carried:Node = $"../UI/SoulsCarried"
@onready var move_unit_size:int = $"../River".move_unit_size
@onready var shop = $"../Shop"
var grid_position:Vector2i

enum BOAT_STATE {On_Left, In_River, On_Right}

var state:BOAT_STATE = BOAT_STATE.On_Left
#var max_speed:int = 3 # the value we reset 'speedcurrent_moves_remaining' to after the river flows
#var current_moves_remaining:int = max_speed

var speed 
var strength 
var souls

#var soul_capacity:int = 4 # max number of souls you can carry at once
#var current_soul_count:int = 0 # number of souls currently being carried
#
#var strength:int = 6 # amount of "free pushes"
#var strength_capacity:int = 6 # amount to replenish when on shore

var delivery_num:int = 1 # number of deliveries made this run

@onready var animation_player:AnimationPlayer = $"garon/AnimationPlayer"
@onready var player_visual:Node2D = $"garon"

class Stat:
	var capacity:int = 4
	var current:int = 0
	var label
	var stat_name
	
	func _init(capacity, label, stat_name, current=0):
		self.capacity = capacity
		self.current = current
		self.label = label
		self.stat_name = stat_name
		
	func refresh():
		current = capacity
		
	func clear():
		current = 0
		
	func has():
		return current > 0
		
	func modify(value:int):
		current += value
		
	func show():
		var postlude = "  " if stat_name == "" else "" 
		label.text = stat_name + ": " + str(current) + "/" + str(capacity) + postlude

func _process(delta):
	speed.show()
	strength.show()
	souls.show()

func _ready():
	grid_position = Vector2i(-1, 0)
	animation_player.get_animation("push").set_loop_mode(0)
	animation_player.get_animation("paddle").set_loop_mode(0)
	animation_player.stop()
	player_visual.scale.x = -absf(player_visual.scale.x)
	full_reset()
	
func next_level():
	grid_position = Vector2i(-1, 0)
	position = move_unit_size * grid_position
	
	speed.refresh()
	strength.refresh()
	souls.clear()
	delivery_num = 1
	
func full_reset():
	speed = Stat.new(3, $"../Shop/Top/PanelContainer4/HBoxContainer/Speed", "",  3)
	strength = Stat.new(6, $"../Shop/Top/PanelContainer3/HBoxContainer/Strength", "")
	souls = Stat.new(4, $"../Shop/Top/PanelContainer2/HBoxContainer/Souls", "")
	next_level()
	
func interact_with_unit(direction:Vector2i):
	# print("lpp=", grid_position, " direction=", direction)
	for unit in river.get_units(grid_position+direction):
		unit.deal_damage_to_player(self)
	var status:River.PUSH_STATUS = river.push_units(grid_position, grid_position+direction)
	
	# set animation based on if we had to push or not
	if status == River.PUSH_STATUS.No_Push_Required:
		animation_player.play("paddle")
	if status == River.PUSH_STATUS.Can_Push:
		animation_player.play("push")
	animation_player.queue("idle")
	
	return status
	
func deliver():
#	current_moves_remaining = max_speed
	speed.refresh()
	shop.delta_coins(souls.current*(2.0/delivery_num))
	delivery_num += 1
	riverbanks.deposit_on_right(souls.current)
	souls.clear()
	
	# all souls delivered
	if riverbanks.left_bank_souls == 0:
		river.next_level()
	
func _input(event):
	# movement
	if event.is_action_pressed("Wait"):
		on_move()
	elif event.is_action_pressed("MoveRight") and grid_position.x < river.map_size.x and speed.has():
		if interact_with_unit(Vector2i(1,0)) != River.PUSH_STATUS.Cant_Push:
			grid_position.x += 1
			on_move()
			if state == BOAT_STATE.On_Left:
				state = BOAT_STATE.In_River
			elif state == BOAT_STATE.In_River and grid_position.x == river.map_size.x:
				state = BOAT_STATE.On_Right
				deliver()
	elif event.is_action_pressed("MoveLeft") and grid_position.x >= 0 and speed.has():
		if interact_with_unit(Vector2i(-1,0)) != River.PUSH_STATUS.Cant_Push:
			grid_position.x -= 1
			on_move()
			if state == BOAT_STATE.On_Right:
				state = BOAT_STATE.In_River
			elif state == BOAT_STATE.In_River and grid_position.x < 0:
				state = BOAT_STATE.On_Left
				speed.refresh()
	elif event.is_action_pressed("MoveUp") and grid_position.y > 0:
		if interact_with_unit(Vector2i(0,-1)) != River.PUSH_STATUS.Cant_Push:
			grid_position.y -= 1
			on_move()
	elif event.is_action_pressed("MoveDown") and grid_position.y < (river.map_size.y - 1) * move_unit_size and speed.has():
		if interact_with_unit(Vector2i(0, 1)) != River.PUSH_STATUS.Cant_Push:
			grid_position.y += 1
			on_move()
	
	if state == BOAT_STATE.On_Left or state == BOAT_STATE.On_Right:
		animation_player.stop()
	
	# soul collection
	if state == BOAT_STATE.On_Left:
		strength.refresh()
		if event.is_action_pressed("CollectSouls"):
			if riverbanks.left_bank_souls > 0 and souls.current < souls.capacity:
				riverbanks.collect_from_left(1)
				souls.modify(1)
		elif event.is_action_pressed("DropSouls"):
			if souls.current > 0:
				riverbanks.deposit_on_left(1)
				souls.modify(-1)
			
	# set visual position based on grid position
	position = move_unit_size * grid_position

func on_move():
	river.player_position = grid_position
	if state == BOAT_STATE.In_River:
		speed.modify(-1)
		if speed.current <= 0:
			river.river_flow()
			speed.refresh()
	
	
func on_river_flow():
	speed.refresh()
