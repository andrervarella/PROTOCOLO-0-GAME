extends Node2D
## Desenha o cenário provisório: fundo em camadas (parallax) + chão/plataformas.
## Quando chegarem as imagens dos lotes 5 e 6, trocar por Sprite2D/Parallax2D.

var main: Node
var lv := {}
var t := 0.0


func _process(delta: float) -> void:
	t += delta
	queue_redraw()


func _cam_x() -> float:
	return main.cam.get_screen_center_position().x if main and main.cam else 0.0


func _draw() -> void:
	if lv.is_empty():
		return
	var w: float = lv["width"]
	var cx := _cam_x()
	var vw: float = get_viewport_rect().size.x
	var left := cx - vw / 2.0 - 20.0
	var right := cx + vw / 2.0 + 20.0
	match lv["theme"]:
		"cell", "corridor", "lab", "hangar":
			_bg_prison(left, right, cx, lv["theme"])
		"mine", "gallery":
			_bg_mine(left, right, cx, lv["theme"])
		"night":
			_bg_night(left, right, cx)
	_solids(w)


func _par(x: float, cx: float, f: float) -> float:
	return x + cx * f


func _bg_prison(l: float, r: float, cx: float, theme: String) -> void:
	var wall := Color("23272d")
	if theme == "lab":
		wall = Color("2a3134")
	elif theme == "hangar":
		wall = Color("181b20")
	draw_rect(Rect2(l, 0, r - l, 300), wall)
	# camada distante: colunas e canos
	var step := 140.0
	var off := fmod(cx * 0.5, step)
	var x := l - off - step
	while x < r + step:
		var px := x
		draw_rect(Rect2(px, 0, 18, 300), wall.darkened(0.25))
		draw_rect(Rect2(px + 40, 40, 6, 260), wall.lightened(0.06))
		x += step
	# luzes de emergência vermelhas
	var step2 := 260.0
	var off2 := fmod(cx * 0.3, step2)
	x = l - off2 - step2
	var i := 0
	while x < r + step2:
		var blink := 0.5 + 0.5 * sin(t * 4.0 + i)
		draw_circle(Vector2(x + 100, 46), 4.0, Color(0.9, 0.1, 0.1, 0.5 + 0.5 * blink))
		draw_circle(Vector2(x + 100, 46), 20.0, Color(0.9, 0.1, 0.1, 0.06 * blink))
		x += step2
		i += 1
	if theme == "cell":
		# rabiscos de cálculos na parede (sem letras legíveis)
		for k in 14:
			var p := Vector2(330 + (k % 7) * 30, 120 + (k / 7) * 34)
			draw_line(p, p + Vector2(18, -6 + (k % 3) * 4), Color(0.75, 0.75, 0.7, 0.25), 1.0)
			draw_arc(p + Vector2(8, 10), 5.0, 0, PI * 1.5, 8, Color(0.75, 0.75, 0.7, 0.2), 1.0)
	if theme == "hangar":
		# holofotes cruzando
		for k in 3:
			var ang := sin(t * 0.6 + k * 2.0) * 0.5
			var o := Vector2(200 + k * 350, 0)
			var tip := o + Vector2(0, 300).rotated(ang)
			draw_colored_polygon(PackedVector2Array([o, tip + Vector2(-40, 0), tip + Vector2(40, 0)]), Color(0.9, 0.95, 1.0, 0.05))
		draw_rect(Rect2(l, 120, r - l, 6), Color("2c3138"))  # passarela no alto
	if theme == "lab":
		for k in 6:
			var bx := 120.0 + k * 220.0
			draw_rect(Rect2(bx, 60, 70, 40), Color("1a1f22"))
			draw_rect(Rect2(bx + 4, 64, 62, 32), Color(0.2, 0.4, 0.38, 0.15))


