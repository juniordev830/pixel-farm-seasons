extends Node3D
signal campaign_won
## Pixel Farm Seasons — vertical slice de vida rural.
## Complementa a cena farm_world.tscn sem mexer no jogo web 2D.
## Os modelos sao prototipos; nao ha streaming real de TV, radio ou Internet.

const SAVE_PATH := "user://pixel_farm_life_save.json"
const DAY_MINUTES := 1440.0
const TimeRules = preload("res://scripts/rural_time.gd")
const Schedule = preload("res://scripts/rural_schedule.gd")
const VitalRules = preload("res://scripts/rural_vitals.gd")
const Missions = preload("res://scripts/farm_missions.gd")

var farmer: CharacterBody3D
var car: CharacterBody3D
var hud_stats: Label
var hud_hint: Label
var hud_notice: Label
var hud_thought: Label
var farm_system: Node3D
var tv_screen: MeshInstance3D
var notebook_screen: MeshInstance3D
var radio_indicator: MeshInstance3D
var interactions: Array[Dictionary] = []

var day := 1
var minutes := 390.0
var hunger := 82.0
var energy := 96.0
var coins := 180
var level := 1
var experience := 0
var mission_stats: Dictionary = {"harvested": 0, "animal_days": 0, "milk": 0, "eggs": 0, "sold": 0, "days": 0}
var mission_completed: Array[String] = []
var campaign_finished := false
var food := 6
var feed := 5
var seeds := 12
var harvested := 0
var eggs := 0
var milk := 0
var car_condition := 90.0
var cow_fed := false
var animals_watered := false
var cow_milked := false
var eggs_collected := false
var meals: Dictionary = {"cafe": false, "almoco": false, "jantar": false}
var ready_meal := false
var tv_on := false
var radio_on := false
var notebook_on := false
var driving := false
var initialized := false
var save_tick := 0.0
var lighting_tick := 0.0
var last_sky_step := -1
var last_travel_position := Vector3.ZERO
var last_reminder_id := ""
var reminder_day := 0


func _ready() -> void:
    # A cena principal monta o mapa em seu _ready(); aguardar para alterar sua casa.
    call_deferred("_setup")


func _setup() -> void:
    farmer = get_parent().get_node_or_null("Farmer") as CharacterBody3D
    if farmer == null:
        push_error("LifeSim: personagem Farmer nao encontrado.")
        return
    _make_house_walkable()
    _build_furniture()
    _build_garage()
    _build_mission_board()
    _build_outskirts()
    _build_hud()
    _register_activities()
    farm_system = get_parent().get_node_or_null("FarmingSystem")
    if farm_system != null:
        farm_system.call("ensure_initialized")
    _load_progress()
    last_travel_position = farmer.global_position
    _refresh_devices()
    _update_light()
    _refresh_reminder()
    _announce("Bem-vindo ao sitio! Entre na casa, cuide dos animais ou dirija ate o mercado.")
    initialized = true
    _review_missions()


func _make_mat(tint: Color) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = tint
    mat.roughness = 0.83
    return mat


func _box(n: String, at: Vector3, size: Vector3, tint: Color, solid: bool = false, parent_node: Node3D = null) -> MeshInstance3D:
    var mesh_node := MeshInstance3D.new()
    mesh_node.name = n
    mesh_node.set_meta("native_prop", n)
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh_node.mesh = mesh
    mesh_node.material_override = _make_mat(tint)
    mesh_node.position = at
    if parent_node == null:
        add_child(mesh_node)
    else:
        parent_node.add_child(mesh_node)
    if solid:
        var body := StaticBody3D.new()
        body.name = "Colisao"
        var col := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = size
        col.shape = shape
        body.add_child(col)
        mesh_node.add_child(body)
    return mesh_node


func _sphere(n: String, at: Vector3, size: Vector3, tint: Color, parent_node: Node3D = null) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = n
    node.set_meta("native_prop", n)
    var mesh := SphereMesh.new()
    mesh.radius = 0.5
    mesh.height = 1.0
    mesh.radial_segments = 12
    mesh.rings = 7
    node.mesh = mesh
    node.material_override = _make_mat(tint)
    node.position = at
    node.scale = size
    if parent_node == null:
        add_child(node)
    else:
        parent_node.add_child(node)
    return node


func _remove_world_mesh(n: String) -> void:
    var obj := get_parent().get_node_or_null(n)
    if obj != null:
        obj.free()


