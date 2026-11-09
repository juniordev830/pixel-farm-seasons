extends Control
## Tela inicial da versao PC. Nunca sobrescreve um save sem confirmacao.
const SAVE_PATH := "user://pixel_farm_life_save.json"
const GAME_SCENE := "res://scenes/farm_world.tscn"
const Missions = preload("res://scripts/farm_missions.gd")

var continue_button: Button
var summary_label: Label
var new_game_confirmation: ConfirmationDialog


func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    _build_menu()
    refresh_save_status()


static func _valid_save_integer(value: Variant, minimum: int) -> bool:
    # Godot JSON can decode numeric literals as floating-point values.
    if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
        return false
    var number := float(value)
    return is_finite(number) and number >= float(minimum) and number == floorf(number) and number <= 2147483647.0


static func inspect_save(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {"valid": false, "reason": "missing"}
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {"valid": false, "reason": "unreadable"}
    var decoded: Variant = JSON.parse_string(file.get_as_text())
    if typeof(decoded) != TYPE_DICTIONARY:
        return {"valid": false, "reason": "corrupt"}
    var data: Dictionary = decoded
    if not _valid_save_integer(data.get("version", null), 1) or int(data.get("version")) != 1:
        return {"valid": false, "reason": "incompatible"}
    if not _valid_save_integer(data.get("day", null), 1) or not _valid_save_integer(data.get("coins", null), 0):
        return {"valid": false, "reason": "corrupt"}
    if data.has("level") and not _valid_save_integer(data.get("level"), 1):
        return {"valid": false, "reason": "corrupt"}
    # Prevent malformed optional save fields from crashing the life simulation.
    for field in ["minutes", "hunger", "energy", "car_condition", "car_rot", "farmer_rot"]:
        if data.has(field):
            var value: Variant = data[field]
            if (typeof(value) != TYPE_FLOAT and typeof(value) != TYPE_INT) or not is_finite(float(value)):
                return {"valid": false, "reason": "corrupt"}
    for field in ["food", "feed", "seeds", "harvested", "eggs", "milk", "experience"]:
        if data.has(field) and not _valid_save_integer(data[field], 0):
            return {"valid": false, "reason": "corrupt"}
    for field in ["car_pos", "farmer_pos"]:
        if not data.has(field):
            continue
        var coords: Variant = data[field]
        if typeof(coords) != TYPE_ARRAY or coords.size() != 3:
            return {"valid": false, "reason": "corrupt"}
        for coord in coords:
            if (typeof(coord) != TYPE_FLOAT and typeof(coord) != TYPE_INT) or not is_finite(float(coord)):
                return {"valid": false, "reason": "corrupt"}
    var claimed: Variant = data.get("mission_completed", [])
    if typeof(claimed) != TYPE_ARRAY:
        return {"valid": false, "reason": "corrupt"}
    # The same canonical mission keys are used when loading the game.
    var finished: bool = Missions.completed({}, claimed)
    return {
        "valid": true,
        "day": maxi(1, int(data.get("day", 1))),
        "coins": maxi(0, int(data.get("coins", 0))),
        "level": clampi(int(data.get("level", 1)), 1, 30),
        "finished": finished
    }


func _build_menu() -> void:
    var background := ColorRect.new()
    background.name = "Background"
    background.color = Color("#193b31")
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)

    var center := CenterContainer.new()
    center.name = "Center"
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    background.add_child(center)

    var panel := PanelContainer.new()
    panel.name = "MainPanel"
    panel.custom_minimum_size = Vector2(560, 475)
    center.add_child(panel)

    var margin := MarginContainer.new()
    for side in ["margin_left", "margin_right"]:
        margin.add_theme_constant_override(side, 32)
    for side in ["margin_top", "margin_bottom"]:
        margin.add_theme_constant_override(side, 28)
    panel.add_child(margin)

    var stack := VBoxContainer.new()
    stack.add_theme_constant_override("separation", 16)
    margin.add_child(stack)

    var title := Label.new()
    title.name = "Title"
    title.text = "PIXEL FARM SEASONS"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 32)
    title.add_theme_color_override("font_color", Color("#d2a457"))
    stack.add_child(title)

    var subtitle := Label.new()
    subtitle.text = "Sua vida no campo comeca aqui"
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_font_size_override("font_size", 19)
    stack.add_child(subtitle)

    summary_label = Label.new()
    summary_label.name = "SaveSummary"
    summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    stack.add_child(summary_label)

    continue_button = Button.new()
    continue_button.name = "Continue"
    continue_button.text = "CONTINUAR PARTIDA"
    continue_button.custom_minimum_size.y = 52
    continue_button.pressed.connect(_enter_game)
    stack.add_child(continue_button)

    var new_game_button := Button.new()
    new_game_button.name = "NewGame"
    new_game_button.text = "NOVA PARTIDA"
    new_game_button.custom_minimum_size.y = 52
    new_game_button.pressed.connect(_confirm_new_game)
    stack.add_child(new_game_button)

    var help := Label.new()
    help.text = "WASD mover | Mouse camera | E interagir\nF ferramenta | G semente | P pausar/salvar"
    help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    stack.add_child(help)

    var quit_button := Button.new()
    quit_button.name = "Quit"
    quit_button.text = "SAIR"
    quit_button.pressed.connect(_quit_game)
    stack.add_child(quit_button)

    new_game_confirmation = ConfirmationDialog.new()
    new_game_confirmation.name = "ConfirmNewGame"
    new_game_confirmation.title = "Iniciar nova partida?"
    new_game_confirmation.dialog_text = "O progresso atual sera guardado em um backup local antes de iniciar uma nova fazenda."
    new_game_confirmation.ok_button_text = "CRIAR NOVA FAZENDA"
    new_game_confirmation.confirmed.connect(_start_new_game)
    add_child(new_game_confirmation)


func refresh_save_status() -> void:
    var result := inspect_save(SAVE_PATH)
    continue_button.disabled = not bool(result.get("valid", false))
    if bool(result.get("valid", false)):
        var progress := "Campanha concluida" if bool(result["finished"]) else "Campanha em andamento"
        summary_label.text = "Partida encontrada: dia %d | nivel %d | R$ %d\n%s" % [
            int(result["day"]), int(result["level"]), int(result["coins"]), progress
        ]
    elif String(result.get("reason", "")) == "missing":
        summary_label.text = "Nenhuma partida salva. Comece sua fazenda!"
    else:
        summary_label.text = "Save existente invalido. Uma nova partida preservara um backup."


func _confirm_new_game() -> void:
    new_game_confirmation.popup_centered()


func _start_new_game() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        var absolute_save := ProjectSettings.globalize_path(SAVE_PATH)
        var backup_path := ProjectSettings.globalize_path(SAVE_PATH + ".backup")
        var backup_result := DirAccess.copy_absolute(absolute_save, backup_path)
        if backup_result != OK:
            summary_label.text = "Nao foi possivel fazer backup. Save original preservado."
            return
        var remove_result := DirAccess.remove_absolute(absolute_save)
        if remove_result != OK:
            summary_label.text = "Nao foi possivel iniciar nova partida. Save original preservado."
            return
    _enter_game()


func _enter_game() -> void:
    var result := get_tree().change_scene_to_file(GAME_SCENE)
    if result != OK:
        summary_label.text = "Erro ao abrir a fazenda (%d). Verifique os arquivos do jogo." % result


func _quit_game() -> void:
    get_tree().quit()
