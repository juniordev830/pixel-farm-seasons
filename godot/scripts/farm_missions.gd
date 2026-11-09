extends RefCounted
## Campanha curta para um primeiro ciclo completo de jogo, com modo livre depois.
## Campos de progresso sao cumulativos para manter compatibilidade com save antigo.
const GOALS := [
    {"key": "harvest", "title": "Colha 6 produtos da horta", "stat": "harvested", "target": 6, "coins": 45, "xp": 30},
    {"key": "animals", "title": "Cuide dos animais em 3 dias", "stat": "animal_days", "target": 3, "coins": 60, "xp": 40},
    {"key": "produce", "title": "Ordenhe 4 litros de leite", "stat": "milk", "target": 4, "coins": 70, "xp": 45},
    {"key": "eggs", "title": "Recolha 9 ovos", "stat": "eggs", "target": 9, "coins": 55, "xp": 35},
    {"key": "market", "title": "Venda 6 produtos na vila", "stat": "sold", "target": 6, "coins": 90, "xp": 55},
    {"key": "days", "title": "Viva 7 dias na fazenda", "stat": "days", "target": 7, "coins": 120, "xp": 65},
]


static func next_goal(stats: Dictionary, claimed: Array) -> Dictionary:
    for goal in GOALS:
        if String(goal["key"]) not in claimed:
            return goal
    return {}


static func describe(stats: Dictionary, claimed: Array) -> String:
    var goal := next_goal(stats, claimed)
    if goal.is_empty():
        return "Campanha concluida! Continue jogando livremente."
    var value := maxi(0, int(stats.get(goal["stat"], 0)))
    return "%s (%d/%d)" % [goal["title"], mini(value, int(goal["target"])), int(goal["target"])]


static func completed(stats: Dictionary, claimed: Array) -> bool:
    # Only canonical objective keys count; extra or duplicate saved values never win.
    return next_goal(stats, claimed).is_empty()
