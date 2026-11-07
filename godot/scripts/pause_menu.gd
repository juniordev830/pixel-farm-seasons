extends CanvasLayer
## Menu de pausa do prototipo 3D. P abre/fecha e salva a partida ao abrir.
## Roda mesmo com SceneTree pausada para permitir retorno pelo teclado.
var backdrop: ColorRect
var resume_button: Button


func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    layer = 20
    _build_menu()
    visible = false


func _build_menu() -> void:
    backdrop = ColorRect.new()
    backdrop.name = "Backdrop"
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    backdrop.color = Color(0.035, 0.065, 0.065, 0.89)
    backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(backdrop)

    var centered := CenterContainer.new()
    centered.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    backdrop.add_child(centered)

    var panel := PanelContainer.new()
    panel.custom_minimum_size = Vector2(460.0, 360.0)
    centered.add_child(panel)

    var padding := MarginContainer.new()
    padding.add_theme_constant_override("margin_left", 25)
    padding.add_theme_constant_override("margin_top", 25)
    padding.add_theme_constant_override("margin_right", 25)
    padding.add_theme_constant_override("margin_bottom", 25)
    panel.add_child(padding)

    var stack := VBoxContainer.new()
    stack.add_theme_constant_override("separation", 13)
    padding.add_child(stack)

    var heading := Label.new()
    heading.text = "PIXEL FARM SEASONS"
    heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    heading.add_theme_font_size_override("font_size", 27)
    stack.add_child(heading)

    var sub := Label.new()
    sub.text = "JOGO PAUSADO"
    sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    sub.add_theme_font_size_override("font_size", 19)
    stack.add_child(sub)

    var help := Label.new()
    help.text = "WASD: andar / dirigir    Mouse: camera\nShift: correr   Espaco: pular\nE: interagir    F: ferramenta    G: semente\nP: pausar/continuar"
    help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    stack.add_child(help)

    resume_button = Button.new()
    resume_button.name = "Resume"
    resume_button.text = "CONTINUAR JOGANDO (P)"
    resume_button.pressed.connect(resume_game)
    stack.add_child(resume_button)

    var save_button := Button.new()
    save_button.name = "Save"
    save_button.text = "SALVAR PARTIDA"
    save_button.pressed.connect(save_game)
    stack.add_child(save_button)


func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_P:
        toggle_pause()
        get_viewport().set_input_as_handled()


func toggle_pause() -> void:
    if get_tree().paused:
        resume_game()
    else:
        pause_game()


func pause_game() -> void:
    save_game()
    visible = true
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    get_tree().paused = true


func resume_game() -> void:
    get_tree().paused = false
    visible = false
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func save_game() -> void:
    var life := get_parent().get_node_or_null("LifeSim")
    if life != null and bool(life.get("initialized")):
        life.call("_save_progress")


func _exit_tree() -> void:
    if get_tree().paused:
        get_tree().paused = false
