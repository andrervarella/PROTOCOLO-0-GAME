extends Node
## PROTOCOLO ZERO — piloto da fase 1 (prólogo).
## Fluxo: título → notícia → cela → corredor → laboratório → hangar (cercados)
##        → flashback 2051: mina → galeria (hesitação) → 2054: sacrifício do mentor → portão → fim.
## Textos marcados como PROPOSTA no docs/20_PILOTO_FASE1.md.

signal level_finished(result: String)

const CAM_ZOOM := 1.25
const CAM_Y := 196.0

const PlayerScript := preload("res://scripts/player.gd")
const EnemyScript := preload("res://scripts/enemy.gd")
const PropScript := preload("res://scripts/props.gd")
const FxScript := preload("res://scripts/fx.gd")
const ViewScript := preload("res://scripts/level_view.gd")
const UiScript := preload("res://scripts/ui.gd")

var world: Node2D
var level_root: Node2D
var view: Node2D
var fx: Node2D
var cam: Camera2D
var ui: Control
var player: CharacterBody2D
var lv := {}
var props_by_id := {}
var marek: Node2D
var nex: Node2D
var show_hud := false
var on_title := true
var nex_active := false
var shake_amt := 0.0
var flags := {}
var arena_walls: Array = []
var wave_queue: Array = []
var busy := false  # cena em andamento
# modo de teste automático: godot -- --autotest  (robô percorre o piloto e salva capturas)
var autotest := false
var shot_t := 0.0
var shot_n := 0
var test_t := 0.0
var bot_jump := 0.0
var bot_last_x := 0.0
var bot_stuck := 0.0


func _ready() -> void:
	autotest = "--autotest" in OS.get_cmdline_user_args()
	_setup_input()
	world = Node2D.new()
	world.name = "World"
	add_child(world)
	cam = Camera2D.new()
	cam.zoom = Vector2(CAM_ZOOM, CAM_ZOOM)
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 7.0
	world.add_child(cam)
	cam.make_current()
	var layer := CanvasLayer.new()
	layer.layer = 10
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)
	ui = UiScript.new()
	ui.main = self
	layer.add_child(ui)
	_run_game()


func _setup_input() -> void:
	var map := {
		"left": [KEY_LEFT, KEY_A], "right": [KEY_RIGHT, KEY_D], "down": [KEY_DOWN, KEY_S],
		"jump": [KEY_SPACE, KEY_W, KEY_UP, KEY_Z], "attack": [KEY_J, KEY_X, KEY_ENTER],
		"dodge": [KEY_K, KEY_C, KEY_SHIFT],
	}
	var pads := {"jump": [JOY_BUTTON_A], "attack": [JOY_BUTTON_X], "dodge": [JOY_BUTTON_B],
		"left": [JOY_BUTTON_DPAD_LEFT], "right": [JOY_BUTTON_DPAD_RIGHT], "down": [JOY_BUTTON_DPAD_DOWN]}
	for a in map.keys():
		if not InputMap.has_action(a):
			InputMap.add_action(a, 0.3)
		for k in map[a]:
			var e := InputEventKey.new()
			e.physical_keycode = k
			InputMap.action_add_event(a, e)
		for b in pads.get(a, []):
			var j := InputEventJoypadButton.new()
			j.button_index = b
			InputMap.action_add_event(a, j)
	for pair in [["left", -1.0], ["right", 1.0]]:
		var m := InputEventJoypadMotion.new()
		m.axis = JOY_AXIS_LEFT_X
		m.axis_value = pair[1]
		InputMap.action_add_event(pair[0], m)
	var md := InputEventJoypadMotion.new()
	md.axis = JOY_AXIS_LEFT_Y
	md.axis_value = 1.0
	InputMap.action_add_event("down", md)


# ================================================================ efeitos
func spark(p: Vector2, c: Color) -> void:
	if fx: fx.spark(p, c)


func burst(p: Vector2, c: Color) -> void:
	if fx: fx.burst(p, c)