func _make_house_walkable() -> void:
    # Retira o bloco macico da casa anterior e substitui por paredes de verdade.
    _remove_world_mesh("Casa - paredes de dois pavimentos")
    _remove_world_mesh("Porta principal")

    var clay := Color("#efe0c5")
    var timber := Color("#9c6a45")
    var floor_tint := Color("#c49264")

    # Casa existente ocupa X -19.6..-10.4, Z -17.6..-10.4.
    _box("Chao interno", Vector3(-15, 0.10, -14), Vector3(9.0, 0.2, 7.0), floor_tint, true)
    _box("Parede oeste", Vector3(-19.55, 2.75, -14), Vector3(0.20, 5.5, 7.2), clay, true)
    _box("Parede leste", Vector3(-10.45, 2.75, -14), Vector3(0.20, 5.5, 7.2), clay, true)
    _box("Parede fundos", Vector3(-15, 2.75, -17.55), Vector3(9.2, 5.5, 0.20), clay, true)

    # Porta principal com vao de 2 metros, livre para entrar a pe.
    _box("Fachada terreo esquerda", Vector3(-17.8, 1.43, -10.43), Vector3(3.6, 2.86, 0.2), clay, true)
    _box("Fachada terreo direita", Vector3(-12.2, 1.43, -10.43), Vector3(3.6, 2.86, 0.2), clay, true)
    _box("Fachada segundo andar", Vector3(-15, 4.27, -10.43), Vector3(9.2, 2.46, 0.2), clay, true)

    # Piso do andar superior deixa um corredor aberto para a escada.
    _box("Laje segundo pavimento", Vector3(-16.13, 2.93, -14.05), Vector3(6.92, 0.22, 6.9), floor_tint, true)
    _box("Patamar da escada", Vector3(-11.57, 2.93, -16.94), Vector3(2.2, 0.22, 1.1), floor_tint, true)

    # Rampa transitavel como colisao da escada; degraus decorativos por cima.
    var stair := _box("Escada inclinada transitavel", Vector3(-11.62, 1.57, -13.65), Vector3(1.75, 0.20, 6.35), timber, true)
    stair.rotation.x = 0.44
    for i in range(11):
        var t := float(i) / 10.0
        _box("Degrau decorativo", Vector3(-11.62, 0.30 + 2.55 * t, -10.95 - 5.43 * t), Vector3(1.75, 0.11, 0.30), Color("#d5a573"))

    # Parede interna parcial, mantendo circulacao entre sala e cozinha.
    _box("Divisoria cozinha", Vector3(-16.65, 1.4, -15.0), Vector3(0.12, 2.8, 2.15), clay)
    _box("Parede quarto superior", Vector3(-16.0, 4.0, -14.7), Vector3(0.11, 2.0, 2.6), clay)
    _box("Tapete sala", Vector3(-17.5, 0.22, -12.6), Vector3(2.4, 0.025, 2.15), Color("#a96c54"))


func _build_furniture() -> void:
    var brown := Color("#825536")
    var cream := Color("#e9d9b6")
    var steel := Color("#a4aab0")

    # Sala de estar com sofa e televisao com tela ligada/desligada.
    _box("Sofa - assento", Vector3(-17.65, 0.55, -12.4), Vector3(1.65, 0.35, 0.74), Color("#b0a27d"))
    _box("Sofa - encosto", Vector3(-17.65, 0.87, -12.72), Vector3(1.65, 0.8, 0.18), Color("#b0a27d"))
    _box("Rack", Vector3(-17.65, 0.6, -15.3), Vector3(1.65, 0.55, 0.45), brown)
    _box("TV moldura", Vector3(-17.65, 1.38, -15.42), Vector3(1.75, 1.05, 0.15), Color("#22252b"))
    tv_screen = _box("TV tela", Vector3(-17.65, 1.4, -15.32), Vector3(1.54, 0.85, 0.05), Color("#252c36"))

    # Cozinha + geladeira que controla o estoque de alimentos.
    _box("Balcao cozinha", Vector3(-14.35, 0.75, -16.65), Vector3(2.5, 1.4, 0.62), brown)
    _box("Pia cozinha", Vector3(-14.35, 1.47, -16.65), Vector3(2.5, 0.1, 0.65), steel)
    _box("Geladeira funcional", Vector3(-12.95, 1.1, -16.68), Vector3(0.9, 2.2, 0.8), cream)
    _box("Geladeira freezer", Vector3(-12.95, 1.62, -16.25), Vector3(0.81, 0.04, 0.06), steel)
    _box("Mesa de refeicoes", Vector3(-14.72, 0.85, -12.62), Vector3(1.9, 0.14, 1.28), brown)
    for dx in [-0.83, 0.83]:
        _box("Cadeira da cozinha", Vector3(-14.72 + dx, 0.54, -12.62), Vector3(0.34, 0.44, 0.51), cream)
    _box("Radio", Vector3(-14.48, 1.64, -16.68), Vector3(0.51, 0.30, 0.22), Color("#343c45"))
    radio_indicator = _box("Luz do radio", Vector3(-14.48, 1.67, -16.53), Vector3(0.12, 0.08, 0.035), Color("#535c62"))

    # Suite superior com cama, escrivaninha e notebook.
    _box("Cama suite base", Vector3(-18.06, 3.42, -15.35), Vector3(2.0, 0.48, 2.4), brown)
    _box("Cama colchao", Vector3(-18.06, 3.70, -15.35), Vector3(1.85, 0.18, 2.18), cream)
    _box("Cama travesseiro", Vector3(-18.06, 3.84, -16.18), Vector3(1.2, 0.12, 0.4), Color("#f9f3e5"))
    _box("Mesa notebook", Vector3(-14.5, 3.44, -16.5), Vector3(1.45, 0.12, 0.78), brown)
    _box("Notebook teclado", Vector3(-14.5, 3.56, -16.48), Vector3(0.95, 0.045, 0.55), Color("#424953"))
    _box("Notebook moldura", Vector3(-14.5, 3.86, -16.87), Vector3(0.98, 0.64, 0.06), Color("#333a43"))
    notebook_screen = _box("Notebook tela", Vector3(-14.5, 3.86, -16.825), Vector3(0.86, 0.50, 0.02), Color("#293543"))

    # Abajur na suite e luz quente no interior.
    _box("Abajur cabeceira", Vector3(-16.63, 3.9, -16.4), Vector3(0.2, 0.55, 0.2), Color("#e3c178"))
    var lamp := OmniLight3D.new()
    lamp.name = "Luminaria casa"
    lamp.position = Vector3(-15.5, 4.55, -13.2)
    lamp.light_color = Color("#ffdc9e")
    lamp.light_energy = 0.35
    lamp.omni_range = 11.0
    add_child(lamp)
    var porch := OmniLight3D.new()
    porch.name = "Luminaria varanda"
    porch.position = Vector3(-15.0, 2.85, -8.2)
    porch.light_color = Color("#ffd18e")
    porch.light_energy = 1.0
    porch.omni_range = 11.0
    add_child(porch)