func _bg_mine(l: float, r: float, cx: float, theme: String) -> void:
	if theme == "gallery":
		draw_rect(Rect2(l, 0, r - l, 300), Color("120d0a"))
		for k in 12:
			var x := fmod(k * 97.0 - cx * 0.2, r - l + 200.0) + l - 100.0
			draw_rect(Rect2(x, 0, 60, 300), Color("1a1410"))
		return
	# céu de fim de tarde poluído
	for k in 10:
		var c := Color("c7743a").lerp(Color("3a2a2a"), k / 10.0)
		draw_rect(Rect2(l, k * 20, r - l, 21), c)
	# montanhas em degraus (parallax lento)
	var pts := PackedVector2Array()
	var x := l - fmod(cx * 0.15, 40.0) - 40.0
	pts.append(Vector2(l - 50, 300))
	while x < r + 50:
		var h := 120.0 + 40.0 * sin((x + cx * 0.85) * 0.006) + 20.0 * sin((x + cx * 0.85) * 0.021)
		pts.append(Vector2(x, h))
		pts.append(Vector2(x + 40, h))
		x += 40.0
	pts.append(Vector2(r + 50, 300))
	draw_colored_polygon(pts, Color("5a3a28"))
	# torres de energia distantes
	var step := 300.0
	var off := fmod(cx * 0.3, step)
	x = l - off - step
	while x < r + step:
		draw_line(Vector2(x, 200), Vector2(x + 10, 120), Color("3a2a22"), 2.0)
		draw_line(Vector2(x + 20, 200), Vector2(x + 10, 120), Color("3a2a22"), 2.0)
		draw_line(Vector2(x - 4, 140), Vector2(x + 24, 140), Color("3a2a22"), 2.0)
		x += step
	# cerca / portão
	draw_rect(Rect2(l, 230, r - l, 70), Color("3a2a20"))
	var st := 24.0
	x = l - fmod(cx * 0.0, st)
	x = floor(l / st) * st
	while x < r:
		draw_line(Vector2(x, 236), Vector2(x, 300), Color("2a1e16"), 1.0)
		x += st


func _bg_night(l: float, r: float, cx: float) -> void:
	for k in 8:
		draw_rect(Rect2(l, k * 30, r - l, 31), Color("0b0f18").lerp(Color("1a1f2c"), k / 8.0))
	var step := 90.0
	var x := l - fmod(cx * 0.2, step) - step
	var i := 0
	while x < r + step:
		var h := 80.0 + float((i * 37) % 70)
		draw_rect(Rect2(x, 300 - h - 40, 60, h + 40), Color("0e1218"))
		for wy in 4:
			if (i + wy) % 3 == 0:
				draw_rect(Rect2(x + 10 + wy * 9, 300 - h - 20 + wy * 14, 4, 3), Color(0.9, 0.7, 0.4, 0.5))
		x += step
		i += 1
	draw_rect(Rect2(l, 200, r - l, 100), Color(0.05, 0.06, 0.08, 0.6))


func _solids(w: float) -> void:
	var top := Color("3a3f47")
	var fill := Color("1b1e23")
	if lv["era"] == "2051":
		top = Color("6a4a30")
		fill = Color("2a1e16")
	for s in lv["solids"]:
		var r := Rect2(s[0], s[1], s[2], s[3])
		draw_rect(r, fill)
		draw_rect(Rect2(r.position, Vector2(r.size.x, 3)), top)
		var gx := r.position.x
		while gx < r.end.x:
			draw_line(Vector2(gx, r.position.y + 3), Vector2(gx, r.end.y), Color(0, 0, 0, 0.25), 1.0)
			gx += 32.0
	for o in lv["oneway"]:
		draw_rect(Rect2(o[0], o[1], o[2], 4), top.lightened(0.1))
		var gx2: float = o[0]
		while gx2 < o[0] + o[2]:
			draw_line(Vector2(gx2, o[1] + 4), Vector2(gx2 + 6, o[1] + 10), Color(0.3, 0.32, 0.36, 0.6), 1.0)
			gx2 += 10.0