func spawn_bullet(p: Vector2, v: Vector2, owner: String, dmg: int) -> void:
	if fx: fx.add_bullet(p, v, owner, dmg)


func shake(a: float) -> void:
	shake_amt = max(shake_amt, a)


func hitstop(d: float) -> void:
	if Engine.time_scale < 1.0:
		return
	Engine.time_scale = 0.05
	await get_tree().create_timer(d, true, false, true).timeout
	Engine.time_scale = 1.0


func _process(delta: float) -> void:
	if cam and player and is_instance_valid(player) and not busy:
		cam.position.x = player.position.x + player.facing * 30.0
	if cam:
		cam.position.y = CAM_Y
		shake_amt = move_toward(shake_amt, 0.0, 30.0 * delta)
		cam.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_amt
	if player and is_instance_valid(player):
		ui.set_hp(player.hp, player.max_hp)
		_check_level_logic()
	if autotest:
		_autotest(delta)


func _autotest(delta: float) -> void:
	test_t += delta
	shot_t += delta
	if shot_t > 1.2:
		shot_t = 0.0
		shot_n += 1
		var img := get_viewport().get_texture().get_image()
		img.save_png("/tmp/pz_shots/%03d_%s.png" % [shot_n, lv.get("id", "card")])
	if player and is_instance_valid(player) and not player.dead:
		player.invuln = max(player.invuln, 0.2)
		var go_left: bool = lv.get("id", "") == "cela" and not flags.get("tool", false)
		Input.action_release("left")
		Input.action_release("right")
		if player.controllable and not ui.dlg_active:
			var stop: bool = enemies_alive() > 0 and lv.get("id", "") == "hangar" and player.position.x > 500
			if not stop:
				Input.action_press("left" if go_left else "right")
			var above := false
			for n in get_tree().get_nodes_in_group("enemies"):
				var c2: Vector2 = n.hit_rect().get_center()
				if absf(c2.x - player.position.x) < 50.0 and player.position.y - c2.y > 30.0:
					above = true
			var walled: bool = (player.is_on_wall() or above) and player.is_on_floor()
			if walled:
				Input.action_press("jump")
				bot_jump = 0.35
			else:
				bot_jump -= delta
				if bot_jump <= 0.0:
					Input.action_release("jump")
			var near := false
			var tgt_dx := 0.0
			var best := 9999.0
			for n in get_tree().get_nodes_in_group("hittable"):
				var c: Vector2 = n.hit_rect().get_center()
				var dxx: float = c.x - player.position.x
				if absf(dxx) < (300.0 if player.era == "2051" else 70.0) and absf(c.y - player.position.y) < 100.0 and absf(dxx) < best:
					near = true
					best = absf(dxx)
					tgt_dx = dxx
			if near:
				Input.action_release("left")
				Input.action_release("right")
				if (tgt_dx < 0.0 and player.facing > 0) or (tgt_dx > 0.0 and player.facing < 0) or (player.era == "2054" and absf(tgt_dx) > 26.0):
					Input.action_press("left" if tgt_dx < 0.0 else "right")
			if lv.get("id", "") == "portao" and player.position.x > 1600.0:
				near = true
			if near and int(test_t * 8.0) % 2 == 0:
				Input.action_press("attack")
			else:
				Input.action_release("attack")
	if player and int(test_t / 10.0) != int((test_t - delta) / 10.0):
		print("  pos ", lv.get("id", ""), " x=", int(player.position.x), " hp=", player.hp, " inimigos=", enemies_alive())
	if player and is_instance_valid(player):
		if absf(player.position.x - bot_last_x) > 8.0:
			bot_last_x = player.position.x
			bot_stuck = 0.0
		elif player.controllable and not ui.dlg_active:
			bot_stuck += delta
			if bot_stuck > 6.0:
				bot_stuck = 0.0
				var en := get_tree().get_nodes_in_group("enemies")
				if en.size() > 0:
					print("  robô: ajuda em ", en[0].kind)
					en[0].take_hit(99, player.position.x)
	if test_t > 560.0:
		print("AUTOTEST: tempo esgotado em ", lv.get("id", ""))
		get_tree().quit(1)


