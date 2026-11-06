extends CanvasLayer
## Interface de jogo em cartoes para Pixel Farm Seasons.
## Somente apresenta dados da LifeSim; nao modifica a simulacao.
## HUD dinamica: dia, estacao, relogio, fome, energia, atividades, ferramentas.

const BG := Color(0.105, 0.145, 0.125, 0.91)
const BORDER := Color(0.64, 0.55, 0.34, 0.95)
const CREAM := Color("#fff1cd")
const MUTED := Color("#d1d8bd")
const ACCENT := Color("#f0be68")
const GOOD := Color("#72b873")
const WARNING := Color("#df9656")
const DANGER := Color("#d66557")

var life: Node3D
var root_control: Control
var header: Label
var subtitle: Label
var money: Label
var hunger_text: Label
var energy_text: Label
var hunger_bar: ProgressBar
var energy_bar: ProgressBar
var tasks: Label
var prompt: Label
var notice: Label
var inventory: Label
var tools: Label
var warning_label: Label
var refresh_elapsed := 0.0
var quick_slots: Array[PanelContainer] = []
var quick_labels: Array[Label] = []


func _ready() -> void:
    _build_ui()
    call_deferred("_link_simulation")


func _link_simulation() -> void:
    life = get_parent().get_node_or_null("LifeSim") as Node3D
    # Esconde a HUD textual provisoria, mas preserva suas propriedades para
    # que os sistemas existentes e os testes continuem funcionando.
    var old_layer := get_parent().get_node_or_null("HUD") as CanvasLayer
    if old_layer != null:
        var legacy_help := old_layer.get_node_or_null("Help") as Control
        if legacy_help != null:
            legacy_help.visible = false
        for node_name in ["LifeStats", "LifeHint", "LifeNotice", "FarmerThought"]:
            var old_label := old_layer.get_node_or_null(node_name) as Control
            if old_label != null:
                old_label.visible = false


func _panel(parent: Control, panel_name: String, at: Vector2, size: Vector2) -> PanelContainer:
    var panel := PanelContainer.new()
    panel.name = panel_name
    panel.position = at
    panel.custom_minimum_size = size
    var style := StyleBoxFlat.new()
    style.bg_color = BG
    style.border_color = BORDER
    style.set_border_width_all(2)
    style.set_corner_radius_all(13)
    style.content_margin_left = 12
    style.content_margin_top = 9
    style.content_margin_right = 12
    style.content_margin_bottom = 9
    panel.add_theme_stylebox_override("panel", style)
    panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(panel)
    return panel


func _text(parent: Control, name: String, value: String, font_size: int, color: Color) -> Label:
    var lbl := Label.new()
    lbl.name = name
    lbl.text = value
    lbl.add_theme_font_size_override("font_size", font_size)
    lbl.add_theme_color_override("font_color", color)
    lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(lbl)
    return lbl


func _stack(parent: Control, gap: int = 4) -> VBoxContainer:
    var stack := VBoxContainer.new()
    stack.add_theme_constant_override("separation", gap)
    stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(stack)
    return stack


func _bar(parent: Control, color: Color) -> ProgressBar:
    var progress := ProgressBar.new()
    progress.custom_minimum_size = Vector2(210, 15)
    progress.show_percentage = false
    progress.max_value = 100.0
    var empty_style := StyleBoxFlat.new()
    empty_style.bg_color = Color("#30372d")
    empty_style.set_corner_radius_all(6)
    var fill_style := StyleBoxFlat.new()
    fill_style.bg_color = color
    fill_style.set_corner_radius_all(6)
    progress.add_theme_stylebox_override("background", empty_style)
    progress.add_theme_stylebox_override("fill", fill_style)
    progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(progress)
    return progress


