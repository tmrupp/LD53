extends Node2D

var spacing = 128.0
var map = []

var map_size = Vector2i(10, 10)

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
		
func remove_unit(unit, pos):
	if(units.has(pos)):
		units[pos].erase(unit)
		if len(units[pos]) == 0:
			units.erase(pos)

func move_unit(unit, origin, target):
	remove_unit(unit, origin)
	add_unit(unit, target)

func create_unit(unit, pos, dynamic=true, right=true):
	var instance = unit.instantiate()
	instance.setup(right, dynamic)
	add_child(instance)
	instance.position = pos * spacing
	add_unit(instance, pos)
	return instance

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

func _input(event):
	if event.is_action_pressed("next_turn"):
		print("----------------------------")
		for pos in units.keys():
			for unit in units[pos]:
				print("pos=", pos)
				if unit.dynamic:
					print("moving!")
					var new_pos = pos + down
					if units.has(new_pos):
						new_pos = pos + (Vector2i(1, 0) if unit.right else Vector2i(-1, 0))
						
					move_unit(unit, pos, new_pos)
				
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