func _build_garage() -> void:
    var brown := Color("#896346")
    # Garagem ao lado da casa, com entrada aberta para a estrada.
    _box("Garagem cobertura", Vector3(-25.0, 3.08, -5.0), Vector3(9.5, 0.24, 8.0), Color("#a65e3f"))
    for x in [-29.55, -20.45]:
        for z in [-8.70, -1.30]:
            _box("Pilar da garagem", Vector3(x, 1.50, z), Vector3(0.24, 3.0, 0.24), brown, true)
    _box("Piso garagem", Vector3(-25.0, 0.07, -5.0), Vector3(9.3, 0.14, 7.9), Color("#aa9c86"))
    _box("Bancada mini oficina", Vector3(-28.7, 0.92, -7.8), Vector3(2.35, 0.20, 0.78), brown)
    _box("Caixa de ferramentas", Vector3(-29.0, 1.21, -7.8), Vector3(0.84, 0.43, 0.48), Color("#be4c34"))
    _box("Armario ferramentas", Vector3(-29.15, 1.12, -3.25), Vector3(1.0, 2.24, 0.55), Color("#6b7e80"))
    _make_car()
    _make_bicycle()


func _build_mission_board() -> void:
    # Painel de tarefas visivel perto do ponto de inicio do fazendeiro.
    _box("Quadro de missoes - poste", Vector3(-7.0, 0.87, 8.5), Vector3(0.14, 1.7, 0.14), Color("#765638"))
    _box("Quadro de missoes - placa", Vector3(-7.0, 1.62, 8.5), Vector3(2.6, 1.25, 0.15), Color("#b98d59"))
    _box("Quadro de missoes - papel", Vector3(-7.0, 1.64, 8.60), Vector3(2.28, 0.94, 0.04), Color("#eee0ad"))


func _bike_tube(label: String, a: Vector3, b: Vector3, tint: Color) -> void:
    var direction := b - a
    if direction.length_squared() < 0.0001:
        return
    var tube := _box(label, (a + b) * 0.5, Vector3(0.06, direction.length(), 0.06), tint)
    tube.quaternion = Quaternion(Vector3.UP, direction.normalized())


func _make_bicycle() -> void:
    # Monark vermelha ao lado do Fusca azul. Modelo decorativo, ainda nao dirigivel.
    var red := Color("#c83c36")
    var steel := Color("#929b9b")
    var rear := Vector3(-28.30, 0.45, -2.60)
    var front := Vector3(-26.95, 0.45, -2.60)
    for center in [rear, front]:
        var wheel := MeshInstance3D.new()
        wheel.name = "Monark - roda"
        var ring := TorusMesh.new()
        ring.inner_radius = 0.32
        ring.outer_radius = 0.40
        wheel.mesh = ring
        wheel.material_override = _make_mat(Color("#252525"))
        wheel.position = center
        wheel.rotation.x = PI / 2.0
        add_child(wheel)
        _bike_tube("Monark - raio", center + Vector3(-0.28, 0, 0), center + Vector3(0.28, 0, 0), steel)
        _bike_tube("Monark - raio", center + Vector3(0, -0.28, 0), center + Vector3(0, 0.28, 0), steel)
    var pedals := Vector3(-27.69, 0.60, -2.60)
    var saddle := Vector3(-27.93, 1.16, -2.60)
    var handle := Vector3(-27.10, 1.18, -2.60)
    _bike_tube("Monark - quadro baixo", rear, pedals, red)
    _bike_tube("Monark - quadro central", pedals, saddle, red)
    _bike_tube("Monark - quadro superior", saddle, handle, red)
    _bike_tube("Monark - quadro dianteiro", handle, front, red)
    _bike_tube("Monark - quadro diagonal", handle, pedals, red)
    _bike_tube("Monark - guidom", handle, handle + Vector3(0.0, 0.18, 0.0), steel)
    _box("Monark - selim", saddle + Vector3(-0.06, 0.06, 0), Vector3(0.37, 0.08, 0.23), Color("#333333"))


func _make_car() -> void:
    # Substitui o carro decorativo por modelo simplificado dirigivel.
    for name_to_remove in ["Carro azul - chassi", "Carro azul - cabine", "Para-brisa"]:
        _remove_world_mesh(name_to_remove)
    for child in get_parent().get_children():
        if child.name == "Roda do carro":
            child.free()

    car = CharacterBody3D.new()
    car.name = "Carro dirigivel"
    car.position = Vector3(-25.0, 0.64, -5.0)
    car.rotation.y = PI
    add_child(car)

    var col := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(1.78, 1.2, 3.25)
    col.shape = shape
    car.add_child(col)
    _box("Fusca azul chassi", Vector3(0, 0.16, 0), Vector3(1.7, 0.84, 3.2), Color("#77b4c8"), false, car)
    _box("Fusca azul cabine", Vector3(0, 0.72, 0.2), Vector3(1.52, 0.74, 1.82), Color("#98cbd7"), false, car)
    _box("Parabrisa Fusca", Vector3(0, 0.78, -0.74), Vector3(1.3, 0.48, 0.06), Color("#547889"), false, car)
    for x in [-0.84, 0.84]:
        for z in [-1.05, 1.05]:
            _sphere("Pneu carro", Vector3(x, -0.14, z), Vector3(0.35, 0.64, 0.64), Color("#262a2d"), car)