# ================================================================ mundo
func point_in_solid(p: Vector2) -> bool:
	for s in lv.get("solids", []):
		if Rect2(s[0], s[1], s[2], s[3]).has_point(p):
			return true
	return false


func floor_y_at(x: float) -> float:
	var best := 300.0
	for s in lv.get("solids", []):
		if x >= s[0] and x <= s[0] + s[2] and s[1] >= 200:
			best = min(best, float(s[1]))
	return best


func build_level(id: String) -> void:
	if level_root:
		level_root.queue_free()
	fx = null
	props_by_id.clear()
	arena_walls.clear()
	wave_queue.clear()
	marek = null
	nex = null
	nex_active = false
	Engine.time_scale = 1.0
	lv = LEVELS.get_level(id)
	level_root = Node2D.new()
	level_root.name = "Level_" + id
	world.add_child(level_root)
	view = ViewScript.new()
	view.main = self
	view.lv = lv
	level_root.add_child(view)
	# colisões
	var sb := StaticBody2D.new()
	sb.collision_layer = 1
	level_root.add_child(sb)
	for s in lv["solids"]:
		var cs := CollisionShape2D.new()
		var rs := RectangleShape2D.new()
		rs.size = Vector2(s[2], s[3])
		cs.shape = rs
		cs.position = Vector2(s[0] + s[2] / 2.0, s[1] + s[3] / 2.0)
		sb.add_child(cs)
	for o in lv["oneway"]:
		var cs2 := CollisionShape2D.new()
		var rs2 := RectangleShape2D.new()
		rs2.size = Vector2(o[2], 6)
		cs2.shape = rs2
		cs2.position = Vector2(o[0] + o[2] / 2.0, o[1] + 3)
		cs2.one_way_collision = true
		sb.add_child(cs2)
	# paredes das bordas
	for wx in [-10.0, float(lv["width"]) + 10.0]:
		var cs3 := CollisionShape2D.new()
		var rs3 := RectangleShape2D.new()
		rs3.size = Vector2(20, 800)
		cs3.shape = rs3
		cs3.position = Vector2(wx, 0)
		sb.add_child(cs3)
	# objetos
	for e in lv["props"]:
		_spawn_prop(e)
	if nex and nex.nex_on:
		nex_active = true
	# jogador
	player = PlayerScript.new()
	player.setup(self, lv["era"], flags.get("tool", false) or lv["era"] == "2051")
	player.position = lv["spawn"]
	player.died.connect(_on_player_died)
	level_root.add_child(player)
	if lv.has("player_facing"):
		player.facing = lv["player_facing"]
	# inimigos
	for e in lv["enemies"]:
		spawn_enemy(e[0], Vector2(e[1], e[2]), e[3] if e.size() > 3 else {})
	fx = FxScript.new()
	fx.main = self
	level_root.add_child(fx)
	cam.limit_left = 0
	cam.limit_right = int(lv["width"])
	cam.limit_top = 0
	cam.limit_bottom = 360
	cam.position = Vector2(player.position.x, CAM_Y)
	cam.reset_smoothing()
	ui.era_tag = lv["tag"]
	show_hud = true
	ui.set_hp(player.hp, player.max_hp)


func _spawn_prop(e: Array) -> Node2D:
	var p := PropScript.new()
	var data: Dictionary = e[3] if e.size() > 3 else {}
	p.setup(self, e[0], Vector2(e[1], e[2]), data)
	level_root.add_child(p)
	if p.id != "":
		props_by_id[p.id] = p
	p.activated.connect(_on_prop_activated)
	if e[0] == "marek":
		marek = p
	elif e[0] == "nex":
		nex = p
	return p


func spawn_enemy(kind: String, pos: Vector2, data := {}) -> Node:
	var en := EnemyScript.new()
	en.setup(self, kind, pos)
	if data.has("key"):
		en.set_meta("key", data["key"])
	if data.has("inactive"):
		en.active = false
	en.defeated.connect(_on_enemy_defeated)
	level_root.add_child(en)
	return en


