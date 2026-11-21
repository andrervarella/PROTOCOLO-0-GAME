extends Control
## Interface: HUD, caixa de diálogo, cartelas de cena, fade e controles de toque.
## Controles de toque (convenção aprovada no ARASHI): direcional deslizante à esquerda,
## PULAR e AÇÃO à direita, pequenos e com acabamento; centro da tela livre.

signal line_advanced
signal card_done

var main: Node
var hp := 6
var max_hp := 6
var era_tag := ""
var hint := ""
var hint_t := 0.0
var title_text := ""
var title_t := 0.0
var fade := 1.0
var t := 0.0

# diálogo
var dlg_active := false
var dlg_name := ""
var dlg_text := ""
var dlg_color := Color.WHITE
var dlg_shown := 0.0
var dlg_radio := false

# cartela
var card_active := false
var card_kind := ""
var card_lines: Array = []
var card_t := 0.0
var card_wait := false

# toque
var touch_enabled := false
var touch_visible := true
var stick_id := -1
var stick_origin := Vector2.ZERO
var stick_pos := Vector2.ZERO
var btn_ids := {}  # índice do dedo -> ação
var held := {}  # ação -> quantos dedos
var show_fs_hint := true
var auto_t := 0.0

const FONT_SIZE := 11


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if DisplayServer.is_touchscreen_available():
		touch_enabled = true


func _process(delta: float) -> void:
	t += delta
	hint_t = max(0.0, hint_t - delta)
	title_t = max(0.0, title_t - delta)
	if dlg_active:
		dlg_shown = min(float(dlg_text.length()), dlg_shown + delta * 48.0)
	if card_active:
		card_t += delta
	if main and main.autotest:
		auto_t += delta
		if auto_t > 0.5:
			auto_t = 0.0
			if (dlg_active and dlg_shown >= dlg_text.length()) or (card_active and card_wait and card_t > 1.0):
				_advance()
			elif dlg_active:
				_advance()
	queue_redraw()


# ---------------------------------------------------------------- API para o main
func set_hp(h: int, m: int) -> void:
	hp = h
	max_hp = m


func show_hint(text: String, dur := 5.0) -> void:
	hint = text
	hint_t = dur


func show_title(text: String) -> void:
	title_text = text
	title_t = 3.0


func fade_to(a: float, dur := 0.5) -> void:
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(self, "fade", a, dur)
	await tw.finished


## lines: Array de [nome, texto] ou [nome, texto, "radio"]
func say(lines: Array) -> void:
	_release_all()
	var was_paused := get_tree().paused
	get_tree().paused = true
	dlg_active = true
	for l in lines:
		dlg_name = l[0]
		dlg_text = l[1]
		dlg_radio = l.size() > 2 and l[2] == "radio"
		dlg_color = _name_color(dlg_name)
		dlg_shown = 0.0
		await line_advanced
	dlg_active = false
	get_tree().paused = was_paused


func card(kind: String, lines: Array, auto := 0.0) -> void:
	_release_all()
	card_active = true
	card_kind = kind
	card_lines = lines
	card_t = 0.0
	card_wait = auto <= 0.0
	if auto > 0.0:
		await get_tree().create_timer(auto, true, false, true).timeout
	else:
		await card_done
	card_active = false


func _name_color(n: String) -> Color:
	match n:
		"SILAS": return Color("e04848")
		"MAREK": return Color("e8c84a")
		"NEX": return Color("ffb030")
		"BALTAZAR": return Color("e08a3a")
		"KORD": return Color("8fb0d8")
		"MINEIRO": return Color("d0a070")
	return Color("cfcfcf")


# ---------------------------------------------------------------- entrada
func _advance() -> void:
	if card_active and card_wait and card_t > 0.8:
		card_done.emit()
		return
	if dlg_active:
		if dlg_shown < dlg_text.length():
			dlg_shown = dlg_text.length()
		else:
			line_advanced.emit()


func _input(event: InputEvent) -> void:
	var blocking := dlg_active or (card_active and card_wait)
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		touch_enabled = true
	if blocking:
		if (event is InputEventScreenTouch and event.pressed) \
				or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
				or event.is_action_pressed("attack") or event.is_action_pressed("jump") or event.is_action_pressed("ui_accept"):
			if not (event is InputEventAction):
				_advance()
			elif event.is_action_pressed("attack") or event.is_action_pressed("jump"):
				_advance()
			get_viewport().set_input_as_handled()
		return
	if event is InputEventScreenTouch:
		_touch(event.index, event.position, event.pressed)
	elif event is InputEventScreenDrag:
		_drag(event.index, event.position)


func _vs() -> Vector2:
	return get_viewport_rect().size