func _build_outskirts() -> void:
    # Expansao experimental de estrada e pequena venda rural, sem streaming.
    # Extensao um pouco abaixo do nivel do terreno original para evitar cintilacao.
    _box("Terreno vila", Vector3(0, -0.21, 102), Vector3(180, 0.34, 155), Color("#76a05e"), true)
    _box("Estrada para a vila", Vector3(-4, 0.02, 74), Vector3(5.3, 0.05, 106), Color("#bba381"))
    _box("Praca da vila", Vector3(9.1, 0.04, 96), Vector3(18, 0.07, 14), Color("#bfa988"))
    _box("Mercado rural", Vector3(13, 2.35, 93), Vector3(10.0, 4.7, 8.0), Color("#d7ac77"), true)
    _box("Mercado telhado", Vector3(13, 4.9, 93), Vector3(11, 0.40, 9.0), Color("#b35c3d"))
    _box("Mercado fachada", Vector3(13.0, 1.6, 97.1), Vector3(2.25, 3.1, 0.12), Color("#956341"))
    _box("Placa mercado", Vector3(13, 4.0, 97.25), Vector3(5.4, 0.75, 0.15), Color("#507552"))
    _box("Poco vila", Vector3(-12, 0.6, 93), Vector3(2, 1.2, 2), Color("#beb5a0"))
    for i in range(12):
        var z := 42.0 + float(i) * 8.2
        var x := 13.0 if i % 2 == 0 else -21.0
        _box("Arvore da estrada tronco", Vector3(x, 1.45, z), Vector3(0.43, 2.9, 0.43), Color("#8b603d"))
        _sphere("Arvore da estrada copa", Vector3(x, 3.45, z), Vector3(3.2, 2.9, 3.4), Color("#5c8d54"))


func _build_hud() -> void:
    var layer := get_parent().get_node_or_null("HUD") as CanvasLayer
    if layer == null:
        layer = CanvasLayer.new()
        get_parent().add_child(layer)
    hud_stats = Label.new()
    hud_stats.name = "LifeStats"
    hud_stats.position = Vector2(24, 98)
    hud_stats.add_theme_font_size_override("font_size", 20)
    hud_stats.add_theme_color_override("font_color", Color("#fff4d9"))
    hud_stats.add_theme_color_override("font_shadow_color", Color("#18251c"))
    hud_stats.add_theme_constant_override("shadow_offset_x", 2)
    hud_stats.add_theme_constant_override("shadow_offset_y", 2)
    layer.add_child(hud_stats)

    hud_hint = Label.new()
    hud_hint.name = "LifeHint"
    hud_hint.position = Vector2(23, 635)
    hud_hint.add_theme_font_size_override("font_size", 22)
    hud_hint.add_theme_color_override("font_color", Color("#fcdb84"))
    hud_hint.add_theme_color_override("font_shadow_color", Color("#1a281d"))
    hud_hint.add_theme_constant_override("shadow_offset_x", 2)
    hud_hint.add_theme_constant_override("shadow_offset_y", 2)
    layer.add_child(hud_hint)

    hud_notice = Label.new()
    hud_notice.name = "LifeNotice"
    hud_notice.position = Vector2(23, 692)
    hud_notice.add_theme_font_size_override("font_size", 17)
    hud_notice.add_theme_color_override("font_color", Color("#f7f1e1"))
    hud_notice.add_theme_color_override("font_shadow_color", Color("#13251b"))
    hud_notice.add_theme_constant_override("shadow_offset_x", 2)
    hud_notice.add_theme_constant_override("shadow_offset_y", 2)
    layer.add_child(hud_notice)

    hud_thought = Label.new()
    hud_thought.name = "FarmerThought"
    hud_thought.position = Vector2(23, 580)
    hud_thought.add_theme_font_size_override("font_size", 21)
    hud_thought.add_theme_color_override("font_color", Color("#fff0b0"))
    hud_thought.add_theme_color_override("font_shadow_color", Color("#12241f"))
    hud_thought.add_theme_constant_override("shadow_offset_x", 2)
    hud_thought.add_theme_constant_override("shadow_offset_y", 2)
    layer.add_child(hud_thought)


func _add_interaction(title: String, at: Vector3, kind: String, distance: float = 2.7) -> void:
    interactions.append({"title": title, "at": at, "kind": kind, "distance": distance})


func _register_activities() -> void:
    _add_interaction("Ver objetivos da fazenda", Vector3(-7.0, 1.1, 8.5), "missions", 3.2)
    _add_interaction("Geladeira / preparar refeicao", Vector3(-12.95, 1.25, -16.3), "fridge")
    _add_interaction("Mesa / tomar cafe, almocar ou jantar", Vector3(-14.72, 1.0, -12.62), "eat")
    _add_interaction("Televisao", Vector3(-17.65, 1.4, -15.32), "tv")
    _add_interaction("Radio", Vector3(-14.48, 1.7, -16.68), "radio")
    _add_interaction("Dormir na suite", Vector3(-18.06, 3.7, -15.35), "sleep")
    _add_interaction("Notebook / rede da fazenda", Vector3(-14.5, 3.8, -16.6), "notebook")
    _add_interaction("Descansar na rede", Vector3(-12.2, 1.1, -8.4), "hammock")
    _add_interaction("Alimentar os animais", Vector3(19.3, 0.7, 21.9), "feed")
    _add_interaction("Colocar agua no curral", Vector3(22.0, 0.7, 18.0), "water")
    _add_interaction("Ordenhar a vaca", Vector3(15.6, 1.0, 17.9), "milk")
    _add_interaction("Coletar ovos", Vector3(20.3, 0.7, 15.5), "eggs")
    _add_interaction("Mini oficina / reparar carro", Vector3(-28.7, 1.0, -7.2), "repair")
    _add_interaction("Entrar e dirigir o carro", Vector3(-25, 1.0, -5), "car")
    _add_interaction("Vender colheita ou comprar suprimentos", Vector3(13, 1.1, 98.0), "market", 4.8)