func enemies_alive() -> int:
	return get_tree().get_nodes_in_group("enemies").size()


# ================================================================ eventos
func _on_player_died() -> void:
	level_finished.emit("dead")


func _on_enemy_defeated(en: Node) -> void:
	if en.has_meta("key"):
		var d = props_by_id.get(en.get_meta("key"))
		if d:
			d.open()
			ui.show_hint("A passagem abriu.", 2.5)


func _on_prop_activated(p: Node) -> void:
	match p.kind:
		"tool":
			flags["tool"] = true
			player.has_tool = true
			_scene_tool()
		"panel":
			var d = props_by_id.get(p.data.get("door", ""))
			if d:
				d.open()
				shake(2.0)
			if p.data.get("door", "") == "d1":
				_scene_cell_open()


func _check_level_logic() -> void:
	if busy or lv.is_empty() or player.dead:
		return
	var px: float = player.position.x
	for trig in lv.get("triggers", []):
		var key: String = lv["id"] + ":" + trig[1]
		if px >= trig[0] and not flags.has(key):
			flags[key] = true
			_on_trigger(trig[1])
	# ondas da arena
	if not wave_queue.is_empty() and enemies_alive() == 0:
		var wave: Array = wave_queue.pop_front()
		for w in wave:
			spawn_enemy(w[0], Vector2(w[1], w[2]))
		if wave_queue.is_empty():
			flags["last_wave"] = true
	elif flags.get("last_wave", false) and enemies_alive() == 0:
		flags.erase("last_wave")
		level_finished.emit("arena")
	# saída
	if lv.has("exit_x") and px >= lv["exit_x"]:
		level_finished.emit("exit")
	# NEX hackeia porta
	if nex_active and Input.is_action_pressed("attack"):
		for p in props_by_id.values():
			if p.kind == "nexdoor" and not p.opened and p.near_player(70.0):
				_scene_nex_hack(p)


func _on_trigger(tid: String) -> void:
	match tid:
		"hint_attack":
			ui.show_hint("AÇÃO = golpe · aperte de novo para o combo de 3", 5.0)
		"hint_steam":
			ui.show_hint("Vapor! BAIXO + PULAR (ou K) = esquiva: passa ileso", 6.0)
		"hint_guard":
			ui.show_hint("O visor pisca antes do golpe. Esquive ou bata primeiro.", 5.0)
		"lab_line":
			await ui.say([["MAREK", "Não olha muito pras cápsulas. Eu ajudei a desenhar isso. Anda."]])
		"lab_heavy":
			ui.show_hint("Carcereiro pesado: o chão avisa antes do impacto.", 5.0)
		"arena":
			_start_arena()
		"mine_explosion":
			_scene_explosion()
		"mine_infiltrator":
			await ui.say([["SILAS", "Bota nova. Arma nova. Isso não é mineiro."],
				["KORD", "Não interessa quem é, Venn. Neutralize.", "radio"]])
		"gallery":
			level_finished.emit("gallery")
		"alarm":
			await ui.say([["NEX", "Pátio externo. Guardas à frente, portão no fim. Eu abro. Você sobrevive."]])


func _start_arena() -> void:
	for x in [30.0, float(lv["width"]) - 30.0]:
		var d := _spawn_prop(["door", x, 300, {}])
		arena_walls.append(d)
	shake(3.0)
	await ui.say([["MAREK", "Hangar. Última porta. Se a gente passar daqui, passou."],
		["SILAS", "Fica atrás de mim."]])
	wave_queue = [
		[["guard", 200, 300], ["guard", 900, 300]],
		[["drone", 300, 190], ["drone", 800, 190], ["guard", 980, 300]],
		[["heavy", 850, 300], ["guard", 150, 300]],
	]


# ================================================================ cenas
func _scene_tool() -> void:
	await ui.say([["SILAS", "Uma chave de manutenção. Você escondeu isso aqui por três anos?"],
		["MAREK", "Três anos, dois meses e onze dias. Agora usa. O painel da porta, à direita."]])
	ui.show_hint("AÇÃO = golpear o painel e sabotar a porta", 5.0)


