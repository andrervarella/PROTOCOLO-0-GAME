extends Node2D
## Objetos de cenário e personagens de apoio (arte provisória desenhada em código).
## kind: tool (ferramenta de manutenção), panel (painel sabotável), door, nexdoor,
##       steam (vapor), marek, nex, baltazar, miner, beam (feixe de luz), capsule, crate

signal activated(prop)

var main: Node
var kind := ""
var id := ""
var data := {}
var t := 0.0
var hp := 2
var opened := false
var on := false
var body: StaticBody2D
var follow := false
var npc_vel := Vector2.ZERO
var facing := 1
var pose := ""  # poses de cena: "kneel", "push", "down", "cable", "boot", "flee"
var picked := false
var flash := 0.0
var nex_on := false
var carrying := false  # Marek carrega o NEX desligado


func setup(p_main: Node, p_kind: String, pos: Vector2, p_data := {}) -> void:
	main = p_main
	kind = p_kind
	position = pos
	data = p_data
	id = str(p_data.get("id", ""))
	t = randf() * 2.0
	match kind:
		"panel":
			add_to_group("hittable")
		"door", "nexdoor":
			body = StaticBody2D.new()
			body.collision_layer = 1
			var cs := CollisionShape2D.new()
			var rs := RectangleShape2D.new()
			rs.size = Vector2(14, 70)
			cs.shape = rs
			cs.position = Vector2(0, -35)
			body.add_child(cs)
			add_child(body)
		"miner":
			facing = -1 if randf() < 0.5 else 1
	if data.get("pose", "") != "":
		pose = data["pose"]
	follow = data.get("follow", false)
	nex_on = data.get("on", false)
	carrying = data.get("carrying", false)
	if kind == "miner":
		add_to_group("miners")
	if data.get("start_open", false):
		opened = true
		position.y -= 66.0
		if body:
			body.queue_free()
			body = null


func hit_rect() -> Rect2:
	if kind == "panel":
		return Rect2(global_position + Vector2(-8, -40), Vector2(16, 22))
	return Rect2(global_position, Vector2.ONE)


func take_hit(_dmg: int, _from_x: float) -> void:
	if kind != "panel" or opened:
		return
	hp -= 1
	flash = 0.15
	if main:
		main.spark(global_position + Vector2(0, -30), Color(0.5, 0.8, 1.0))
	if hp <= 0:
		opened = true
		remove_from_group("hittable")
		activated.emit(self)


func open() -> void:
	if opened and kind != "panel":
		return
	opened = true
	if body:
		body.queue_free()
		body = null
	var tw := create_tween()
	tw.tween_property(self, "position:y", position.y - 66.0, 0.6).set_trans(Tween.TRANS_QUAD)


func close_door() -> void:
	opened = false
	position.y += 66.0


func _process(delta: float) -> void:
	t += delta
	flash = max(0.0, flash - delta)
	if kind == "steam":
		var cycle := fmod(t, 2.8)
		on = cycle > 1.5
		if on and main and main.player and not main.player.dead:
			var r := Rect2(global_position + Vector2(-9, -60), Vector2(18, 60))
			if r.intersects(main.player.hit_rect()):
				main.player.take_hit(1, global_position.x)
	elif kind == "tool" and not picked and main and main.player:
		if global_position.distance_to(main.player.global_position + Vector2(0, -10)) < 22.0:
			picked = true
			activated.emit(self)
			queue_free()
	elif kind in ["marek", "nex"] and follow and main and main.player:
		_follow(delta)
	queue_redraw()


func _follow(delta: float) -> void:
	var p: Node2D = main.player
	var gap := 34.0 if kind == "marek" else 22.0
	var target_x: float = p.global_position.x - p.facing * gap
	var dx: float = target_x - global_position.x
	if absf(dx) > 260.0:
		global_position.x = p.global_position.x - p.facing * gap
		global_position.y = main.floor_y_at(global_position.x)
		return
	var spd := 120.0 if kind == "marek" else 150.0
	if absf(dx) > 6.0:
		global_position.x += clamp(dx, -1.0, 1.0) * spd * delta
		facing = 1 if dx > 0 else -1
		npc_vel.x = sign(dx)
	else:
		npc_vel.x = 0.0
		facing = p.facing
	global_position.y = move_toward(global_position.y, main.floor_y_at(global_position.x), 400.0 * delta)