func _process(delta: float) -> void:
    if not initialized:
        return
    # Sistema hibrido: o relogio avanca inclusive se o jogador estiver parado.
    # Atividades e deslocamentos tambem acrescentam tempo ao passar dos minutos.
    advance_minutes(delta * TimeRules.REALTIME_MINUTES_PER_SECOND)
    _measure_travel()
    save_tick += delta
    if save_tick > 30.0:
        _save_progress()
        save_tick = 0.0
    _update_hud()


func advance_activity(activity: String) -> void:
    advance_minutes(TimeRules.activity_minutes(activity))


func advance_minutes(amount: float) -> void:
    if not is_finite(amount) or amount <= 0.0:
        return
    # Almoco nao realizado: desgaste extra entre 12h e 16h30.
    var missed_lunch_cost := TimeRules.missed_lunch_energy_cost(minutes, amount, bool(meals.get("almoco", false)))
    minutes += amount
    var running := farmer != null and not driving and Input.is_action_pressed("sprint") and farmer.velocity.length() > 0.2
    var nighttime := minutes >= 1320.0 or minutes < 330.0
    var state: Dictionary = VitalRules.advance(hunger, energy, amount, running, nighttime)
    hunger = float(state["satiety"])
    energy = maxf(0.0, float(state["energy"]) - missed_lunch_cost)
    while minutes >= DAY_MINUTES:
        minutes -= DAY_MINUTES
        day += 1
        _daily_reset()
    _refresh_reminder()
    _update_light()


func movement_multiplier() -> float:
    return VitalRules.movement_multiplier(hunger, energy)


func _refresh_reminder() -> void:
    if hud_thought == null:
        return
    if reminder_day != day:
        reminder_day = day
        last_reminder_id = ""
    var current: Dictionary = Schedule.current_prompt(minutes, meals, cow_fed, animals_watered, energy)
    if current.is_empty():
        hud_thought.text = ""
        last_reminder_id = ""
        return
    var key := String(current["id"])
    var phrase := String(current["text"])
    hud_thought.text = "Pensamento: " + phrase
    if key != last_reminder_id:
        last_reminder_id = key
        _announce(phrase)


func _measure_travel() -> void:
    var current := car.global_position if driving and car != null else farmer.global_position
    var distance := current.distance_to(last_travel_position)
    last_travel_position = current
    # Pulos de posicao (teleportes, carregamento) nao consomem tempo.
    if distance <= 0.0 or distance > 25.0:
        return
    advance_minutes(TimeRules.travel_minutes(distance, driving))


func _reset_travel_position() -> void:
    last_travel_position = car.global_position if driving and car != null else farmer.global_position


func _physics_process(delta: float) -> void:
    if not initialized or not driving or car == null:
        return
    var accelerator := Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
    var steering := Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
    var speed := 12.0 * clampf(car_condition / 100.0, 0.2, 1.0)
    if absf(accelerator) > 0.05:
        car.rotate_y(steering * delta * 0.85 * signf(accelerator))
        car_condition = maxf(0.0, car_condition - delta * 0.006)
    car.velocity = -car.global_transform.basis.z * accelerator * speed
    car.move_and_slide()
    farmer.global_position = car.global_position + Vector3(0, 1.05, 0)
    farmer.rotation.y = car.rotation.y


func _unhandled_key_input(event: InputEvent) -> void:
    if not initialized or not (event is InputEventKey):
        return
    var key_event := event as InputEventKey
    if key_event.pressed and not key_event.echo and key_event.physical_keycode == KEY_E:
        _interact()


func _closest() -> Dictionary:
    if driving:
        return {"title": "Sair do carro", "kind": "exit_car"}
    var found: Dictionary = {}
    var best := INF
    for item in interactions:
        var distance: float = farmer.global_position.distance_to(item["at"])
        if distance <= float(item["distance"]) and distance < best:
            found = item
            best = distance
    if farm_system != null:
        var farm_prompt: Dictionary = farm_system.call("get_nearby_prompt", farmer.global_position)
        if not farm_prompt.is_empty() and float(farm_prompt["distance"]) < best:
            found = farm_prompt
    return found


