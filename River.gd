extends Node2D

var spacing = 128.0
var map = []

var map_size = Vector2i(10, 10)
var move_unit_size = 128

var sprite = preload("res://lil_guy.tscn")
@onready var main = $".."
#var dynamic = preload("res://dynamic.tscn")
var unit_prefab = preload("res://unit.tscn")

@onready var player = $"../Player"
var player_position:Vector2i = Vector2i.ZERO
var units = {}

func add_unit(unit, pos):
#	print("Adding unit at=", pos, " units.has(pos)=", units.has(pos), " unit?=", unit==null)
	if units.has(pos):
		units[pos].append(unit)
	else:
		units[pos] = [unit]
	unit.position = spacing * pos
		
func remove_unit(unit, pos:Vector2i):
	if(units.has(pos)):
#		print("pre ", len(units[pos]))
		units[pos].erase(unit)
#		print("post ", len(units[pos]))
		if len(units[pos]) == 0:
			units.erase(pos)
#		print("post, has=", units.has(pos))

func delete_unit(unit, pos:Vector2i):
	remove_unit(unit, pos)
	unit.queue_free()

func find_unit_pos(unit):
	for pos in units.keys():
		if unit in units[pos]:
			print("unit @ ", pos)

func delete_all_units_at(pos:Vector2i):
	if units.has(pos):
		for unit in units[pos]:
			unit.queue_free()
		units[pos].clear()
		units.erase(pos)
		
func delete_all_units():
	for pos in units.keys():
		for unit in units[pos]:
			unit.queue_free()
		units[pos].clear()
	units.clear()

func move_unit(unit, origin:Vector2i, target:Vector2i):
	remove_unit(unit, origin)
	add_unit(unit, target)

func create_unit(unit, pos, dynamic=true, right=true):
	var instance = unit.instantiate()
	instance.setup(right, dynamic)
	add_child(instance)
#	instance.position = pos * spacing
	add_unit(instance, pos)
	return instance
	
func get_units(pos):
	if units.has(pos):
		return units[pos]
	else:
		return []
		
func any_static(pos):
	for unit in get_units(pos):
		if not unit.dynamic:
			return true
	return false
	
func any_not_pushable(pos):
	for unit in get_units(pos):
		if not unit.pushable:
			return true
	return false
	
func in_range(pos):
	return pos.x >= 0 and pos.x < map_size.x and pos.y >= 0 and pos.y < map_size.y
	
func in_shore_range(pos):
	return pos.x >= 0 and pos.x < map_size.x
	
func push_units(from, pos) -> bool:
	var new_pos = (pos-from)+pos
	
	if len(get_units(pos)) == 0:
		return true
		
	if any_not_pushable(pos):
		return false
	
	if not in_shore_range(new_pos) or any_not_pushable(new_pos):
		return false
	else:
		if push_units(pos, new_pos):
			for unit in get_units(pos):
				move_unit(unit, pos, new_pos)
			return true
	return false

# Called when the node enters the scene tree for the first time.
var gen = true
@onready var riverbanks = $Riverbanks
func generate_starting_units():
	for x in range(map_size.x):
		for y in range(map_size.y):
			var v = Vector2i(x, y)
			if randi() % 20 == 0:
				create_unit(unit_prefab, v, true, randi() % 2 == 0)
			elif randi() % 20 == 1:
				create_unit(unit_prefab, v, false)

var level = 1

func full_reset():
	level = 1
	player.full_reset()
	next_level()

func next_level():
	delete_all_units()
	riverbanks.reset(12*level)
	if (gen):
		generate_starting_units()
	player.next_level()
	level += 1
	
func _ready():
	randomize()
		
	# assuming a square rn
	spacing = sprite.instantiate().texture.get_width()
#	print(spacing)
	for x in range(map_size.x):
		for y in range(map_size.y):
			var v = Vector2i(x, y)
			var s = sprite.instantiate()
			add_child(s)
			s.position = v * spacing
			
	next_level()

var down = Vector2i(0, 1) # ???

