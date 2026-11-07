extends RefCounted
## Relogio hibrido: o tempo passa sozinho e atividades acrescentam minutos.
## Distancias percorridas tambem contam como tempo de viagem.
## Escala de fundo: 1 segundo real = 0.5 minuto no jogo (ajustavel).
## Assim 1 hora no jogo dura 2 minutos reais sem tarefas.
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

const REALTIME_MINUTES_PER_SECOND := 0.5
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


## Consequencia do almoco atrasado: das 12h as 16h30.
## O aviso ja aparece as 11h; a janela de tolerancia evita punicao imediata.
## A funcao cobre apenas a janela do dia corrente, sem cobrar minutos fora dela.
const LUNCH_LATE_MINUTE := 720.0
const LUNCH_LATE_END_MINUTE := 990.0
const LUNCH_LATE_ENERGY_PER_MINUTE := 0.04


static func missed_lunch_energy_cost(start_minutes: float, elapsed_minutes: float, ate_lunch: bool) -> float:
    if ate_lunch or not is_finite(start_minutes) or not is_finite(elapsed_minutes) or elapsed_minutes <= 0.0:
        return 0.0
    var start := maxf(start_minutes, LUNCH_LATE_MINUTE)
    var finish := minf(start_minutes + elapsed_minutes, LUNCH_LATE_END_MINUTE)
    return maxf(0.0, finish - start) * LUNCH_LATE_ENERGY_PER_MINUTE