func _interact() -> void:
    var target := _closest()
    if target.is_empty():
        _announce("Aproxime-se de um objeto para interagir.")
        return
    match String(target["kind"]):
        "missions":
            _announce("OBJETIVO: " + current_mission_text())
        "farm":
            if farm_system != null:
                var message: String = String(farm_system.call("interact", int(target["plot_index"])))
                _announce(message)
                if message.contains("plantado!"):
                    advance_activity("plantar")
                    _award_experience(2)
                elif message.begins_with("Canteiro regado!"):
                    advance_activity("regar")
                    _award_experience(1)
                elif message.begins_with("Colheu "):
                    advance_activity("colher")
                    _award_experience(10)
                    mission_stats["harvested"] = int(mission_stats.get("harvested", 0)) + 3
        "fridge":
            if food < 1:
                _announce("Geladeira vazia! Compre mantimentos na venda da vila.")
            else:
                ready_meal = true
                advance_activity("preparar_refeicao")
                _announce("Geladeira aberta: ingredientes separados. Va ate a mesa para comer.")
        "eat":
            _have_meal()
        "tv":
            tv_on = not tv_on
            if tv_on:
                advance_activity("assistir_tv")
            _announce("TV ligada: canal rural do jogo (tela demonstrativa)." if tv_on else "TV desligada.")
        "radio":
            radio_on = not radio_on
            _announce("Radio ligado: interface demonstrativa, audio ainda nao implementado." if radio_on else "Radio desligado.")
        "notebook":
            notebook_on = not notebook_on
            if notebook_on:
                advance_activity("usar_notebook")
            _announce("Notebook: rede ficticia da fazenda. Dia %d, hora %s, estoque %d alimentos." % [day, _time_string(), food] if notebook_on else "Notebook desligado.")
        "sleep":
            _sleep()
        "hammock":
            advance_activity("descansar_rede")
            energy = minf(100.0, energy + 18.0)
            _announce("Descansou na rede por 45 minutos. Energia recuperada.")
        "feed":
            if cow_fed:
                _announce("Animais ja receberam racao hoje.")
            elif feed < 1:
                _announce("Racao acabou. Compre na vila.")
            else:
                feed -= 1
                cow_fed = true
                advance_activity("alimentar_animais")
                _award_experience(6)
                _announce("Voce alimentou a vaca e as galinhas. +bem-estar.")
        "water":
            if animals_watered:
                _announce("Bebedouros ja foram abastecidos hoje.")
            else:
                animals_watered = true
                advance_activity("colocar_agua")
                _award_experience(4)
                _announce("Agua limpa distribuida no curral e galinheiro.")
        "milk":
            if cow_milked:
                _announce("A vaca ja foi ordenhada hoje.")
            elif not cow_fed or not animals_watered:
                _announce("Primeiro alimente os animais e encha os bebedouros.")
            else:
                milk += 2
                cow_milked = true
                coins += 12
                advance_activity("ordenhar")
                _award_experience(10)
                mission_stats["milk"] = int(mission_stats.get("milk", 0)) + 2
                _announce("Ordenha concluida: +2 leite, +R$ 12 pela venda automatica.")
        "eggs":
            if eggs_collected:
                _announce("Ovos ja recolhidos hoje.")
            elif not cow_fed or not animals_watered:
                _announce("Primeiro alimente as galinhas e coloque agua.")
            else:
                eggs += 3
                eggs_collected = true
                coins += 9
                advance_activity("recolher_ovos")
                _award_experience(8)
                mission_stats["eggs"] = int(mission_stats.get("eggs", 0)) + 3
                _announce("Coletou 3 ovos e recebeu R$ 9 pela venda automatica.")
        "repair":
            if coins < 20:
                _announce("Manutencao requer R$ 20.")
            elif car_condition >= 99.9:
                _announce("Carro ja esta em boas condicoes.")
            else:
                coins -= 20
                car_condition = 100.0
                advance_activity("reparar_carro")
                _award_experience(6)
                _announce("Carro revisado na oficina. Condicao 100%.")
        "car":
            _enter_car()
        "exit_car":
            _exit_car()
        "market":
            if harvested > 0:
                var sold := harvested
                coins += sold * 5
                harvested = 0
                advance_activity("mercado")
                _award_experience(3)
                mission_stats["sold"] = int(mission_stats.get("sold", 0)) + sold
                _announce("Vendeu %d produtos da horta por R$ %d! E novamente para comprar." % [sold, sold * 5])
            elif coins < 30:
                _announce("O kit com comida, racao e sementes custa R$ 30.")
            else:
                coins -= 30
                food += 4
                feed += 3
                seeds += 8
                advance_activity("mercado")
                _announce("Comprou +4 mantimentos, +3 racoes e +8 sementes por R$ 30.")
    _review_missions()
    _refresh_devices()
    _save_progress()


func _award_experience(points: int) -> void:
    # Progressao inicial ate o nivel 30: tarefas da fazenda rendem experiencia.
    if points <= 0:
        return
    experience += points
    while level < 30 and experience >= level * 50:
        experience -= level * 50
        level += 1
        coins += level * 5
    if level >= 30:
        experience = mini(experience, level * 50)


func current_mission_text() -> String:
    return Missions.describe(mission_stats, mission_completed)


func _review_missions() -> void:
    var newly_completed := false
    for goal in Missions.GOALS:
        var key := String(goal["key"])
        if key in mission_completed:
            continue
        if int(mission_stats.get(goal["stat"], 0)) < int(goal["target"]):
            continue
        mission_completed.append(key)
        newly_completed = true
        coins += int(goal["coins"])
        _award_experience(int(goal["xp"]))
        _announce("Objetivo completo: %s! +R$ %d e +%d XP." % [goal["title"], int(goal["coins"]), int(goal["xp"])])
    if not campaign_finished and Missions.completed(mission_stats, mission_completed):
        campaign_finished = true
        _announce("PARABENS! VOCE CONCLUIU A CAMPANHA DA FAZENDA! O modo livre continua.")
        _save_progress()
        campaign_won.emit()
    elif newly_completed:
        _save_progress()


func _meal_name() -> String:
    if minutes >= 330.0 and minutes < 660.0:
        return "cafe"
    if minutes >= 660.0 and minutes < 1020.0:
        return "almoco"
    return "jantar"


func _have_meal() -> void:
    var meal := _meal_name()
    if bool(meals.get(meal, false)):
        _announce("Voce ja fez esta refeicao hoje.")
    elif not ready_meal:
        _announce("Pegue ingredientes na geladeira antes de sentar a mesa.")
    elif food < 1:
        _announce("Nao ha ingredientes suficientes.")
    else:
        food -= 1
        ready_meal = false
        meals[meal] = true
        hunger = minf(100.0, hunger + 45.0)
        energy = minf(100.0, energy + 7.0)
        advance_activity(TimeRules.meal_activity(meal))
        _award_experience(3)
        _announce("Refeicao realizada: %s. Saciedade +45, energia +7." % meal.capitalize())