func _btn_pos(action: String) -> Vector2:
	var s := _vs()
	if action == "jump":
		return Vector2(s.x - 40, s.y - 38)
	return Vector2(s.x - 98, s.y - 52)  # attack


func _touch(idx: int, pos: Vector2, pressed: bool) -> void:
	var s := _vs()
	if pressed:
		if pos.x > s.x - 34 and pos.y < 30:
			_toggle_fullscreen()
			return
		for a in ["jump", "attack"]:
			if pos.distance_to(_btn_pos(a)) < 36.0:
				btn_ids[idx] = a
				_press(a)
				return
		if pos.x < s.x * 0.45 and pos.y > s.y * 0.35 and stick_id == -1:
			stick_id = idx
			stick_origin = pos
			stick_pos = pos
	else:
		if btn_ids.has(idx):
			_release(btn_ids[idx])
			btn_ids.erase(idx)
		if idx == stick_id:
			stick_id = -1
			for a in ["left", "right", "down"]:
				if held.get(a, 0) > 0:
					held[a] = 1
					_release(a)


func _drag(idx: int, pos: Vector2) -> void:
	if idx != stick_id:
		return
	stick_pos = pos
	var d := pos - stick_origin
	if d.length() > 34.0:  # direcional acompanha o dedo
		stick_origin = pos - d.normalized() * 34.0
		d = pos - stick_origin
	_set_held("left", d.x < -9.0)
	_set_held("right", d.x > 9.0)
	_set_held("down", d.y > 14.0 and absf(d.y) > absf(d.x) * 0.8)


func _set_held(a: String, v: bool) -> void:
	var is_on: bool = held.get(a, 0) > 0
	if v and not is_on:
		_press(a)
	elif not v and is_on:
		held[a] = 1
		_release(a)


func _press(a: String) -> void:
	held[a] = held.get(a, 0) + 1
	if held[a] == 1:
		var ev := InputEventAction.new()
		ev.action = a
		ev.pressed = true
		Input.parse_input_event(ev)


func _release(a: String) -> void:
	held[a] = max(0, held.get(a, 0) - 1)
	if held[a] == 0:
		var ev := InputEventAction.new()
		ev.action = a
		ev.pressed = false
		Input.parse_input_event(ev)


func _release_all() -> void:
	for a in held.keys():
		if held[a] > 0:
			held[a] = 1
			_release(a)
	btn_ids.clear()
	stick_id = -1
	for a in ["left", "right", "down", "jump", "attack", "dodge"]:
		Input.action_release(a)


func _toggle_fullscreen() -> void:
	show_fs_hint = false
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


# ---------------------------------------------------------------- desenho
func _txt(pos: Vector2, s: String, size: int, col: Color, align := HORIZONTAL_ALIGNMENT_LEFT, width := -1.0) -> void:
	var f := ThemeDB.fallback_font
	draw_string_outline(f, pos, s, align, width, size, 3, Color(0, 0, 0, col.a * 0.85))
	draw_string(f, pos, s, align, width, size, col)


func _draw() -> void:
	var s := _vs()
	if not card_active:
		if not dlg_active:
			_draw_hud(s)
		if touch_enabled and touch_visible and not dlg_active:
			_draw_touch(s)
		if dlg_active:
			_draw_dialogue(s)
	if card_active:
		_draw_card(s)
	if fade > 0.0:
		draw_rect(Rect2(Vector2.ZERO, s), Color(0, 0, 0, fade))


func _draw_hud(s: Vector2) -> void:
	if max_hp > 0 and main and main.show_hud:
		# moldura metálica + segmentos de vida
		var x0 := 10.0
		var y0 := 10.0
		draw_rect(Rect2(x0 - 3, y0 - 3, max_hp * 9 + 5, 13), Color(0.08, 0.09, 0.1, 0.8))
		draw_rect(Rect2(x0 - 3, y0 - 3, max_hp * 9 + 5, 13), Color("5a6068"), false, 1.0)
		for i in max_hp:
			var c := Color("c62828") if i < hp else Color("2a1416")
			draw_rect(Rect2(x0 + i * 9, y0, 7, 7), c)
		if era_tag != "":
			_txt(Vector2(x0 - 2, y0 + 24), era_tag, 9, Color(0.75, 0.78, 0.82, 0.8))
	if hint_t > 0.0 and not dlg_active:
		var a: float = min(1.0, hint_t)
		draw_rect(Rect2(s.x / 2 - 160, 34, 320, 20), Color(0, 0, 0, 0.5 * a))
		_txt(Vector2(s.x / 2 - 160, 48), hint, 10, Color(1, 0.92, 0.75, a), HORIZONTAL_ALIGNMENT_CENTER, 320)
	if title_t > 0.0:
		var a2: float = min(1.0, title_t) * min(1.0, (3.0 - title_t) * 2.0)
		_txt(Vector2(0, s.y * 0.32), title_text, 16, Color(1, 1, 1, a2), HORIZONTAL_ALIGNMENT_CENTER, s.x)
	if touch_enabled:
		# botão de tela cheia (canto superior direito)
		var c2 := Vector2(s.x - 18, 16)
		draw_rect(Rect2(c2 - Vector2(8, 7), Vector2(16, 14)), Color(1, 1, 1, 0.35), false, 1.0)
		if show_fs_hint and main and main.on_title:
			_txt(Vector2(s.x - 140, 20), "tela cheia >", 9, Color(1, 1, 1, 0.6))


