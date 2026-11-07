extends Node2D

const Rules = preload("res://scripts/farm_rules.gd")
const COLUMNS := 10
const ROWS := 7
const CELL := 68.0
const START := Vector2(72, 126)
const FONT_SIZE := 22

var cursor := Vector2i(0, 0)
var planted: Dictionary = {}
var day := 1
var seeds := 8
var coins := 0
var notice := "Espaco: plantar. N: proximo dia."


func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	var code := key_event.physical_keycode
	match code:
		KEY_W, KEY_UP:
			cursor.y = maxi(0, cursor.y - 1)
		KEY_S, KEY_DOWN:
			cursor.y = mini(ROWS - 1, cursor.y + 1)
		KEY_A, KEY_LEFT:
			cursor.x = maxi(0, cursor.x - 1)
		KEY_D, KEY_RIGHT:
			cursor.x = mini(COLUMNS - 1, cursor.x + 1)
		KEY_SPACE:
			_tend_plot()
		KEY_N:
			day += 1
			notice = "Dia %d: as plantacoes cresceram." % day
		KEY_B:
			if Rules.can_buy_seeds(coins):
				coins -= 4
				seeds += 5
				notice = "Comprou 5 sementes por 4 moedas."
			else:
				notice = "Voce precisa de 4 moedas."
		KEY_R:
			get_tree().reload_current_scene()
			return
		_:
			return
	queue_redraw()


func _tend_plot() -> void:
	if planted.has(cursor):
		var when_planted: int = planted[cursor]
		if Rules.can_harvest(when_planted, day):
			planted.erase(cursor)
			coins += 3
			notice = "Colheita! +3 moedas."
		else:
			notice = "A planta ainda nao esta madura."
	elif seeds > 0:
		planted[cursor] = day
		seeds -= 1
		notice = "Uma semente foi plantada."
	else:
		notice = "Sem sementes. Pressione B para comprar."


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color("#10212b"))
	draw_rect(Rect2(44, 72, 732, 536), Color("#294834"))
	var season := Rules.season_name(day)
	var soil_color := Color("#705239")
	match season:
		"Primavera":
			soil_color = Color("#6c4c38")
		"Verao":
			soil_color = Color("#82603b")
		"Outono":
			soil_color = Color("#67483c")
		"Inverno":
			soil_color = Color("#516377")
	for row in range(ROWS):
		for col in range(COLUMNS):
			var grid_pos := Vector2i(col, row)
			var pos := START + Vector2(col, row) * CELL
			var rect := Rect2(pos, Vector2(CELL - 6, CELL - 6))
			draw_rect(rect, soil_color)
			draw_rect(rect.grow(-4), soil_color.darkened(0.10), false, 1)
			if planted.has(grid_pos):
				_draw_crop(pos + Vector2(31, 37), Rules.crop_stage(planted[grid_pos], day))
			if cursor == grid_pos:
				draw_rect(rect, Color("#61e9ff"), false, 4)
	_draw_text(Vector2(48, 48), "PIXEL FARM SEASONS", 32, Color("#f1f7df"))
	draw_rect(Rect2(790, 80, 292, 528), Color("#172f31"))
	_draw_text(Vector2(815, 128), "FAZENDA / MVP", 22, Color("#8deec5"))
	_draw_text(Vector2(815, 180), "Dia: %d" % day)
	_draw_text(Vector2(815, 214), "Estacao: %s" % season)
	_draw_text(Vector2(815, 268), "Sementes: %d" % seeds)
	_draw_text(Vector2(815, 304), "Moedas: %d" % coins)
	_draw_text(Vector2(815, 358), "WASD / Setas: mover", 17)
	_draw_text(Vector2(815, 391), "Espaco: plantar/colher", 17)
	_draw_text(Vector2(815, 424), "N: avancar 1 dia", 17)
	_draw_text(Vector2(815, 457), "B: comprar sementes", 17)
	_draw_text(Vector2(815, 490), "R: reiniciar", 17)
	_draw_text(Vector2(48, 664), notice, 20, Color("#ffe5a7"))
	_draw_text(Vector2(48, 690), "Culturas amadurecem depois de 3 dias. Cada colheita rende 3 moedas.", 15, Color("#a4d6bc"))


func _draw_crop(center: Vector2, stage: int) -> void:
	draw_line(center, center + Vector2(0, -9 - stage * 5), Color("#87d579"), 4)
	if stage >= 1:
		draw_circle(center + Vector2(-7, -9), 7, Color("#80c95d"))
	if stage >= 2:
		draw_circle(center + Vector2(7, -17), 9, Color("#8fea58"))
	if stage >= 3:
		draw_circle(center + Vector2(0, -24), 11, Color("#f5ba55"))


func _draw_text(pos: Vector2, value: String, font_size: int = FONT_SIZE, tint: Color = Color("#ebf3e9")) -> void:
	draw_string(ThemeDB.fallback_font, pos, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, tint)
