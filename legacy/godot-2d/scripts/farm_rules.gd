extends RefCounted
## Pure rules: seasons and crop growth are independent of graphics.

static func season_name(day: int) -> String:
	if day < 1:
		return "Invalido"
	var seasons := ["Primavera", "Verao", "Outono", "Inverno"]
	return seasons[((day - 1) / 7) % seasons.size()]


static func crop_stage(planted_on: int, current_day: int) -> int:
	if planted_on < 1 or current_day < planted_on:
		return 0
	return mini(3, current_day - planted_on)


static func can_harvest(planted_on: int, current_day: int) -> bool:
	return planted_on >= 1 and current_day >= planted_on + 3


static func can_buy_seeds(coins: int, price: int = 4) -> bool:
	return coins >= price and price > 0