func _sleep() -> void:
    driving = false
    # Dormir ate 06:30 sempre avanca ao dia seguinte.
    day += 1
    minutes = 390.0
    _daily_reset()
    _reset_travel_position()
    _refresh_reminder()
    hunger = maxf(35.0, hunger - 10.0)
    energy = 100.0
    _announce("Bom dia! O fazendeiro dormiu e acordou as 06:30.")
    _update_light()


func _daily_reset() -> void:
    # Um dia conta no objetivo de cuidados apenas se ração e agua foram dadas.
    if cow_fed and animals_watered:
        mission_stats["animal_days"] = int(mission_stats.get("animal_days", 0)) + 1
    mission_stats["days"] = maxi(int(mission_stats.get("days", 0)), day - 1)
    _review_missions()
    if farm_system != null:
        farm_system.call("advance_day", _rain_on_day(day - 1))
    cow_fed = false
    animals_watered = false
    cow_milked = false
    eggs_collected = false
    meals = {"cafe": false, "almoco": false, "jantar": false}
    ready_meal = false
    last_reminder_id = ""


func _enter_car() -> void:
    if car_condition < 10.0:
        _announce("Carro precisa de reparo na oficina.")
        return
    driving = true
    _reset_travel_position()
    farmer.set_physics_process(false)
    var visuals := farmer.get_node_or_null("Visuals") as Node3D
    if visuals != null:
        visuals.visible = false
    _announce("Carro ligado. WASD dirige; pressione E para sair.")


func _exit_car() -> void:
    driving = false
    var offset := car.global_transform.basis.x * 2.2
    farmer.global_position = car.global_position + offset + Vector3(0, 0.8, 0)
    _reset_travel_position()
    farmer.set_physics_process(true)
    var visuals := farmer.get_node_or_null("Visuals") as Node3D
    if visuals != null:
        visuals.visible = true
    _announce("Voce saiu do carro.")


func _refresh_devices() -> void:
    if tv_screen != null:
        tv_screen.material_override = _make_mat(Color("#5d9cb7") if tv_on else Color("#23272f"))
    if radio_indicator != null:
        radio_indicator.material_override = _make_mat(Color("#d0e78c") if radio_on else Color("#485157"))
    if notebook_screen != null:
        notebook_screen.material_override = _make_mat(Color("#73c2dc") if notebook_on else Color("#28333e"))


func _time_string() -> String:
    var total := int(minutes) % 1440
    return "%02d:%02d" % [int(total / 60), total % 60]


func _update_light() -> void:
    # Light begins at dawn; at 06:30 the farm is visibly sunlit instead
    # of looking like midnight. Keep evenings and night clearly distinct.
    var phase := sin((minutes / DAY_MINUTES - 0.25) * TAU)
    var daylight := clampf(phase * 2.0 + 0.45, 0.0, 1.0)
    var dawn := clampf(1.0 - absf(minutes - 390.0) / 190.0, 0.0, 1.0)
    var dusk := clampf(1.0 - absf(minutes - 1110.0) / 190.0, 0.0, 1.0)
    var golden := maxf(dawn, dusk)
    var sun := get_parent().get_node_or_null("Sun") as DirectionalLight3D
    if sun != null:
        sun.light_energy = 0.10 + daylight * 0.83
        sun.light_color = Color("#fff0d6").lerp(Color("#eab277"), golden * 0.58)
        sun.rotation_degrees = Vector3(-15.0 - daylight * 47.0, -34.0, 0)
    var environment := get_parent().get_node_or_null("WorldEnvironment") as WorldEnvironment
    if environment != null and environment.environment != null:
        var env := environment.environment
        env.ambient_light_color = Color("#48516e").lerp(Color("#eadfc9"), daylight)
        env.ambient_light_energy = 0.19 + daylight * 0.30
        # Updating a ProceduralSkyMaterial can rebuild the sky texture. Keep
        # that expensive work to one update per five in-game minutes.
        var sky_step := int(minutes / 5.0)
        if sky_step != last_sky_step and env.sky != null and env.sky.sky_material is ProceduralSkyMaterial:
            last_sky_step = sky_step
            var sky_material := env.sky.sky_material as ProceduralSkyMaterial
            sky_material.sky_top_color = Color("#1f385a").lerp(Color("#5baad2"), daylight)
            sky_material.sky_horizon_color = Color("#57627b").lerp(Color("#deebec"), daylight).lerp(Color("#f6c99e"), golden * 0.26)
            sky_material.ground_horizon_color = Color("#414758").lerp(Color("#c8d4bf"), daylight)
            sky_material.ground_bottom_color = Color("#28322d").lerp(Color("#536d45"), daylight)


func _rain_on_day(day_number: int) -> bool:
    return day_number > 0 and day_number % 5 == 0


func _season() -> String:
    var names := ["Primavera", "Verao", "Outono", "Inverno"]
    return names[int((day - 1) / 7) % 4]


func _weather_label() -> String:
    if _rain_on_day(day):
        return "Chuva"
    if day % 4 == 0:
        return "Nublado"
    return "Sol"