func _draw_touch(s: Vector2) -> void:
	# direcional
	var base := stick_origin if stick_id != -1 else Vector2(64, s.y - 52)
	var knob := stick_pos if stick_id != -1 else base
	draw_circle(base, 30.0, Color(0, 0, 0, 0.25))
	draw_arc(base, 30.0, 0, TAU, 32, Color(0.75, 0.78, 0.82, 0.45), 1.5)
	draw_arc(base, 26.0, 0, TAU, 32, Color("a3191f", 0.35), 1.0)
	for dir in [Vector2.LEFT, Vector2.RIGHT, Vector2.DOWN]:
		var on: bool = (dir == Vector2.LEFT and held.get("left", 0) > 0) or (dir == Vector2.RIGHT and held.get("right", 0) > 0) or (dir == Vector2.DOWN and held.get("down", 0) > 0)
		var p: Vector2 = base + dir * 20.0
		var tri := PackedVector2Array([p + dir * 5.0, p + dir.orthogonal() * 4.0, p - dir.orthogonal() * 4.0])
		draw_colored_polygon(tri, Color(1, 0.85, 0.6, 0.9) if on else Color(1, 1, 1, 0.45))
	var kd := (knob - base).limit_length(18.0)
	draw_circle(base + kd, 11.0, Color(0.6, 0.62, 0.66, 0.55))
	draw_arc(base + kd, 11.0, 0, TAU, 20, Color(1, 1, 1, 0.5), 1.0)
	# botões
	for a in ["jump", "attack"]:
		var c := _btn_pos(a)
		var on2: bool = held.get(a, 0) > 0
		draw_circle(c, 24.0, Color(0.05, 0.05, 0.06, 0.55 if not on2 else 0.75))
		draw_arc(c, 24.0, 0, TAU, 32, Color(0.75, 0.78, 0.82, 0.55), 1.5)
		draw_arc(c, 20.0, -2.2, -0.9, 10, Color("a3191f", 0.8), 2.0)
		var label := "PULAR" if a == "jump" else "AÇÃO"
		_txt(Vector2(c.x - 24, c.y + 4), label, 9, Color(1, 1, 1, 0.9 if on2 else 0.7), HORIZONTAL_ALIGNMENT_CENTER, 48)


func _draw_dialogue(s: Vector2) -> void:
	var w: float = min(560.0, s.x - 40.0)
	var r := Rect2(s.x / 2 - w / 2, 10, w, 72)
	draw_rect(r, Color(0.04, 0.045, 0.055, 0.9))
	draw_rect(r, Color("6a7078"), false, 1.0)
	draw_line(r.position + Vector2(0, 0), r.position + Vector2(40, 0), Color("a3191f"), 2.0)
	# retrato provisório
	var pr := Rect2(r.position + Vector2(8, 8), Vector2(56, 56))
	draw_rect(pr, Color(0.1, 0.11, 0.13))
	draw_rect(pr, dlg_color * Color(1, 1, 1, 0.8), false, 1.0)
	if dlg_radio:
		for i in 4:
			draw_arc(pr.get_center(), 6.0 + i * 6.0, -0.7, 0.7, 6, Color(dlg_color, 0.7 - i * 0.15), 1.0)
		_txt(pr.position + Vector2(0, 52), "RÁDIO", 8, Color(1, 1, 1, 0.5), HORIZONTAL_ALIGNMENT_CENTER, 56)
	else:
		_txt(pr.position + Vector2(0, 35), dlg_name.substr(0, 1), 22, dlg_color, HORIZONTAL_ALIGNMENT_CENTER, 56)
	_txt(r.position + Vector2(74, 18), dlg_name, 10, dlg_color)
	var shown := dlg_text.substr(0, int(dlg_shown))
	var f := ThemeDB.fallback_font
	draw_multiline_string_outline(f, r.position + Vector2(74, 34), shown, HORIZONTAL_ALIGNMENT_LEFT, w - 90, 11, 3, 3, Color(0, 0, 0, 0.8))
	draw_multiline_string(f, r.position + Vector2(74, 34), shown, HORIZONTAL_ALIGNMENT_LEFT, w - 90, 11, 3, Color(0.92, 0.92, 0.92))
	if dlg_shown >= dlg_text.length() and int(t * 3.0) % 2 == 0:
		draw_colored_polygon(PackedVector2Array([r.end - Vector2(14, 12), r.end - Vector2(6, 12), r.end - Vector2(10, 7)]), Color(1, 1, 1, 0.8))