func _scene_cell_open() -> void:
	await get_tree().create_timer(0.5).timeout
	await ui.say([["MAREK", "Bom. Agora sem barulho. E não me espera: eu sou velho, não sou lento."]])
	if marek:
		marek.follow = true
		marek.carrying = true
	if nex:
		nex.queue_free()
		nex = null


func _scene_explosion() -> void:
	busy = true
	player.controllable = false
	var px: float = player.position.x + 160.0
	shake(10.0)
	fx.explosion(Vector2(px, 296))
	for m in get_tree().get_nodes_in_group("miners"):
		m.pose = "flee"
		var tw := m.create_tween()
		tw.tween_property(m, "position:x", m.position.x - 400.0, 2.0)
		tw.parallel().tween_property(m, "modulate:a", 0.0, 2.0)
	await get_tree().create_timer(0.8).timeout
	await ui.say([["KORD", "Explosão no setor 2. Os terroristas atacaram. Fogo liberado.", "radio"],
		["SILAS", "...Entendido, comandante."]])
	for e in [["infiltrator", px + 120, 300], ["infiltrator", px + 220, 300], ["drill", px + 380, 300]]:
		spawn_enemy(e[0], Vector2(e[1], e[2]))
	busy = false
	player.controllable = true
	ui.show_hint("2051: Silas forte e equipado · segure AÇÃO = rajada", 5.0)


func _scene_nex_hack(door: Node) -> void:
	busy = true
	player.controllable = false
	nex.follow = false
	var tw := nex.create_tween()
	tw.tween_property(nex, "position:x", door.position.x - 14.0, 0.5)
	await tw.finished
	await ui.say([["NEX", "Porta de segurança modelo antigo. Senha: 1-2-3-4. Os humanos me decepcionam."]])
	shake(2.0)
	door.open()
	await get_tree().create_timer(0.6).timeout
	nex.follow = true
	busy = false
	player.controllable = true


# ================================================================ roteiro
func _run_game() -> void:
	if "--from=sacrificio" in OS.get_cmdline_user_args():
		on_title = false
		await _scene_sacrifice()
		await run_level("portao")
		get_tree().quit(0)
		return
	ui.fade = 1.0
	ui.fade_to(0.0, 0.6)
	await ui.card("title", [])
	on_title = false
	await ui.card("text", ["2054.", "HELION, NEXUS e ATLAS: três blocos", "numa guerra fria por energia, chips e minerais."], 0.0)
	await ui.card("news", [], 0.0)
	await ui.card("text", ["Instalação de detenção ÉREBO.", "Na mesma noite."], 3.2)

	await run_level("cela")
	await run_level("corredor")
	await run_level("laboratorio")
	await run_level("hangar")

	# cercados
	await _scene_surrounded()
	await ui.card("era", ["2051", "Três anos antes."], 3.0)

	await run_level("mina")
	await run_level("galeria")
	await _scene_hesitation()
	await ui.card("era", ["2054", "Agora."], 2.6)

	await _scene_sacrifice()
	await run_level("portao")

	await ui.fade_to(1.0, 0.8)
	show_hud = false
	if level_root:
		level_root.queue_free()
		level_root = null
	player = null
	ui.fade = 0.0
	if autotest:
		print("AUTOTEST: FIM OK t=", snappedf(test_t, 0.1))
	await ui.card("text", ["FIM DO PILOTO — FASE 1", "Próximo: o complexo industrial.", "Obrigado por jogar."], 0.0)
	if autotest:
		get_tree().quit(0)
	get_tree().reload_current_scene()


func run_level(id: String) -> void:
	var first := true
	while true:
		await ui.fade_to(1.0, 0.3)
		build_level(id)
		print("FASE: ", id, " t=", snappedf(test_t, 0.1))
		await ui.fade_to(0.0, 0.4)
		if first:
			ui.show_title(lv["title"])
			await get_tree().create_timer(0.3).timeout
			await _level_intro(id)
			first = false
		var result: String = await level_finished
		if result == "dead":
			player.controllable = false
			await get_tree().create_timer(0.9).timeout
			await ui.card("text", ["Silas caiu.", "Tentando de novo..."], 1.4)
			continue
		return


