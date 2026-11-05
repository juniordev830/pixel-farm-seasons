extends CanvasLayer
## Prototype HUD for the 3D farm. Values are placeholders except the game clock.
var clock_label: Label
var status_label: Label
var message_label: Label

func _ready() -> void:
    var root := Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(root)

    var top := PanelContainer.new()
    top.position = Vector2(16, 16)
    top.custom_minimum_size = Vector2(290, 0)
    root.add_child(top)
    var stats := VBoxContainer.new()
    top.add_child(stats)
    var heading := Label.new()
    heading.text = "🌾 PIXEL FARM SEASONS"
    heading.add_theme_font_size_override("font_size", 22)
    stats.add_child(heading)
    status_label = Label.new()
    status_label.text = "Vida 100  |  Energia 100  |  Fome 0"
    stats.add_child(status_label)
    var objective := Label.new()
    objective.text = "Objetivo: explorar a fazenda"
    stats.add_child(objective)
    message_label = Label.new()
    message_label.text = ""
    stats.add_child(message_label)

    var right := PanelContainer.new()
    right.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    right.offset_left = -240
    right.offset_right = -16
    right.offset_top = 16
    root.add_child(right)
    clock_label = Label.new()
    clock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    right.add_child(clock_label)

    var help := PanelContainer.new()
    help.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
    help.offset_left = -270
    help.offset_right = -16
    help.offset_top = -118
    help.offset_bottom = -16
    root.add_child(help)
    var controls := Label.new()
    controls.text = "WASD / Setas: andar\nShift: correr   Espaço: pular\nMouse: câmera   E: interagir"
    help.add_child(controls)

func _process(_delta: float) -> void:
    var controller := get_node_or_null("../DayNightController")
    if controller != null and controller.has_method("get_clock"):
        clock_label.text = "🍂 Outono  |  " + controller.get_clock()
    var needs := get_node_or_null("../FarmerNeeds")
    if needs != null:
        status_label.text = "Energia %d  |  Fome %d" % [int(needs.energy), int(needs.hunger)]
        message_label.text = needs.message