func near_player(dist := 40.0) -> bool:
	return main and main.player and absf(main.player.global_position.x - global_position.x) < dist


# ---------------------------------------------------------------- desenho provisório
func _draw() -> void:
	match kind:
		"tool": _d_tool()
		"panel": _d_panel()
		"door": _d_door(Color("3a3f47"), Color("a3191f"))
		"nexdoor": _d_door(Color("2f3540"), Color("e0a030"))
		"steam": _d_steam()
		"marek": _d_marek()
		"nex": _d_nex()
		"baltazar": _d_baltazar()
		"miner": _d_miner()
		"beam": _d_beam()
		"capsule": _d_capsule()
		"crate": _d_crate()
		"bed": _d_bed()


func _d_tool() -> void:
	var bob := sin(t * 3.0) * 2.0
	draw_circle(Vector2(0, -10 + bob), 10.0, Color(1.0, 0.8, 0.3, 0.12 + 0.08 * sin(t * 5.0)))
	draw_line(Vector2(-6, -6 + bob), Vector2(5, -14 + bob), Color("9aa0a6"), 2.0)
	draw_rect(Rect2(3, -17 + bob, 5, 5), Color("c0c6cc"))


func _d_panel() -> void:
	var c := Color("1c2430") if not opened else Color("111418")
	draw_rect(Rect2(-8, -40, 16, 22), Color(1, 1, 1) if flash > 0.0 else c)
	draw_rect(Rect2(-8, -40, 16, 22), Color("5a6472"), false, 1.0)
	if not opened:
		var blink := 0.5 + 0.5 * sin(t * 6.0)
		draw_rect(Rect2(-4, -35, 8, 3), Color(0.3, 0.8, 1.0, 0.4 + 0.6 * blink))
		draw_rect(Rect2(-4, -29, 3, 3), Color("a3191f"))
		draw_rect(Rect2(1, -29, 3, 3), Color("a3191f"))
		if near_player(60.0) and main.player.has_tool:
			draw_string(ThemeDB.fallback_font, Vector2(-26, -48), "SABOTAR", HORIZONTAL_ALIGNMENT_CENTER, 52, 8, Color(1, 0.85, 0.5, 0.6 + 0.4 * blink))
	else:
		for i in 3:
			draw_line(Vector2(-6 + i * 5, -30), Vector2(-4 + i * 5, -22 + sin(t * 9.0 + i) * 2.0), Color(0.4, 0.7, 1.0, 0.5), 1.0)
	draw_line(Vector2(0, -18), Vector2(0, 0), Color("2a2e35"), 2.0)


func _d_door(c: Color, light: Color) -> void:
	draw_rect(Rect2(-7, -70, 14, 70), c)
	for i in 6:
		draw_line(Vector2(-7, -64 + i * 11), Vector2(7, -60 + i * 11), Color(0, 0, 0, 0.35), 2.0)
	draw_rect(Rect2(-7, -70, 14, 70), Color("1a1d22"), false, 1.0)
	draw_rect(Rect2(-3, -40, 6, 3), light if not opened else Color("2a2a2a"))
	if kind == "nexdoor" and not opened and near_player(70.0) and main.nex_active:
		var blink := 0.5 + 0.5 * sin(t * 6.0)
		draw_string(ThemeDB.fallback_font, Vector2(-40, -78), "NEX: HACKEAR", HORIZONTAL_ALIGNMENT_CENTER, 80, 8, Color(1, 0.75, 0.3, 0.6 + 0.4 * blink))