func _level_intro(id: String) -> void:
	match id:
		"cela":
			await ui.say([["MAREK", "Levanta. Segundo a TV, você morreu hoje."],
				["SILAS", "Primeiro a saída. Depois as perguntas."],
				["MAREK", "Primeiro a ferramenta. Canto esquerdo, atrás da cama. Eu que não vou buscar."]])
			ui.show_hint("Direcional: mover · PULAR · AÇÃO", 6.0)
		"mina":
			await ui.say([["KORD", "Venn. A mina parou. Os líderes do protesto são terroristas. Contenha a revolta.", "radio"],
				["SILAS", "Entendido, comandante."],
				["MINEIRO", "As máquinas tomaram o nosso trabalho! A gente só quer comer!"]])
			ui.show_hint("2051: Silas forte e equipado · segure AÇÃO = rajada", 5.0)
		"portao":
			ui.show_hint("NEX te segue. Perto do portão: AÇÃO = NEX hackeia.", 6.0)


func _scene_surrounded() -> void:
	busy = true
	player.controllable = false
	for w in arena_walls:
		if is_instance_valid(w):
			w.queue_free()
	var cx: float = player.position.x
	for i in 6:
		var side := -1.0 if i % 2 == 0 else 1.0
		var g := spawn_enemy("guard", Vector2(cx + side * (90.0 + (i / 2) * 26.0), 300), {"inactive": true})
		g.facing = -int(side)
		g.modulate.a = 0.0
		g.create_tween().tween_property(g, "modulate:a", 1.0, 0.4)
	if marek:
		marek.follow = false
		marek.position.x = cx + 16.0
		marek.facing = -1
	shake(4.0)
	await get_tree().create_timer(0.8).timeout
	await ui.say([["SILAS", "São muitos."],
		["MAREK", "São. Ei. Olha pra mim, não pra eles."],
		["MAREK", "Você lembra por que está aqui?"]])
	await ui.fade_to(1.0, 0.6)
	busy = false


func _scene_hesitation() -> void:
	busy = true
	player.controllable = false
	player.velocity = Vector2.ZERO
	var b = props_by_id.get("baltazar")
	player.facing = 1
	var tw := create_tween()
	tw.tween_property(player, "position:x", b.position.x - 70.0, 0.8)
	await tw.finished
	player.aiming = true
	var ztw := create_tween()
	ztw.tween_property(cam, "zoom", Vector2(2.0, 2.0), 1.2).set_trans(Tween.TRANS_SINE)
	cam.position = Vector2(b.position.x - 35.0, 272)
	await ui.say([["SILAS", "Mãos na cabeça. Acabou."],
		["BALTAZAR", "Então atira, soldado. Eu tô olhando."],
		["KORD", "Venn. Os líderes são terroristas. Você sabe a ordem.", "radio"]])
	# o dedo sai do gatilho
	await get_tree().create_timer(1.2).timeout
	player.aiming = false
	shake(1.0)
	await get_tree().create_timer(1.0).timeout
	await ui.say([["SILAS", "..."],
		["KORD", "Venn? Status.", "radio"],
		["SILAS", "Alvo capturado. Vivo."]])
	var ztw2 := create_tween()
	ztw2.tween_property(cam, "zoom", Vector2(CAM_ZOOM, CAM_ZOOM), 0.6)
	await ui.fade_to(1.0, 0.8)
	cam.zoom = Vector2(CAM_ZOOM, CAM_ZOOM)
	busy = false