func _build_ui() -> void:
    root_control = Control.new()
    root_control.name = "CozyOverlay"
    root_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(root_control)

    var top_left := _panel(root_control, "Calendar", Vector2(20, 16), Vector2(255, 92))
    var left_stack := _stack(top_left, 2)
    header = _text(left_stack, "Season", "PIXEL FARM SEASONS", 21, ACCENT)
    subtitle = _text(left_stack, "DayClock", "Dia 1  |  06:30  |  Primavera", 16, CREAM)

    var top_right := _panel(root_control, "Money", Vector2(-240, 16), Vector2(220, 66))
    top_right.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    money = _text(_stack(top_right, 2), "MoneyValue", "R$ 180", 24, ACCENT)

    var status := _panel(root_control, "Needs", Vector2(20, 124), Vector2(235, 113))
    var needs_stack := _stack(status, 3)
    hunger_text = _text(needs_stack, "Hunger", "Saciedade 82%", 15, CREAM)
    hunger_bar = _bar(needs_stack, WARNING)
    energy_text = _text(needs_stack, "Energy", "Energia 96%", 15, CREAM)
    energy_bar = _bar(needs_stack, GOOD)

    var agenda := _panel(root_control, "Agenda", Vector2(-300, 98), Vector2(280, 284))
    agenda.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    var agenda_stack := _stack(agenda, 7)
    _text(agenda_stack, "AgendaTitle", "ROTINA DA FAZENDA", 18, ACCENT)
    tasks = _text(agenda_stack, "AgendaTasks",
        "[ ] Cafe da manha\n[ ] Almoco\n[ ] Jantar\n[ ] Cuidar dos animais",
        16, CREAM)
    tasks.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    tasks.custom_minimum_size = Vector2(242, 0)

    var bottom_panel := _panel(root_control, "Inventory", Vector2(20, -126), Vector2(490, 105))
    bottom_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    var bottom_stack := _stack(bottom_panel, 4)
    _text(bottom_stack, "InventoryTitle", "MOCHILA E FERRAMENTAS", 16, ACCENT)
    inventory = _text(bottom_stack, "InventoryContents", "Sementes 12  |  Ovos 0  |  Leite 0", 15, CREAM)
    tools = _text(bottom_stack, "ToolContents", "F: Plantar  |  G: Cenoura", 15, MUTED)

    var center_bottom := _panel(root_control, "Interaction", Vector2(20, -210), Vector2(490, 76))
    center_bottom.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    var hint_stack := _stack(center_bottom, 4)
    prompt = _text(hint_stack, "Prompt", "E - interagir com objetos", 17, ACCENT)
    notice = _text(hint_stack, "Message", "Explore a fazenda e cuide dos animais.", 13, CREAM)
    prompt.clip_text = true
    notice.clip_text = true
    prompt.custom_minimum_size = Vector2(450, 0)
    notice.custom_minimum_size = Vector2(450, 0)

    var thought_panel := _panel(root_control, "Thought", Vector2(-490, -105), Vector2(465, 85))
    thought_panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
    warning_label = _text(_stack(thought_panel, 5), "FarmerThought",
        "Seu personagem tem horarios e pensamentos.", 17, CREAM)
    warning_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    warning_label.custom_minimum_size = Vector2(425, 55)
    _build_quickbar()


func _quick_style(selected: bool) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = Color("#293629") if selected else Color("#202d28")
    style.border_color = ACCENT if selected else Color("#788566")
    style.set_border_width_all(3 if selected else 1)
    style.set_corner_radius_all(11)
    style.content_margin_left = 7
    style.content_margin_top = 9
    style.content_margin_right = 7
    style.content_margin_bottom = 9
    return style


func _build_quickbar() -> void:
    # Compact toolbar inspired by the approved screenshot; F/G remain the
    # actual controls until direct numeric shortcuts are implemented.
    var width := get_viewport().get_visible_rect().size.x
    var height := get_viewport().get_visible_rect().size.y
    var row := HBoxContainer.new()
    row.name = "QuickTools"
    row.position = Vector2((width - 480.0) * 0.5, height - 92.0)
    row.mouse_filter = Control.MOUSE_FILTER_IGNORE
    row.add_theme_constant_override("separation", 6)
    root_control.add_child(row)
    for label in ["PLANTAR", "REGAR", "COLHER", "SEMENTES", "PRODUCAO", "OVOS"]:
        var slot := PanelContainer.new()
        slot.custom_minimum_size = Vector2(74, 67)
        slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
        slot.add_theme_stylebox_override("panel", _quick_style(false))
        row.add_child(slot)
        var text_node := Label.new()
        text_node.text = label
        text_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        text_node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        text_node.add_theme_font_size_override("font_size", 12)
        text_node.add_theme_color_override("font_color", CREAM)
        text_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
        slot.add_child(text_node)
        quick_slots.append(slot)
        quick_labels.append(text_node)
    var help := _text(root_control, "QuickToolsHelp", "F: trocar ferramenta   |   G: trocar semente   |   E: interagir", 13, CREAM)
    help.position = Vector2((width - 410.0) * 0.5, height - 116.0)


