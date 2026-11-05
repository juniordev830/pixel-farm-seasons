extends SceneTree
const Rules = preload("res://scripts/farm_rules.gd")

func _initialize() -> void:
	assert(Rules.season_name(1) == "Primavera")
	assert(Rules.season_name(8) == "Verao")
	assert(Rules.season_name(15) == "Outono")
	assert(Rules.season_name(22) == "Inverno")
	assert(Rules.season_name(29) == "Primavera")
	assert(Rules.crop_stage(2, 2) == 0)
	assert(Rules.crop_stage(2, 3) == 1)
	assert(Rules.crop_stage(2, 10) == 3)
	assert(not Rules.can_harvest(2, 4))
	assert(Rules.can_harvest(2, 5))
	assert(Rules.can_buy_seeds(4))
	assert(not Rules.can_buy_seeds(3))
	print("Farm rules: 12 assertions passed")
	quit()