func _scene_sacrifice() -> void:
	await ui.fade_to(1.0, 0.01)
	build_level("hangar_volta")
	busy = true
	player.controllable = false
	player.facing = -1
	cam.position = Vector2(540, CAM_Y)
	cam.reset_smoothing()
	await ui.fade_to(0.0, 0.8)
	await ui.say([["SILAS", "Lembrei. De quem eu era."],
		["MAREK", "Ótimo. Então lembra também de quem você quer ser. Agora me escuta."]])
	marek.pose = "cable"
	nex.facing = -1
	await get_tree().create_timer(0.6).timeout
	spark(nex.position + Vector2(0, -12), Color(1.0, 0.7, 0.2))
	nex.nex_on = true
	await ui.say([["MAREK", "Passei tudo pra ele. As rotas, as senhas, o que eu sei sobre o ÉREBO."],
		["SILAS", "Marek. Vem comigo."],
		["MAREK", "Uma ordem não é uma razão, garoto. E eu tenho uma razão pra ficar."],
		["MAREK", "Cuide dele. Ele sabe o caminho."]])
	# o empurrão
	marek.pose = "push"
	var tw := create_tween()
	tw.tween_property(player, "position:x", 700.0, 0.35).set_trans(Tween.TRANS_QUAD)
	tw.parallel().tween_property(nex, "position:x", 680.0, 0.35)
	await tw.finished
	var door = props_by_id.get("blast")
	if door:
		var dtw: Tween = door.create_tween()
		dtw.tween_property(door, "position:y", door.position.y + 66.0, 0.25)
	shake(8.0)
	player.facing = -1
	await get_tree().create_timer(0.8).timeout
	for i in 3:
		shake(4.0)
		spark(Vector2(600, 260 - i * 10), Color(1, 0.3, 0.2))
		await get_tree().create_timer(0.35).timeout
	await get_tree().create_timer(0.8).timeout
	await ui.say([["SILAS", "MAREK!"],
		["NEX", "Sistema ativo. Ordem principal recebida: cuidar de você."],
		["NEX", "Probabilidade de sucesso: baixa. Probabilidade de você tentar mesmo assim: total."],
		["SILAS", "...Então mostra o caminho."]])
	busy = false
	player.controllable = true


