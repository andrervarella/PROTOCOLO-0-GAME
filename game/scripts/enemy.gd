extends CharacterBody2D
## Inimigos do piloto. Regra de gênero: encostar NÃO causa dano, só golpes com aviso visual.
## kind: guard (guarda ÉREBO), drone, heavy (carcereiro pesado),
##       infiltrator (sabotador mascarado, 2051), drill (máquina perfuratriz, 2051)

signal defeated(enemy)

const GRAVITY := 980.0
var main: Node
var kind := "guard"
var hp := 3
var max_hp := 3
var facing := -1
var state := "idle"
var t := 0.0
var anim_t := 0.0
var flash := 0.0
var home := Vector2.ZERO
var patrol := 60.0
var size := Vector2(14, 32)
var dead := false
var active := true
var hit_done := false
var dive_target := Vector2.ZERO
var stagger := 0.0


func setup(p_main: Node, p_kind: String, pos: Vector2) -> void:
	main = p_main
	kind = p_kind
	position = pos
	home = pos
	match kind:
		"guard":
			hp = 3; size = Vector2(14, 32)
		"drone":
			hp = 2; size = Vector2(16, 12)
		"heavy":
			hp = 9; size = Vector2(24, 42)
		"infiltrator":
			hp = 3; size = Vector2(14, 32)
		"drill":
			hp = 4; size = Vector2(30, 18)
	max_hp = hp
	collision_layer = 4
	collision_mask = 1
	if kind != "drone":
		var cs := CollisionShape2D.new()
		var rs := RectangleShape2D.new()
		rs.size = size
		cs.shape = rs
		cs.position = Vector2(0, -size.y / 2.0)
		add_child(cs)
	add_to_group("hittable")
	add_to_group("enemies")
	anim_t = randf() * 3.0


func hit_rect() -> Rect2:
	if kind == "drone":
		return Rect2(global_position - size / 2.0, size)
	return Rect2(global_position + Vector2(-size.x / 2.0, -size.y), size)


func _player() -> Node2D:
	return main.player if main else null


func take_hit(dmg: int, from_x: float) -> void:
	if dead:
		return
	hp -= dmg
	flash = 0.12
	if kind != "heavy" or dmg >= 2:
		stagger = 0.18
		if state == "windup" and kind != "heavy":
			state = "recover"; t = 0.35
		if kind != "drone":
			velocity.x = (1.0 if global_position.x > from_x else -1.0) * (90.0 if kind == "heavy" else 140.0)
	if hp <= 0:
		dead = true
		remove_from_group("hittable")
		remove_from_group("enemies")
		if main:
			main.burst(hit_rect().get_center(), Color(1.0, 0.5, 0.2) if kind in ["drone", "drill"] else Color(0.9, 0.2, 0.2))
		defeated.emit(self)
		var tw := create_tween()
		tw.tween_property(self, "modulate:a", 0.0, 0.25)
		tw.tween_callback(queue_free)


func _physics_process(delta: float) -> void:
	anim_t += delta
	flash = max(0.0, flash - delta)
	stagger = max(0.0, stagger - delta)
	queue_redraw()
	if dead:
		return
	var p := _player()
	if kind == "drone":
		_drone(delta, p)
		return
	if not is_on_floor():
		velocity.y = min(velocity.y + GRAVITY * delta, 520.0)
	if stagger > 0.0 or not active or p == null or p.dead:
		velocity.x = move_toward(velocity.x, 0.0, 500.0 * delta)
		move_and_slide()
		return
	match kind:
		"guard", "heavy":
			_melee(delta, p)
		"infiltrator":
			_shooter(delta, p)
		"drill":
			_drill(delta, p)
	move_and_slide()


func _dist(p: Node2D) -> Vector2:
	return p.global_position - global_position


func _melee(delta: float, p: Node2D) -> void:
	var d := _dist(p)
	var reach := 34.0 if kind == "guard" else 46.0
	var spd := 62.0 if kind == "guard" else 40.0
	var wind := 0.42 if kind == "guard" else 0.75
	t -= delta
	match state:
		"idle", "patrol":
			if absf(d.x) < 230.0 and absf(d.y) < 60.0:
				state = "chase"
			else:
				state = "patrol"
				var tx := home.x + sin(anim_t * 0.6) * patrol
				velocity.x = clamp(tx - global_position.x, -1.0, 1.0) * 35.0
				if absf(velocity.x) > 1.0:
					facing = 1 if velocity.x > 0 else -1
		"chase":
			facing = 1 if d.x > 0 else -1
			if absf(d.x) < reach - 6.0 and absf(d.y) < 40.0:
				state = "windup"; t = wind; velocity.x = 0.0
			elif absf(d.x) > 320.0:
				state = "patrol"
			else:
				velocity.x = facing * spd
		"windup":
			velocity.x = 0.0
			if t <= 0.0:
				state = "strike"; t = 0.14; hit_done = false
				if kind == "heavy" and main:
					main.shake(5.0)
		"strike":
			velocity.x = facing * (40.0 if kind == "guard" else 0.0)
			if not hit_done:
				var r: Rect2
				if kind == "heavy":
					r = Rect2(global_position + Vector2(-60, -18), Vector2(120, 18))
				else:
					r = Rect2(global_position + Vector2(0 if facing > 0 else -reach, -30), Vector2(reach, 22))
				if r.intersects(p.hit_rect()):
					p.take_hit(1 if kind == "guard" else 2, global_position.x)
					hit_done = true
			if t <= 0.0:
				state = "recover"; t = 0.6 if kind == "guard" else 0.9
		"recover":
			velocity.x = move_toward(velocity.x, 0.0, 400.0 * delta)
			if t <= 0.0:
				state = "chase"


