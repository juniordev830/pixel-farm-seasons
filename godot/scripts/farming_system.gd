extends Node3D
## Horta interativa: 30 canteiros, 3 culturas, rega, crescimento e colheita.
## Controles: E interage; F alterna ferramenta; G alterna semente.
## Sistema independente do prototipo web. Nao utiliza assets externos.

const ROWS := 5
const COLS := 6
const MAX_GROWTH := 3
const CROPS := ["Cenoura", "Milho", "Tomate"]
const TOOLS := ["Plantar", "Regar", "Colher"]
const SOIL_WET := Color("#483427")

var life: Node3D
var plots: Array[Dictionary] = []
var visuals: Array[Node3D] = []
var tool_index := 0
var seed_type := 0
var initialized := false


func _ready() -> void:
    # LifeSim invoca ensure_initialized antes de restaurar o progresso.
    call_deferred("ensure_initialized")


func ensure_initialized() -> void:
    if initialized:
        return
    life = get_parent().get_node_or_null("LifeSim")
    for row in range(ROWS):
        for col in range(COLS):
            var x := 7.5 + float(col) * 1.58
            var z := 1.45 + float(row) * 1.85
            var slot := Node3D.new()
            slot.name = "Horta_%02d_%02d" % [row + 1, col + 1]
            slot.position = Vector3(x, 0, z)
            add_child(slot)
            visuals.append(slot)
            plots.append({"planted": false, "growth": 0, "watered": false, "crop": 0})
    initialized = true
    for i in range(plots.size()):
        _render_plot(i)


func _unhandled_key_input(event: InputEvent) -> void:
    if not initialized or life == null or not event is InputEventKey:
        return
    var key := event as InputEventKey
    if not key.pressed or key.echo or bool(life.get("driving")):
        return
    match key.physical_keycode:
        KEY_F:
            tool_index = (tool_index + 1) % TOOLS.size()
            life.call("_announce", "Ferramenta selecionada: %s (F para alternar)." % TOOLS[tool_index])
        KEY_G:
            seed_type = (seed_type + 1) % CROPS.size()
            life.call("_announce", "Semente selecionada: %s (G para alternar)." % CROPS[seed_type])


func tool_name() -> String:
    return TOOLS[tool_index]


func seed_name() -> String:
    return CROPS[seed_type]


func crops_ready() -> int:
    var total := 0
    for plot in plots:
        if bool(plot["planted"]) and int(plot["growth"]) >= MAX_GROWTH:
            total += 1
    return total


func get_nearby_prompt(player_pos: Vector3) -> Dictionary:
    if not initialized:
        return {}
    var choice := -1
    var shortest := 2.25
    for i in range(plots.size()):
        var p := visuals[i].global_position + Vector3(0, 0.75, 0)
        var dst := player_pos.distance_to(p)
        if dst < shortest:
            choice = i
            shortest = dst
    if choice == -1:
        return {}
    var label := ""
    var crop: Dictionary = plots[choice]
    match tool_index:
        0:
            label = "Plantar %s no canteiro %d" % [CROPS[seed_type], choice + 1]
        1:
            label = "Regar canteiro %d" % (choice + 1)
        2:
            label = "Colher canteiro %d" % (choice + 1)
    if bool(crop["planted"]) and tool_index == 2 and int(crop["growth"]) >= MAX_GROWTH:
        label += " (maduro)"
    return {"title": label, "kind": "farm", "plot_index": choice, "distance": shortest}


func interact(index: int) -> String:
    if index < 0 or index >= plots.size() or life == null:
        return "Canteiro indisponivel."
    var plot: Dictionary = plots[index]
    match tool_index:
        0:
            if bool(plot["planted"]):
                return "Este canteiro ja tem %s. Regue ou aguarde a colheita." % CROPS[int(plot["crop"])]
            var seeds := int(life.get("seeds"))
            if seeds <= 0:
                return "Sementes esgotadas! Va ate o mercado rural."
            life.set("seeds", seeds - 1)
            plot["planted"] = true
            plot["crop"] = seed_type
            plot["growth"] = 0
            plot["watered"] = false
            _render_plot(index)
            return "%s plantado! Selecione Regar com F e pressione E." % CROPS[seed_type]
        1:
            if not bool(plot["planted"]):
                return "Nao ha planta aqui. Selecione Plantar com F."
            if int(plot["growth"]) >= MAX_GROWTH:
                return "Esta planta esta madura. Selecione Colher com F."
            if bool(plot["watered"]):
                return "Este canteiro ja foi regado hoje."
            plot["watered"] = true
            _render_plot(index)
            return "Canteiro regado! A planta cresce ao fim do dia."
        2:
            if not bool(plot["planted"]):
                return "Terreno vazio. Nada para colher."
            if int(plot["growth"]) < MAX_GROWTH:
                return "Ainda falta crescer: %d de %d dias regados." % [int(plot["growth"]), MAX_GROWTH]
            var harvested := int(life.get("harvested"))
            life.set("harvested", harvested + 3)
            var crop_label: String = CROPS[int(plot["crop"])]
            plot["planted"] = false
            plot["growth"] = 0
            plot["watered"] = false
            _render_plot(index)
            return "Colheu 3 unidades de %s! Venda no mercado da vila." % crop_label
    return ""


