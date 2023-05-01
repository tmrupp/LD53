extends Node2D

@onready var river = $".."

func _input(event):
	var pos = river.to_grid_pos(get_global_mouse_position())
	var amount = 0
	
#	if event.is_action_pressed("AddDamage"):
#		alter_unit_damage(pos, 1)
#	elif event.is_action_pressed("SubtractDamage"):
#		alter_unit_damage(pos, -1)

func alter_unit_damage(pos:Vector2i, amount:int):
	if river.units.has(pos):
		for unit in river.units[pos]:
			unit.damage += amount
			if unit.damage < 0:
				unit.damage = 0
	else:
		print("no units at: ", pos)