func _shooter(delta: float, p: Node2D) -> void:
	var d := _dist(p)
	t -= delta
	match state:
		"idle", "patrol", "chase":
			if absf(d.x) < 300.0 and absf(d.y) < 80.0:
				facing = 1 if d.x > 0 else -1
				if absf(d.x) < 110.0:
					velocity.x = -facing * 55.0  # mantém distância
				else:
					velocity.x = move_toward(velocity.x, 0.0, 300.0 * delta)
				if t <= 0.0:
					state = "windup"; t = 0.6
			else:
				velocity.x = move_toward(velocity.x, 0.0, 300.0 * delta)
		"windup":
			velocity.x = 0.0
			facing = 1 if d.x > 0 else -1
			if t <= 0.0:
				if main:
					main.spawn_bullet(global_position + Vector2(facing * 14, -22), Vector2(facing * 230.0, 0), "enemy", 1)
				state = "chase"; t = randf_range(1.1, 1.6)


func _drill(delta: float, p: Node2D) -> void:
	var d := _dist(p)
	t -= delta
	match state:
		"idle", "patrol", "chase":
			velocity.x = move_toward(velocity.x, 0.0, 400.0 * delta)
			if absf(d.x) < 260.0 and absf(d.y) < 50.0 and t <= 0.0:
				facing = 1 if d.x > 0 else -1
				state = "windup"; t = 0.7
		"windup":
			if t <= 0.0:
				state = "strike"; t = 0.9; hit_done = false
		"strike":
			velocity.x = facing * 230.0
			if not hit_done and hit_rect().grow(2).intersects(p.hit_rect()):
				p.take_hit(1, global_position.x)
				hit_done = true
			if t <= 0.0 or is_on_wall():
				state = "recover"; t = 1.0
				if is_on_wall() and main:
					main.shake(3.0)
		"recover":
			velocity.x = move_toward(velocity.x, 0.0, 500.0 * delta)
			if t <= 0.0:
				state = "chase"; t = 0.3


func _drone(delta: float, p: Node2D) -> void:
	t -= delta
	if stagger > 0.0 or p == null or p.dead or not active:
		position.y = move_toward(position.y, home.y, 40.0 * delta)
		return
	var d := _dist(p)
	match state:
		"idle", "patrol", "chase":
			var tx: float = home.x + sin(anim_t) * 40.0
			if absf(d.x) < 260.0:
				tx = p.global_position.x - (70.0 if d.x > 0.0 else -70.0)
			position.x = move_toward(position.x, tx, 55.0 * delta)
			position.y = home.y + sin(anim_t * 2.5) * 6.0
			facing = 1 if d.x > 0 else -1
			if absf(d.x) < 160.0 and t <= 0.0:
				state = "windup"; t = 0.65
		"windup":
			if t <= 0.0:
				dive_target = p.global_position + Vector2(0, -16)
				state = "strike"; hit_done = false
		"strike":
			position = position.move_toward(dive_target, 260.0 * delta)
			if not hit_done and hit_rect().intersects(p.hit_rect()):
				p.take_hit(1, global_position.x)
				hit_done = true
			if position.distance_to(dive_target) < 3.0:
				state = "recover"; t = 1.4
		"recover":
			position = position.move_toward(Vector2(position.x, home.y), 80.0 * delta)
			if t <= 0.0:
				state = "chase"; t = 0.8


# ---------------------------------------------------------------- desenho provisório
func _draw() -> void:
	var f := float(facing)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(f, 1.0))
	var warn := state == "windup" and int(anim_t * 16.0) % 2 == 0
	var white := flash > 0.0
	match kind:
		"guard": _draw_guard(warn, white, false)
		"heavy": _draw_heavy(warn, white)
		"infiltrator": _draw_guard(warn, white, true)
		"drone": _draw_drone(warn, white)
		"drill": _draw_drill(warn, white)


func _c(c: Color, white: bool) -> Color:
	return Color(1, 1, 1) if white else c