enum {Open_Space, Player_Occupied, Other_Occupied}
func can_flow(try_pos):
	if player_position == try_pos:
		return Player_Occupied
	if any_static(try_pos) or not in_shore_range(try_pos):
		return Other_Occupied
	return Open_Space
	# return not (any_static(try_pos) or player_position == try_pos or not in_shore_range(try_pos))
	
func same_flow_unit_at(unit, try_pos):
	for new_unit in get_units(try_pos):
		if new_unit.right == unit.right:
			return true
	return false

func get_dir(unit):
	return Vector2i(1, 0) if unit.right else Vector2i(-1, 0)

func try_flow(unit, pos, try_pos):
	var can_flow_state = can_flow(try_pos)
	if can_flow_state == Open_Space:
		if not same_flow_unit_at(unit, try_pos):
			move_unit(unit, pos, try_pos)
			unit.moved = true
			return true
			
		for new_unit in get_units(try_pos):
			flow_unit(new_unit, try_pos)
	elif can_flow_state == Player_Occupied:
		unit.deal_damage_to_player(player)
	return false

func flow_unit(unit, pos):
#	print("flowing unit=", unit, " @ ", pos)
	if unit.moved or not unit.dynamic:
		return
	
	var new_pos = pos
	
	if (not unit.layered):
		new_pos = pos + down
		if try_flow(unit, pos, new_pos):
			return
	
	new_pos = pos + down + get_dir(unit)
	if try_flow(unit, pos, new_pos):
		return
		
	new_pos = pos + get_dir(unit)
	if try_flow(unit, pos, new_pos):
		return
	
	if (unit.layered):
		new_pos = pos + down
		if try_flow(unit, pos, new_pos):
			return
		
#		new_pos = pos + (Vector2i(1, 0) if unit.right else Vector2i(-1, 0))
#		new_pos.x = clamp(new_pos.x, 0, map_size.x - 1)
	unit.moved = true
		
	
func refresh_unit(unit):
	unit.moved = false
	
func to_grid_pos(pos):
	return Vector2i((pos+Vector2.ONE*spacing/2)/spacing)
	
func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
#		print("clicked at, ", to_grid_pos(get_global_mouse_position()), " glob=", get_global_mouse_position())
		var pos = to_grid_pos(get_global_mouse_position())
		if len(get_units(pos)) == 0:
			create_unit(unit_prefab, pos, true, true)
		else:
			var unit = get_units(pos)[0]
			if unit.dynamic and unit.right:
				unit.right = false
			elif unit.dynamic:
				unit.dynamic = false
				unit.pushable = false
			else:
				delete_unit(unit, pos)
				
			unit.update()
			
func get_all_units():
	var all_units = []
	for pos in units.keys():
		for unit in units[pos]:
			all_units.append(unit)
	return all_units
	

func river_flow():
#	print("----------------------------")
	var keys_at = []
	keys_at.append_array(units.keys())
	for pos in keys_at:
		var units_at = []
		if units.has(pos):
			units_at.append_array(units[pos])
			for unit in units_at:
				unit.layered = len(units_at) > 1
	#			print("trying to flow: ", unit, " ", str(unit), " pos=", pos)
				if unit.dynamic:
	#				print(len(units[pos]))
					flow_unit(unit, pos)
	#			print("pos=", pos)
	#			if unit.dynamic:
	#				var new_pos = pos + down
	##				print("moving!")
	#				if (units.has(new_pos) or (player_position == new_pos)):
	#					new_pos = pos + (Vector2i(1, 0) if unit.right else Vector2i(-1, 0))
	#					new_pos.x = clamp(new_pos.x, 0, map_size.x - 1)
	#
#				move_unit(unit, pos, new_pos)

	for pos in units.keys():
		for unit in units[pos]:
			refresh_unit(unit)
	
	# randomly add new units just above the top of the grid
	if (gen):
		for x in range(map_size.x):
			var v = Vector2i(x, -1)
			if randi() % 20 == 0:
				create_unit(unit_prefab, v, true, randi() % 2 == 0)
	
	# clear units that are now off the bottom of the grid
	for x in range(map_size.x):
		delete_all_units_at(Vector2i(x, map_size.y))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
