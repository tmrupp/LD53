extends Node

var left_bank_souls:int = 10
var right_bank_souls:int = 0

var soul_sprite = preload("res://soul.tscn")
@onready var left_bank = $"../LeftBankVisual"
@onready var right_bank = $"../RightBankVisual"
var bank_padding = Vector2(100.0, 100.0)
#var bank_padding = Vector2(0,0)

var souls = {
	"left":[],
	"right":[],
}

var to_bank_node = {}

func get_random_by_range_in_bank(bank):
	var bank_node = to_bank_node[bank]
	var transform:Transform2D = bank_node.get_transform()
	var size = bank_node.texture.get_size()
	var random_location = Vector2(clamp(randfn(0, .2), -.5, .5), randf()-.5)
	return transform.origin + ((size * transform.get_scale() - bank_padding)*random_location)

func delete_all_souls():
	for bank in souls.keys():
		for soul in souls[bank]:
			soul.queue_free()
		souls[bank].clear()
		
func modify_souls(bank, value):
	
	if value < 0:
		for i in range(abs(value)):
			var soul = souls[bank].pop_back()
			soul.queue_free()
	else:
		for i in range(value):
			var soul = soul_sprite.instantiate()
			add_child(soul)
			souls[bank].append(soul)
			
			soul.position = get_random_by_range_in_bank(bank)

func _ready():
	print(left_bank.get_transform())
	print(left_bank.texture.get_size())
	to_bank_node = {
		"left":left_bank,
		"right":right_bank,
	}
	
#	modify_souls("left", 60)
#	modify_souls("right", 60)
#	modify_souls("right", -30)

func reset(starting_value):
	delete_all_souls()
	right_bank_souls = 0
	left_bank_souls = starting_value
	modify_souls("left", starting_value)

func collect_from_left(amount:int):
	left_bank_souls -= amount
	modify_souls("left", -amount)

func deposit_on_left(amount:int):
	left_bank_souls += amount
	modify_souls("left", amount)

func deposit_on_right(amount:int):
	print("try me")
	right_bank_souls += amount
	modify_souls("right", amount)