func advance_day(rainy: bool) -> void:
    if not initialized:
        return
    for i in range(plots.size()):
        var plot: Dictionary = plots[i]
        if not bool(plot["planted"]):
            continue
        if (bool(plot["watered"]) or rainy) and int(plot["growth"]) < MAX_GROWTH:
            plot["growth"] = int(plot["growth"]) + 1
        plot["watered"] = false
        _render_plot(i)


func serialize() -> Array:
    var out: Array = []
    for plot in plots:
        out.append(plot.duplicate(true))
    return out


func restore(data: Variant) -> void:
    ensure_initialized()
    if typeof(data) != TYPE_ARRAY or data.size() != ROWS * COLS:
        return
    for i in range(data.size()):
        var entry: Variant = data[i]
        if typeof(entry) != TYPE_DICTIONARY:
            continue
        var c := int(entry.get("crop", 0))
        var stage := int(entry.get("growth", 0))
        if c < 0 or c >= CROPS.size() or stage < 0 or stage > MAX_GROWTH:
            continue
        plots[i] = {
            "planted": bool(entry.get("planted", false)),
            "growth": stage,
            "watered": bool(entry.get("watered", false)),
            "crop": c
        }
        _render_plot(i)


func _mat(tint: Color) -> StandardMaterial3D:
    var result := StandardMaterial3D.new()
    result.albedo_color = tint
    result.roughness = 0.9
    return result


func _box(parent: Node3D, at: Vector3, size: Vector3, tint: Color) -> void:
    var node := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.position = at
    node.material_override = _mat(tint)
    parent.add_child(node)


func _ball(parent: Node3D, at: Vector3, size: Vector3, tint: Color) -> void:
    var node := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = 0.5
    mesh.height = 1.0
    mesh.radial_segments = 9
    mesh.rings = 5
    node.mesh = mesh
    node.position = at
    node.scale = size
    node.material_override = _mat(tint)
    parent.add_child(node)


func _render_plot(index: int) -> void:
    var slot := visuals[index]
    for child in slot.get_children():
        child.free()
    var state: Dictionary = plots[index]
    if bool(state["watered"]):
        _box(slot, Vector3(0, 0.194, 0), Vector3(1.20, 0.018, 1.4), SOIL_WET)
    if not bool(state["planted"]):
        return
    var stage := int(state["growth"])
    var crop := int(state["crop"])
    var size_factor := 0.45 + float(stage) * 0.25
    match crop:
        0:
            _box(slot, Vector3(0, 0.25 + size_factor * 0.34, 0), Vector3(0.11, size_factor * 0.65, 0.11), Color("#487d3c"))
            _ball(slot, Vector3(-0.18, 0.35 + size_factor * 0.55, 0), Vector3(size_factor * 0.48, 0.18, 0.20), Color("#70a44f"))
            _ball(slot, Vector3(0.17, 0.42 + size_factor * 0.54, 0), Vector3(size_factor * 0.53, 0.16, 0.23), Color("#5f9e4b"))
            if stage == MAX_GROWTH:
                _ball(slot, Vector3(0, 0.34, 0.1), Vector3(0.30, 0.42, 0.29), Color("#ec8439"))
        1:
            _box(slot, Vector3(0, 0.25 + size_factor * 0.67, 0), Vector3(0.15, size_factor * 1.32, 0.15), Color("#5d9c42"))
            _ball(slot, Vector3(-0.19, 0.42 + size_factor * 0.58, 0), Vector3(0.46, 0.16, 0.18), Color("#7aae54"))
            _ball(slot, Vector3(0.2, 0.55 + size_factor * 0.80, 0), Vector3(0.48, 0.16, 0.18), Color("#72a84f"))
            if stage >= 2:
                _ball(slot, Vector3(0.13, 0.52 + size_factor * 0.55, 0.09), Vector3(0.20, 0.43, 0.25), Color("#e4be5c"))
        2:
            _box(slot, Vector3(0, 0.30 + size_factor * 0.41, 0), Vector3(0.13, size_factor * 0.84, 0.13), Color("#3f8c43"))
            for n in range(4):
                var a := float(n) * TAU / 4.0
                _ball(slot, Vector3(cos(a) * 0.18, 0.55 + size_factor * 0.30, sin(a) * 0.18),
                    Vector3(size_factor * 0.34, 0.15, size_factor * 0.34), Color("#62a750"))
            if stage == MAX_GROWTH:
                for n in range(3):
                    var a := float(n) * TAU / 3.0
                    _ball(slot, Vector3(cos(a) * 0.21, 0.61 + float(n % 2) * 0.1, sin(a) * 0.21),
                        Vector3(0.24, 0.24, 0.24), Color("#cb4b40"))
