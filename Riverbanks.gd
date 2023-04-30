extends Node

var left_bank_souls:int = 10
var right_bank_souls:int = 0

func reset(starting_value):
	right_bank_souls = 0
	left_bank_souls = starting_value

func collect_from_left(amount:int):
	left_bank_souls -= amount

func deposit_on_left(amount:int):
	left_bank_souls += amount

func deposit_on_right(amount:int):
	right_bank_souls += amount