func _draw_guard(warn: bool, white: bool, masked: bool) -> void:
	var swing := sin(anim_t * 10.0) * 4.0 if absf(velocity.x) > 5.0 else 0.0
	var armor := Color("2b2f36") if not masked else Color("4a3b2c")
	var dark := Color("17191d") if not masked else Color("2b2219")
	draw_rect(Rect2(-5 + swing * 0.5, -13, 4, 13), _c(dark, white))
	draw_rect(Rect2(1 - swing * 0.5, -13, 4, 13), _c(dark, white))
	draw_rect(Rect2(-7, -26, 14, 14), _c(armor, white))
	draw_rect(Rect2(-5, -34, 10, 9), _c(dark if not masked else Color("1d1d1d"), white))
	if masked:
		draw_rect(Rect2(0, -31, 5, 2), _c(Color("c9a24a"), white))  # olhos pela máscara
		draw_rect(Rect2(-7, -15, 14, 2), _c(Color("6b5a3a"), white))
		var gun_y := -22.0
		draw_rect(Rect2(2, gun_y, 13, 3), _c(Color("111111"), white))
		if state == "windup":
			draw_line(Vector2(15, gun_y + 1), Vector2(300, gun_y + 1), Color(1, 0.2, 0.2, 0.35 if not warn else 0.7), 1.0)
	else:
		draw_rect(Rect2(0, -31, 5, 2), _c(Color("ff2a2a") if not warn else Color("ffffff"), white))  # visor vermelho
		var ang := -1.4 if state == "windup" else (0.6 if state == "strike" else -0.3)
		var sh := Vector2(2, -23)
		var tip := sh + Vector2(18, 0).rotated(ang)
		draw_line(sh, tip, _c(Color("3a3f46"), white), 2.0)
		draw_line(tip - Vector2(6, 0).rotated(ang), tip, _c(Color("ff4040") if warn else Color("8a8f96"), white), 2.0)
	if warn:
		draw_rect(Rect2(-2, -44, 4, 6), Color(1, 0.3, 0.2))


func _draw_heavy(warn: bool, white: bool) -> void:
	var a := Color("2a2d33")
	draw_rect(Rect2(-10, -16, 8, 16), _c(Color("16181b"), white))
	draw_rect(Rect2(2, -16, 8, 16), _c(Color("16181b"), white))
	draw_rect(Rect2(-13, -36, 26, 22), _c(a, white))
	draw_rect(Rect2(-13, -30, 26, 3), _c(Color("7a1414"), white))
	draw_rect(Rect2(-7, -44, 14, 9), _c(Color("101113"), white))
	draw_rect(Rect2(-5, -41, 10, 2), _c(Color("ff2a2a") if not warn else Color("ffffff"), white))
	var raise := -18.0 if state == "windup" else (6.0 if state == "strike" else 0.0)
	draw_rect(Rect2(-20, -34 + raise, 8, 16), _c(Color("3c4048"), white))
	draw_rect(Rect2(12, -34 + raise, 8, 16), _c(Color("3c4048"), white))
	if state == "windup":
		var a2 := 0.25 + 0.35 * float(warn)
		draw_rect(Rect2(-60, -3, 120, 3), Color(1, 0.2, 0.15, a2))


func _draw_drone(warn: bool, white: bool) -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var body := Color("3a3e45")
	draw_rect(Rect2(-8, -5, 16, 9), _c(body, white))
	draw_rect(Rect2(-11, -8, 22, 2), _c(Color("5c616a"), white))
	var blade := 9.0 * absf(sin(anim_t * 30.0))
	draw_line(Vector2(-blade, -9), Vector2(blade, -9), Color(0.8, 0.8, 0.8, 0.6), 1.0)
	draw_circle(Vector2(0, 0), 2.5, _c(Color("ff2a2a") if not warn else Color("ffffff"), white))
	if warn:
		draw_arc(Vector2.ZERO, 12.0, 0, TAU, 16, Color(1, 0.2, 0.2, 0.6), 1.0)


func _draw_drill(warn: bool, white: bool) -> void:
	draw_rect(Rect2(-15, -14, 24, 12), _c(Color("8a5a1e"), white))
	draw_rect(Rect2(-15, -14, 24, 3), _c(Color("c98a2a"), white))
	draw_rect(Rect2(-13, -4, 6, 4), _c(Color("1a1a1a"), white))
	draw_rect(Rect2(1, -4, 6, 4), _c(Color("1a1a1a"), white))
	var spin := int(anim_t * (40.0 if state == "strike" else 6.0)) % 2
	var pts := PackedVector2Array([Vector2(9, -14), Vector2(22 + spin, -8), Vector2(9, -2)])
	draw_colored_polygon(pts, _c(Color("b8bcc2") if not warn else Color("ff5030"), white))
	draw_circle(Vector2(-4, -9), 2.0, _c(Color("ffb020"), white))
