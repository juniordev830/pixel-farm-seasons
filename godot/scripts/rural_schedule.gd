extends RefCounted
## Pensamentos do fazendeiro conforme horarios e tarefas pendentes.
## A rotina orienta o jogador sem obrigar a parar outras atividades.

static func current_prompt(minutes: float, meals: Dictionary, animals_fed: bool, animals_watered: bool, energy: float) -> Dictionary:
    var hour := int(minutes) % 1440
    if hour >= 1320 or hour < 315:
        return {"id": "sono", "text": "Eita, ja ficou tarde! Melhor ir dormir e descansar."}
    if hour >= 1080 and hour < 1320 and not bool(meals.get("jantar", false)):
        return {"id": "jantar", "text": "Ja sao 18h! Vou preparar minha janta."}
    if hour >= 660 and hour < 990 and not bool(meals.get("almoco", false)):
        return {"id": "almoco", "text": "Eita, ja sao 11h! Tenho que almoçar!"}
    if hour >= 330 and hour < 630 and not bool(meals.get("cafe", false)):
        return {"id": "cafe", "text": "Bom dia! Vou preparar meu cafe da manha."}
    if hour >= 390 and hour < 1080 and not animals_fed:
        return {"id": "animais_racao", "text": "Os animais devem estar com fome. Vou colocar racao."}
    if hour >= 390 and hour < 1080 and not animals_watered:
        return {"id": "animais_agua", "text": "Preciso abastecer os bebedouros dos animais."}
    if energy < 23.0:
        return {"id": "cansaco", "text": "Estou cansado! Vou descansar na rede ou dormir."}
    return {}