func _draw_card(s: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, s), Color(0.015, 0.015, 0.02))
	var a: float = clamp(card_t * 1.5, 0.0, 1.0)
	match card_kind:
		"news":
			_draw_news(s, a)
		"title":
			_txt(Vector2(0, s.y * 0.42), "PROTOCOLO ZERO", 34, Color(0.92, 0.92, 0.92, a), HORIZONTAL_ALIGNMENT_CENTER, s.x)
			draw_rect(Rect2(s.x / 2 - 120, s.y * 0.42 + 10, 240, 2), Color("a3191f", a))
			_txt(Vector2(0, s.y * 0.42 + 30), "PILOTO JOGÁVEL — FASE 1", 11, Color(0.75, 0.75, 0.78, a), HORIZONTAL_ALIGNMENT_CENTER, s.x)
			if card_t > 1.0 and int(t * 2.0) % 2 == 0:
				_txt(Vector2(0, s.y * 0.78), "toque ou aperte AÇÃO para começar", 10, Color(1, 1, 1, 0.8), HORIZONTAL_ALIGNMENT_CENTER, s.x)
			_txt(Vector2(0, s.y - 14), "arte, som e textos provisórios · teclado: setas, ESPAÇO pula, J ação, K esquiva", 8, Color(1, 1, 1, 0.35), HORIZONTAL_ALIGNMENT_CENTER, s.x)
		_:
			var y := s.y / 2 - card_lines.size() * 11.0
			for i in card_lines.size():
				var la: float = clamp((card_t - i * 0.6) * 1.5, 0.0, 1.0)
				var big := i == 0 and card_kind == "era"
				_txt(Vector2(30, y + i * 24), card_lines[i], 20 if big else 12, Color(0.9, 0.9, 0.9, la), HORIZONTAL_ALIGNMENT_CENTER, s.x - 60)
	if card_wait and card_t > 1.2 and card_kind != "title":
		_txt(Vector2(0, s.y - 14), ">>", 10, Color(1, 1, 1, 0.5 + 0.5 * sin(t * 4.0)), HORIZONTAL_ALIGNMENT_CENTER, s.x - 20)


func _draw_news(s: Vector2, a: float) -> void:
	var tv := Rect2(s.x / 2 - 170, s.y / 2 - 110, 340, 200)
	draw_rect(tv.grow(10), Color(0.08, 0.08, 0.09, a))
	draw_rect(tv, Color(0.1, 0.16, 0.24, a))
	for i in 40:
		var yy := tv.position.y + fmod(i * 5.0 + t * 30.0, tv.size.y)
		draw_line(Vector2(tv.position.x, yy), Vector2(tv.end.x, yy), Color(1, 1, 1, 0.03 * a), 1.0)
	# foto oficial provisória (Silas 2051)
	var ph := Rect2(tv.position + Vector2(24, 26), Vector2(90, 110))
	draw_rect(ph, Color(0.2, 0.24, 0.3, a))
	draw_rect(Rect2(ph.position + Vector2(30, 24), Vector2(30, 32)), Color(0.78, 0.6, 0.48, a))
	draw_rect(Rect2(ph.position + Vector2(27, 18), Vector2(36, 12)), Color(0.05, 0.05, 0.06, a))
	draw_rect(Rect2(ph.position + Vector2(30, 44), Vector2(30, 12)), Color(0.14, 0.1, 0.08, a))
	draw_rect(Rect2(ph.position + Vector2(14, 60), Vector2(62, 50)), Color(0.22, 0.25, 0.28, a))
	_txt(tv.position + Vector2(130, 46), "NOTÍCIAS · 2054", 10, Color(0.8, 0.85, 0.95, a))
	_txt(tv.position + Vector2(130, 70), "Ex-agente condenado", 11, Color(1, 1, 1, a))
	_txt(tv.position + Vector2(130, 86), "por traição.", 11, Color(1, 1, 1, a))
	var bar := Rect2(tv.position.x, tv.end.y - 40, tv.size.x, 26)
	draw_rect(bar, Color(0.62, 0.08, 0.1, a))
	_txt(Vector2(bar.position.x, bar.position.y + 18), "SILAS VENN — EXECUTADO POR TRAIÇÃO", 12, Color(1, 1, 1, a), HORIZONTAL_ALIGNMENT_CENTER, bar.size.x)
	if card_t > 3.2 and fmod(card_t, 0.3) < 0.1:
		draw_rect(tv, Color(1, 1, 1, 0.1))
