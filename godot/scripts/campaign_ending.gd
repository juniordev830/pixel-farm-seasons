extends CanvasLayer
## Encerramento da campanha. Jogador pode continuar no modo livre ou voltar ao menu.
const MENU_SCENE := "res://scenes/main_menu.tscn"

var backdrop: ColorRect
var free_play_button: Button


func _ready() -> void:
    layer = 30
    process_mode = Node.PROCESS_MODE_ALWAYS
    _build_screen()
    visible = false
    var life := get_parent().get_node_or_null("LifeSim")
    if life != null:
        life.connect("campaign_won", Callable(self, "show_victory"))


func _build_screen() -> void:
    backdrop = ColorRect.new()
    backdrop.name = "Backdrop"
    backdrop.color = Color(0.03, 0.09, 0.07, 0.93)
    backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(backdrop)

    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    backdrop.add_child(center)

    var panel := PanelContainer.new()
    panel.name = "VictoryPanel"
    panel.custom_minimum_size = Vector2(570, 415)
    center.add_child(panel)

    var padding := MarginContainer.new()
    for side in ["margin_left", "margin_right"]:
        padding.add_theme_constant_override(side, 30)
    for side in ["margin_top", "margin_bottom"]:
        padding.add_theme_constant_override(side, 25)
    panel.add_child(padding)

    var stack := VBoxContainer.new()
    stack.add_theme_constant_override("separation", 18)
    padding.add_child(stack)

    var heading := Label.new()
    heading.name = "VictoryTitle"
    heading.text = "A FAZENDA FLORESCEU!"
    heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    heading.add_theme_font_size_override("font_size", 31)
    heading.add_theme_color_override("font_color", Color("#daa954"))
    stack.add_child(heading)

    var message := Label.new()
    message.name = "VictoryMessage"
    message.text = "Voce concluiu os 6 objetivos da campanha!\nA horta prosperou, os animais foram cuidados\ne a vila conheceu seu trabalho.\n\nA jornada continua no modo livre."
    message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    message.add_theme_font_size_override("font_size", 19)
    stack.add_child(message)

    free_play_button = Button.new()
    free_play_button.name = "FreePlay"
    free_play_button.text = "CONTINUAR NO MODO LIVRE"
    free_play_button.custom_minimum_size.y = 52
    free_play_button.pressed.connect(continue_after_victory)
    stack.add_child(free_play_button)

    var title_button := Button.new()
    title_button.name = "BackToMenu"
    title_button.text = "SALVAR E VOLTAR AO MENU"
    title_button.custom_minimum_size.y = 48
    title_button.pressed.connect(back_to_menu)
    stack.add_child(title_button)


func show_victory() -> void:
    if visible:
        return
    visible = true
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    get_tree().paused = true
    free_play_button.grab_focus()


func continue_after_victory() -> void:
    get_tree().paused = false
    visible = false
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func back_to_menu() -> void:
    var life := get_parent().get_node_or_null("LifeSim")
    if life != null and bool(life.get("initialized")):
        life.call("_save_progress")
    get_tree().paused = false
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    get_tree().change_scene_to_file(MENU_SCENE)


func _exit_tree() -> void:
    if get_tree().paused:
        get_tree().paused = false