func _refresh_quickbar() -> void:
    if quick_labels.size() != 6 or life == null:
        return
    var farm := life.get("farm_system") as Node3D
    var selected := 0
    if farm != null:
        selected = int(farm.get("tool_index"))
    for i in range(3):
        quick_slots[i].add_theme_stylebox_override("panel", _quick_style(i == selected))
    quick_labels[0].text = "ENXADA\nPLANTAR"
    quick_labels[1].text = "REGADOR\nREGAR"
    quick_labels[2].text = "CESTO\nCOLHER"
    quick_labels[3].text = "SEMENTES\n%d" % int(life.get("seeds"))
    quick_labels[4].text = "COLHIDOS\n%d" % int(life.get("harvested"))
    quick_labels[5].text = "OVOS\n%d" % int(life.get("eggs"))


func _process(delta: float) -> void:
    refresh_elapsed += delta
    if refresh_elapsed < 0.2:
        return
    refresh_elapsed = 0.0
    if life == null:
        _link_simulation()
        return
    if not bool(life.get("initialized")):
        return
    _refresh_data()


func _refresh_data() -> void:
    var hunger := float(life.get("hunger"))
    var energy := float(life.get("energy"))
    var meals: Dictionary = life.get("meals")
    var day := int(life.get("day"))
    var cash := int(life.get("coins"))

    subtitle.text = "Dia %d  |  %s  |  %s" % [
        day, String(life.call("_time_string")), String(life.call("_season"))
    ]
    money.text = "R$ %d | Nv.%d" % [cash, int(life.get("level"))]

    hunger_text.text = "Saciedade  %d%%" % int(hunger)
    energy_text.text = "Energia  %d%%" % int(energy)
    hunger_bar.value = hunger
    energy_bar.value = energy
    _refresh_quickbar()

    var hunger_style := StyleBoxFlat.new()
    hunger_style.bg_color = DANGER if hunger < 30 else WARNING
    hunger_style.set_corner_radius_all(6)
    hunger_bar.add_theme_stylebox_override("fill", hunger_style)

    tasks.text = "%s  Cafe da manha\n%s  Almoco\n%s  Jantar\n%s  Alimentar animais\n%s  Abastecer bebedouros" % [
        "[x]" if bool(meals.get("cafe", false)) else "[ ]",
        "[x]" if bool(meals.get("almoco", false)) else "[ ]",
        "[x]" if bool(meals.get("jantar", false)) else "[ ]",
        "[x]" if bool(life.get("cow_fed")) else "[ ]",
        "[x]" if bool(life.get("animals_watered")) else "[ ]"
    ]
    tasks.text += "\n\nMISSAO: " + String(life.call("current_mission_text"))

    inventory.text = "Comida %d  |  Racao %d  |  Sementes %d  |  Ovos %d" % [
        int(life.get("food")), int(life.get("feed")),
        int(life.get("seeds")), int(life.get("eggs"))
    ]
    var farm := life.get("farm_system") as Node3D
    if farm != null:
        tools.text = "F: %s   |   G: %s   |   Colhidos: %d" % [
            String(farm.call("tool_name")),
            String(farm.call("seed_name")),
            int(life.get("harvested"))
        ]

    var old_layer := get_parent().get_node_or_null("HUD") as CanvasLayer
    if old_layer != null:
        # O HUD antigo continua como fonte de texto, mas nao deve se sobrepor ao HUD novo.
        for old_name in ["Help", "LifeStats", "LifeHint", "LifeNotice", "FarmerThought"]:
            var old_widget := old_layer.get_node_or_null(old_name) as CanvasItem
            if old_widget != null:
                old_widget.hide()
        var hint := old_layer.get_node_or_null("LifeHint") as Label
        if hint != null:
            prompt.text = hint.text
        var message := old_layer.get_node_or_null("LifeNotice") as Label
        if message != null:
            notice.text = message.text
        var thought := old_layer.get_node_or_null("FarmerThought") as Label
        if thought != null and not thought.text.is_empty():
            warning_label.text = thought.text
        elif hunger < 28.0:
            warning_label.text = "Estou com muita fome. Melhor fazer uma refeicao!"
        else:
            warning_label.text = "Regue a horta, cuide dos animais e explore o sitio."
