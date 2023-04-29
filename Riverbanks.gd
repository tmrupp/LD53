extends Node

var left_bank_souls:int = 10
var right_bank_souls:int = 0

func collect_from_left(amount:int):
	left_bank_souls -= amount

func deposit_on_left(amount:int):
	left_bank_souls += amount

func deposit_on_right(amount:int):
	right_bank_souls += amount