func _d_steam() -> void:
	draw_rect(Rect2(-6, -6, 12, 6), Color("3a3f47"))
	var cycle := fmod(t, 2.8)
	if cycle > 1.2 and cycle <= 1.5:
		for i in 3:
			draw_circle(Vector2(sin(t * 20.0 + i) * 3.0, -8 - i * 4), 2.0, Color(1, 1, 1, 0.3))
	if on:
		for i in 9:
			var yy := -6.0 - fmod(t * 120.0 + i * 7.0, 60.0)
			var a := 0.55 * (1.0 + yy / 60.0)
			draw_circle(Vector2(sin(t * 7.0 + i) * 4.0, yy), 5.0 + (-yy) * 0.06, Color(0.9, 0.92, 0.95, a))


func _d_marek() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1))
	var walk := sin(t * 10.0) * 3.0 if absf(npc_vel.x) > 0.1 else 0.0
	var uni := Color("b3a78f")
	if pose == "down":
		draw_rect(Rect2(-16, -8, 26, 8), uni)
		draw_rect(Rect2(10, -9, 8, 8), Color("c9a88a"))
		draw_rect(Rect2(10, -10, 8, 3), Color("e8e8e8"))
		return
	var kneel := pose in ["kneel", "cable"]
	var base := -10.0 if kneel else 0.0
	if not kneel:
		draw_rect(Rect2(-4 + walk * 0.5, -12, 3, 12), Color("8c826d"))
		draw_rect(Rect2(1 - walk * 0.5, -12, 3, 12), Color("8c826d"))
	else:
		draw_rect(Rect2(-6, -6, 12, 6), Color("8c826d"))
	# corpo encurvado
	var k := 10.0 if kneel else 0.0
	var hx := 2.0
	draw_rect(Rect2(-5 + hx, -24 + k, 10, 13), uni)
	draw_rect(Rect2(-5 + hx, -14 + k, 10, 2), Color("6f6754"))
	var hy := -31.0 + k
	draw_rect(Rect2(-1 + hx, hy, 8, 8), Color("c9a88a"))
	draw_rect(Rect2(-1 + hx, hy - 1, 8, 2), Color("dcdcdc"))  # cabelo branco ralo
	draw_rect(Rect2(2 + hx, hy + 1, 6, 2), Color("ffffff"))  # sobrancelhas enormes
	draw_rect(Rect2(3 + hx, hy + 3, 4, 2), Color("2a2a2a"))  # óculos
	draw_rect(Rect2(4 + hx, hy + 3, 1, 2), Color("e8c22a"))  # fita amarela
	if carrying:
		draw_circle(Vector2(-3, -17), 5.0, Color("d6d2c8"))  # NEX desligado no colo
		draw_rect(Rect2(-6, -20, 6, 4), Color("1c1c1c"))
	if pose == "cable":
		draw_line(Vector2(8, -14 + 10), Vector2(22, -4), Color("d08a20"), 1.0)
	if pose == "push":
		draw_line(Vector2(6, -20), Vector2(16, -20), uni, 3.0)


func _d_nex() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1))
	var walk := sin(t * 16.0) * 2.0 if absf(npc_vel.x) > 0.1 else 0.0
	var boot := nex_on
	draw_line(Vector2(-3, -6), Vector2(-3 + walk, 0), Color("8a8e94"), 1.0)
	draw_line(Vector2(3, -6), Vector2(3 - walk, 0), Color("8a8e94"), 1.0)
	draw_circle(Vector2(0, -11), 7.0, Color("d6d2c8"))
	draw_rect(Rect2(-5, -15, 10, 7), Color("1c1c1c"))
	if boot:
		var blink := int(t * 0.7) % 5 == 0 and fmod(t, 1.43) < 0.12
		var ec := Color("ffb030")
		if not blink:
			draw_line(Vector2(-3, -12), Vector2(-1, -12), ec, 1.0)
			draw_line(Vector2(1, -12), Vector2(3, -12), ec, 1.0)
		else:
			draw_line(Vector2(-3, -11), Vector2(3, -11), ec, 1.0)
	draw_line(Vector2(2, -18), Vector2(4, -22), Color("8a8e94"), 1.0)  # antena torta
	draw_line(Vector2(4, -22), Vector2(7, -23), Color("8a8e94"), 1.0)
	draw_circle(Vector2(7, -23), 1.0, Color("ffb030") if boot else Color("555555"))
	draw_rect(Rect2(-5, -6, 3, 2), Color("c8b050"))  # adesivo velho do mentor