func _update_hud() -> void:
    var ready := 0
    var tool := "Plantar"
    var crop := "Cenoura"
    if farm_system != null:
        ready = int(farm_system.call("crops_ready"))
        tool = String(farm_system.call("tool_name"))
        crop = String(farm_system.call("seed_name"))
    hud_stats.text = "TEMPO POR ATIVIDADES | DIA %d  |  %s  |  %s  |  %s  |  R$ %d\nSaciedade: %d%%   Energia: %d%%\nComida: %d  Racao: %d  Sementes: %d\nColhidos: %d  Prontos: %d  Ovos: %d  Leite: %d\nFerramenta: %s  |  Cultura: %s  (F/G)\nCafe: %s  Almoco: %s  Janta: %s\nAnimais alimentados: %s  Agua: %s\nCarro: %d%%  |  Nivel %d  XP %d/%d\nObjetivo: %s" % [
        day, _time_string(), _season(), _weather_label(), coins,
        int(hunger), int(energy),
        food, feed, seeds, harvested, ready, eggs, milk,
        tool, crop,
        "ok" if meals["cafe"] else "-", "ok" if meals["almoco"] else "-", "ok" if meals["jantar"] else "-",
        "sim" if cow_fed else "nao", "sim" if animals_watered else "nao",
        int(car_condition), level, experience, level * 50, current_mission_text()
    ]
    var next := _closest()
    hud_hint.text = ("E — " + String(next["title"])) if not next.is_empty() else "Explore e trabalhe na fazenda: E interagir | F ferramenta | G semente."


func _announce(message: String) -> void:
    if hud_notice != null:
        hud_notice.text = message


func _save_progress() -> void:
    var payload := {
        "version": 1, "day": day, "minutes": minutes, "hunger": hunger,
        "energy": energy, "coins": coins, "food": food, "feed": feed,
        "level": level, "experience": experience,
        "mission_stats": mission_stats, "mission_completed": mission_completed, "campaign_finished": campaign_finished,
        "seeds": seeds, "harvested": harvested,
        "farming": farm_system.call("serialize") if farm_system != null else [],
        "eggs": eggs, "milk": milk, "car_condition": car_condition,
        "cow_fed": cow_fed, "animals_watered": animals_watered,
        "cow_milked": cow_milked, "eggs_collected": eggs_collected,
        "meals": meals, "ready_meal": ready_meal,
        "car_pos": [car.global_position.x, car.global_position.y, car.global_position.z],
        "car_rot": car.rotation.y,
        "farmer_pos": [farmer.global_position.x, farmer.global_position.y, farmer.global_position.z],
        "farmer_rot": farmer.rotation.y
    }
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file != null:
        file.store_string(JSON.stringify(payload))


func _load_progress() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return
    var decoded: Variant = JSON.parse_string(file.get_as_text())
    if typeof(decoded) != TYPE_DICTIONARY:
        return
    var data: Dictionary = decoded
    if int(data.get("version", 0)) != 1:
        return
    day = maxi(1, int(data.get("day", day)))
    minutes = clampf(float(data.get("minutes", minutes)), 0.0, 1439.0)
    hunger = clampf(float(data.get("hunger", hunger)), 0.0, 100.0)
    energy = clampf(float(data.get("energy", energy)), 0.0, 100.0)
    coins = maxi(0, int(data.get("coins", coins)))
    level = clampi(int(data.get("level", level)), 1, 30)
    experience = clampi(int(data.get("experience", experience)), 0, level * 50)
    var stored_stats: Variant = data.get("mission_stats", {})
    if typeof(stored_stats) == TYPE_DICTIONARY:
        for key in mission_stats.keys():
            mission_stats[key] = maxi(0, int(stored_stats.get(key, 0)))
    var stored_completed: Variant = data.get("mission_completed", [])
    if typeof(stored_completed) == TYPE_ARRAY:
        # Ignore unknown/duplicate entries; a partial or modified save must not
        # create a false victory or hide remaining objectives.
        for goal in Missions.GOALS:
            var key := String(goal["key"])
            if key in stored_completed:
                mission_completed.append(key)
    campaign_finished = Missions.completed(mission_stats, mission_completed)
    food = maxi(0, int(data.get("food", food)))
    feed = maxi(0, int(data.get("feed", feed)))
    seeds = maxi(0, int(data.get("seeds", seeds)))
    harvested = maxi(0, int(data.get("harvested", harvested)))
    eggs = maxi(0, int(data.get("eggs", eggs)))
    milk = maxi(0, int(data.get("milk", milk)))
    car_condition = clampf(float(data.get("car_condition", car_condition)), 0.0, 100.0)
    cow_fed = bool(data.get("cow_fed", cow_fed))
    animals_watered = bool(data.get("animals_watered", animals_watered))
    cow_milked = bool(data.get("cow_milked", cow_milked))
    eggs_collected = bool(data.get("eggs_collected", eggs_collected))
    ready_meal = bool(data.get("ready_meal", ready_meal))
    var loaded_meals: Variant = data.get("meals", {})
    if typeof(loaded_meals) == TYPE_DICTIONARY:
        for key in ["cafe", "almoco", "jantar"]:
            meals[key] = bool(loaded_meals.get(key, false))
    var car_pos: Variant = data.get("car_pos", [])
    if typeof(car_pos) == TYPE_ARRAY and car_pos.size() == 3:
        car.global_position = Vector3(float(car_pos[0]), float(car_pos[1]), float(car_pos[2]))
    car.rotation.y = float(data.get("car_rot", car.rotation.y))
    # Saves antigos continuam validos mesmo sem posicao do fazendeiro.
    var saved_farmer_position: Variant = data.get("farmer_pos", [])
    if farmer != null and typeof(saved_farmer_position) == TYPE_ARRAY and saved_farmer_position.size() == 3:
        var restored_position := Vector3(float(saved_farmer_position[0]), float(saved_farmer_position[1]), float(saved_farmer_position[2]))
        if is_finite(restored_position.x) and is_finite(restored_position.y) and is_finite(restored_position.z) and restored_position.length() < 20000.0:
            farmer.global_position = restored_position
            last_travel_position = restored_position
    if farmer != null:
        var restored_yaw := float(data.get("farmer_rot", farmer.rotation.y))
        if is_finite(restored_yaw):
            farmer.rotation.y = restored_yaw
    if farm_system != null:
        farm_system.call("restore", data.get("farming", []))
