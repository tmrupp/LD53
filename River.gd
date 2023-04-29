extends Node2D

var spacing = 128.0
var map = []

var map_size = Vector2i(10, 10)
var move_unit_size = 128

var sprite = preload("res://lil_guy.tscn")
@onready var main = $".."
#var dynamic = preload("res://dynamic.tscn")
var unit_prefab = preload("res://unit.tscn")

var player_position = Vector2i.ZERO

var units = {}

func add_unit(unit, pos):
	if units.has(pos):
		units[pos].append(unit)
	else:
		units[pos] = [unit]
	unit.position = spacing * pos
		
func remove_unit(unit, pos:Vector2i):
	if(units.has(pos)):
		units[pos].erase(unit)
		if len(units[pos]) == 0:
			units.erase(pos)

func delete_all_units_at(pos:Vector2i):
	print("deleting all at: ", pos)
	if units.has(pos):
		for unit in units[pos]:
			unit.queue_free()
		units[pos].clear()
		units.erase(pos)

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
		
func player_position_to_local():
	return Vector2i(player_position/spacing)
	
func in_range(pos):
	return pos.x >= 0 and pos.x < map_size.x and pos.y >= 0 and pos.y < map_size.y
	
func push_units(from, pos) -> bool:
	var new_pos = (pos-from)+pos
	
	print("pushing units! from=", from, " pos=", pos, " new_pos=", new_pos)
	
	if not in_range(new_pos) or any_static(new_pos):
		return false
	else:
		if len(get_units(pos)) == 0 or push_units(pos, new_pos):
			for unit in get_units(pos):
				move_unit(unit, pos, new_pos)
			return true
	return false

# Called when the node enters the scene tree for the first time.
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
			
			if randi() % 20 == 0:
				add_unit(create_unit(unit_prefab, v, true, randi() % 2 == 0), v)
			elif randi() % 20 == 1:
				add_unit(create_unit(unit_prefab, v, false), v)

var down = Vector2i(0, 1) # ???

func river_flow():
	print("----------------------------")
	for pos in units.keys():
		for unit in units[pos]:
			print("pos=", pos)
			if unit.dynamic:
#				print("moving!")
				var new_pos = pos + down
				if units.has(new_pos):
					new_pos = pos + (Vector2i(1, 0) if unit.right else Vector2i(-1, 0))
					
				move_unit(unit, pos, new_pos)
	
	# randomly add new units just above the top of the grid
	for x in range(map_size.x):
		var v = Vector2i(x, -1)
		if randi() % 20 == 0:
			add_unit(create_unit(unit_prefab, v, true, randi() % 2 == 0), v)
			
	for pos in units.keys():
		for unit in units[pos]:
			print("new pos=", pos)
	
	# clear units that are now off the bottom of the grid
	for x in range(map_size.x):
		delete_all_units_at(Vector2i(x, map_size.y))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