func _d_baltazar() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1))
	var kneel := pose == "kneel"
	var dy := 9.0 if kneel else 0.0
	if not kneel:
		draw_rect(Rect2(-8, -14, 6, 14), Color("4a3a2a"))
		draw_rect(Rect2(2, -14, 6, 14), Color("4a3a2a"))
	else:
		draw_rect(Rect2(-10, -6, 20, 6), Color("4a3a2a"))
	draw_rect(Rect2(-11, -34 + dy, 22, 22), Color("c76a22"))  # colete laranja
	draw_rect(Rect2(-11, -26 + dy, 22, 2), Color("e6d26a"))
	draw_rect(Rect2(-5, -44 + dy, 11, 10), Color("5a3a26"))
	draw_rect(Rect2(-5, -37 + dy, 11, 4), Color("8a8a8a"))  # barba grisalha
	draw_rect(Rect2(-6, -48 + dy, 13, 5), Color("d8b020"))  # capacete
	draw_rect(Rect2(5, -47 + dy, 3, 3), Color("3a3a3a"))  # lanterna quebrada
	draw_rect(Rect2(2, -41 + dy, 2, 2), Color("1a1a1a"))


func _d_miner() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1))
	var arm := sin(t * 5.0) * 5.0 if pose != "flee" else 0.0
	draw_rect(Rect2(-4, -12, 3, 12), Color("3a3328"))
	draw_rect(Rect2(1, -12, 3, 12), Color("3a3328"))
	draw_rect(Rect2(-6, -24, 12, 12), Color("a85a20"))
	draw_rect(Rect2(-4, -31, 8, 7), Color("7a5038"))
	draw_rect(Rect2(-5, -33, 10, 3), Color("c9a020"))
	if pose != "flee":
		draw_line(Vector2(3, -22), Vector2(6, -32 + arm), Color("a85a20"), 2.0)


func _d_beam() -> void:
	var w := 60.0
	var pts := PackedVector2Array([Vector2(-12, -360), Vector2(12, -360), Vector2(w, 0), Vector2(-w, 0)])
	draw_colored_polygon(pts, Color(1.0, 0.85, 0.55, 0.1 + 0.02 * sin(t * 2.0)))
	for i in 10:
		var px := sin(t * 0.3 + i * 1.7) * 30.0
		var py := -fmod(t * 6.0 + i * 37.0, 300.0)
		draw_circle(Vector2(px, py), 0.8, Color(1, 0.9, 0.7, 0.5))


func _d_capsule() -> void:
	draw_rect(Rect2(-12, -70, 24, 70), Color(0.35, 0.5, 0.45, 0.25))
	draw_rect(Rect2(-12, -70, 24, 70), Color("4a5560"), false, 2.0)
	draw_rect(Rect2(-14, -74, 28, 6), Color("2a2f36"))
	draw_rect(Rect2(-14, -4, 28, 4), Color("2a2f36"))
	for i in 4:
		draw_circle(Vector2(sin(t + i) * 6.0, -10 - fmod(t * 14.0 + i * 15.0, 56.0)), 1.2, Color(0.7, 0.9, 0.8, 0.4))


func _d_crate() -> void:
	draw_rect(Rect2(-16, -26, 32, 26), Color("3a3328"))
	draw_rect(Rect2(-16, -26, 32, 26), Color("221e18"), false, 2.0)
	draw_line(Vector2(-16, -26), Vector2(16, 0), Color("221e18"), 2.0)


func _d_bed() -> void:
	draw_rect(Rect2(-24, -14, 48, 5), Color("7a7e84"))
	draw_rect(Rect2(-24, -9, 3, 9), Color("4a4e54"))
	draw_rect(Rect2(21, -9, 3, 9), Color("4a4e54"))
	draw_rect(Rect2(-22, -17, 12, 3), Color("c8c8c0"))
