extends SceneTree
## Falha de gravacao nao pode descartar a partida na tela de vitoria.
const Ending = preload("res://scripts/campaign_ending.gd")
var failures: Array[String] = []

class FakeLife extends Node:
    signal campaign_won
    var initialized := true
    var save_succeeds := false
    var save_calls := 0

    func _save_progress() -> bool:
        save_calls += 1
        return save_succeeds


func _initialize() -> void:
    call_deferred("_run")


func _check(ok: bool, message: String) -> void:
    if not ok:
        failures.append(message)
        push_error("CAMPAIGN ENDING TEST FAILED: " + message)


func _run() -> void:
    var world := Node.new()
    root.add_child(world)
    current_scene = world
    var life := FakeLife.new()
    life.name = "LifeSim"
    world.add_child(life)
    var ending := Ending.new()
    world.add_child(ending)
    ending.show_victory()
    ending.back_to_menu()
    _check(life.save_calls == 1, "Tenta salvar antes de sair")
    _check(current_scene == world and paused, "Falha preserva cena e pausa")
    # Stop here on regression: scene change would free the nodes next frame.
    if not failures.is_empty():
        quit(1)
        return
    _check(ending.visible, "Tela de vitoria continua disponivel")
    var notice := ending.find_child("SaveError", true, false) as Label
    _check(notice != null and notice.visible and not notice.text.is_empty(), "Falha informa o jogador")
    life.initialized = false
    ending.back_to_menu()
    _check(current_scene == world and paused, "Simulacao nao inicializada impede saida")
    _check(life.save_calls == 1, "Nao salva simulacao nao inicializada")
    life.initialized = true
    world.remove_child(life)
    ending.back_to_menu()
    _check(current_scene == world and paused, "Simulacao ausente impede saida")
    world.add_child(life)
    # After a failed attempt, free play remains usable and a later retry can save.
    ending.continue_after_victory()
    _check(not paused and not ending.visible, "Jogador pode continuar apos falha")
    ending.show_victory()
    life.save_succeeds = true
    ending.back_to_menu()
    await process_frame
    await process_frame
    _check(not paused, "Salvamento confirmado libera a pausa")
    _check(current_scene != null and current_scene.scene_file_path == "res://scenes/main_menu.tscn", "Sucesso retorna ao menu principal")
    if failures.is_empty():
        print("PASSOU: vitoria preserva progresso quando salvar falha e permite nova tentativa.")
        quit(0)
    else:
        quit(1)
