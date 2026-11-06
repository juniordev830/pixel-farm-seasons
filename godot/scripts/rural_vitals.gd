extends RefCounted
## Regras puras de necessidades do fazendeiro (0..100 de saciedade/energia).
## "satiety" significa estomago cheio; valores baixos indicam fome.

static func movement_multiplier(satiety: float, energy: float) -> float:
    var multiplier := 1.0
    if satiety < 15.0:
        multiplier *= 0.70
    elif satiety < 35.0:
        multiplier *= 0.85
    if energy < 10.0:
        multiplier *= 0.60
    elif energy < 25.0:
        multiplier *= 0.78
    return clampf(multiplier, 0.42, 1.0)


static func advance(satiety: float, energy: float, game_minutes: float, sprinting: bool, night: bool) -> Dictionary:
    if not is_finite(game_minutes) or game_minutes <= 0.0:
        return {"satiety": clampf(satiety, 0.0, 100.0), "energy": clampf(energy, 0.0, 100.0)}
    var next_satiety := maxf(0.0, satiety - game_minutes * 0.06)
    var energy_cost := 0.04
    if sprinting:
        energy_cost += 0.08
    if next_satiety < 25.0:
        energy_cost += 0.035
    if night:
        energy_cost += 0.02
    return {
        "satiety": next_satiety,
        "energy": maxf(0.0, energy - game_minutes * energy_cost)
    }
