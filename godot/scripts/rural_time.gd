extends RefCounted
## Relogio por acontecimentos: nao usa conversao fixa segundos-reais -> minutos.
## Toda acao bem-sucedida consome uma duracao plausivel dentro do jogo.
## Distancias percorridas tambem consomem tempo (caminhada ou direcao).
## As duracoes sao valores iniciais de balanceamento, editaveis neste arquivo.

const ACTIVITY_MINUTES := {
    "preparar_refeicao": 10.0,
    "cafe": 20.0,
    "almoco": 35.0,
    "jantar": 30.0,
    "alimentar_animais": 25.0,
    "colocar_agua": 12.0,
    "ordenhar": 30.0,
    "recolher_ovos": 12.0,
    "reparar_carro": 70.0,
    "mercado": 25.0,
    "plantar": 9.0,
    "regar": 5.0,
    "colher": 12.0,
    "assistir_tv": 35.0,
    "usar_notebook": 25.0,
    "descansar_rede": 45.0
}

const WALK_METERS_PER_GAME_MINUTE := 80.0
const DRIVE_METERS_PER_GAME_MINUTE := 500.0


static func activity_minutes(activity: String) -> float:
    return float(ACTIVITY_MINUTES.get(activity, 0.0))


static func travel_minutes(distance_meters: float, driving: bool) -> float:
    if not is_finite(distance_meters) or distance_meters <= 0.0:
        return 0.0
    var meters_per_minute := DRIVE_METERS_PER_GAME_MINUTE if driving else WALK_METERS_PER_GAME_MINUTE
    return distance_meters / meters_per_minute


static func meal_activity(meal: String) -> String:
    if meal == "cafe" or meal == "almoco" or meal == "jantar":
        return meal
    return "almoco"