# ================================================================ dados das fases
class LEVELS:
	static func get_level(id: String) -> Dictionary:
		var L := {"id": id, "oneway": [], "props": [], "enemies": [], "triggers": [], "era": "2054"}
		match id:
			"cela":
				L.merge({"title": "PRISÃO ÉREBO — CELA 7", "tag": "2054 · ÉREBO", "theme": "cell", "width": 760,
					"spawn": Vector2(150, 300), "exit_x": 740,
					"solids": [[0, 300, 760, 60], [0, 0, 16, 300], [0, 0, 760, 24]],
					"props": [["bed", 140, 300], ["bed", 290, 300], ["tool", 36, 300],
						["marek", 300, 300], ["nex", 330, 300],
						["panel", 640, 300, {"door": "d1"}], ["door", 690, 300, {"id": "d1"}]]}, true)
			"corredor":
				L.merge({"title": "CORREDOR DE MANUTENÇÃO", "tag": "2054 · ÉREBO", "theme": "corridor", "width": 2300,
					"spawn": Vector2(40, 300), "exit_x": 2280,
					"solids": [[0, 300, 2300, 60], [0, 0, 2300, 20], [880, 272, 120, 28], [1520, 258, 90, 42]],
					"oneway": [[1150, 240, 110], [1300, 206, 100], [1720, 236, 120]],
					"props": [["marek", 20, 300, {"follow": true, "carrying": true}],
						["steam", 520, 300], ["steam", 1360, 300], ["steam", 1420, 300],
						["panel", 2060, 300, {"door": "d2"}], ["door", 2120, 300, {"id": "d2"}]],
					"enemies": [["guard", 720, 300], ["drone", 1000, 190], ["guard", 1200, 300],
						["guard", 1760, 300], ["drone", 1900, 180]],
					"triggers": [[60, "hint_attack"], [420, "hint_steam"], [620, "hint_guard"]]}, true)
			"laboratorio":
				L.merge({"title": "LABORATÓRIO DO ÉREBO", "tag": "2054 · ÉREBO", "theme": "lab", "width": 1500,
					"spawn": Vector2(40, 300), "exit_x": 1480,
					"solids": [[0, 300, 1500, 60], [0, 0, 1500, 20], [560, 268, 140, 32]],
					"oneway": [[380, 240, 100], [760, 230, 90]],
					"props": [["marek", 20, 300, {"follow": true, "carrying": true}],
						["capsule", 250, 300], ["capsule", 300, 300], ["capsule", 880, 300], ["capsule", 930, 300],
						["door", 1400, 300, {"id": "d3"}]],
					"enemies": [["guard", 600, 268], ["drone", 820, 180], ["heavy", 1200, 300, {"key": "d3"}]],
					"triggers": [[120, "lab_line"], [1020, "lab_heavy"]]}, true)
			"hangar":
				L.merge({"title": "HANGAR DE SAÍDA", "tag": "2054 · ÉREBO", "theme": "hangar", "width": 1100,
					"spawn": Vector2(80, 300),
					"solids": [[0, 300, 1100, 60]],
					"oneway": [[260, 236, 120], [720, 236, 120]],
					"props": [["marek", 50, 300, {"follow": true, "carrying": true}],
						["crate", 470, 300], ["crate", 640, 300]],
					"triggers": [[330, "arena"]]}, true)
			"mina":
				L.merge({"title": "MINA DE MINERAIS ESTRATÉGICOS", "tag": "2051 · SILAS, SOLDADO", "theme": "mine", "width": 2500,
					"era": "2051", "spawn": Vector2(40, 300), "exit_x": 2480,
					"solids": [[0, 300, 2500, 60], [1300, 270, 160, 30], [1460, 244, 120, 56], [1900, 266, 140, 34]],
					"oneway": [[1640, 220, 110]],
					"props": [["miner", 330, 300], ["miner", 360, 300], ["miner", 400, 300], ["miner", 450, 300], ["miner", 520, 300]],
					"enemies": [["infiltrator", 1520, 244], ["drill", 1760, 300], ["infiltrator", 2000, 266],
						["infiltrator", 2250, 300], ["drill", 2380, 300]],
					"triggers": [[560, "mine_explosion"], [1100, "mine_infiltrator"]]}, true)
			"galeria":
				L.merge({"title": "GALERIA FUNDA", "tag": "2051 · SILAS, SOLDADO", "theme": "gallery", "width": 760,
					"era": "2051", "spawn": Vector2(40, 300),
					"solids": [[0, 300, 760, 60], [0, 0, 760, 18]],
					"props": [["beam", 560, 300], ["baltazar", 560, 300, {"id": "baltazar", "pose": "kneel"}]],
					"triggers": [[380, "gallery"]]}, true)
			"hangar_volta":
				L.merge({"title": "", "tag": "2054 · ÉREBO", "theme": "hangar", "width": 760,
					"spawn": Vector2(470, 300), "player_facing": -1,
					"solids": [[0, 300, 760, 60]],
					"props": [["marek", 430, 300, {"pose": "kneel"}], ["nex", 455, 300],
						["door", 600, 300, {"id": "blast"}]],
					"enemies": [["guard", 140, 300, {"inactive": true}], ["guard", 180, 300, {"inactive": true}],
						["guard", 230, 300, {"inactive": true}], ["heavy", 90, 300, {"inactive": true}]]}, true)
				L["props"][2][3]["start_open"] = true
			"portao":
				L.merge({"title": "PÁTIO EXTERNO — PORTÃO", "tag": "2054 · FUGA", "theme": "night", "width": 1800,
					"spawn": Vector2(40, 300), "exit_x": 1780,
					"solids": [[0, 300, 1800, 60], [620, 266, 120, 34], [1180, 262, 100, 38]],
					"oneway": [[900, 230, 110]],
					"props": [["nex", 20, 300, {"follow": true, "on": true}], ["crate", 420, 300], ["crate", 1000, 300],
						["nexdoor", 1680, 300, {"id": "gate"}]],
					"enemies": [["guard", 560, 300], ["drone", 860, 180], ["guard", 1300, 300], ["drone", 1450, 170], ["guard", 1560, 300]],
					"triggers": [[200, "alarm"]]}, true)
		return L
