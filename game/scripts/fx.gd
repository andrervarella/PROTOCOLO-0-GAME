extends Node2D
## Faíscas, explosões e projéteis (desenhados em código).

var main: Node
var parts: Array = []  # {p, v, life, max, col, size}
var bullets: Array = []  # {p, v, owner, dmg, life}
var fires: Array = []  # {p, t}


func spark(pos: Vector2, col: Color, n := 8) -> void:
	for i in n:
		var a := randf() * TAU
		var sp := randf_range(60.0, 180.0)
		parts.append({"p": pos, "v": Vector2(cos(a), sin(a)) * sp, "life": 0.25, "max": 0.25, "col": col, "size": 1.5})


func burst(pos: Vector2, col: Color) -> void:
	for i in 22:
		var a := randf() * TAU
		var sp := randf_range(40.0, 220.0)
		parts.append({"p": pos, "v": Vector2(cos(a), sin(a)) * sp, "life": 0.5, "max": 0.5, "col": col, "size": 2.5})
	for i in 8:
		parts.append({"p": pos + Vector2(randf_range(-8, 8), randf_range(-8, 8)), "v": Vector2(randf_range(-20, 20), -30), "life": 0.8, "max": 0.8, "col": Color(0.3, 0.3, 0.32), "size": 5.0})


func explosion(pos: Vector2) -> void:
	for i in 50:
		var a := randf() * TAU
		var sp := randf_range(60.0, 320.0)
		parts.append({"p": pos, "v": Vector2(cos(a), sin(a) * 0.7 - 0.4) * sp, "life": 0.9, "max": 0.9, "col": Color(1.0, randf_range(0.4, 0.8), 0.15), "size": 3.0})
	for i in 20:
		parts.append({"p": pos + Vector2(randf_range(-30, 30), randf_range(-20, 10)), "v": Vector2(randf_range(-30, 30), randf_range(-60, -20)), "life": 2.0, "max": 2.0, "col": Color(0.25, 0.22, 0.2), "size": 9.0})
	fires.append({"p": pos + Vector2(-30, 0), "t": 0.0})
	fires.append({"p": pos + Vector2(25, 0), "t": 1.0})


func add_bullet(pos: Vector2, vel: Vector2, owner: String, dmg: int) -> void:
	bullets.append({"p": pos, "v": vel, "owner": owner, "dmg": dmg, "life": 1.4})


func clear_all() -> void:
	parts.clear()
	bullets.clear()
	fires.clear()


func _physics_process(delta: float) -> void:
	for p in parts:
		p["p"] += p["v"] * delta
		p["v"] *= 0.9
		p["v"].y += 200.0 * delta
		p["life"] -= delta
	parts = parts.filter(func(p): return p["life"] > 0.0)
	for f in fires:
		f["t"] += delta
	var keep: Array = []
	for b in bullets:
		b["p"] += b["v"] * delta
		b["life"] -= delta
		var alive: bool = b["life"] > 0.0
		if alive and main.point_in_solid(b["p"]):
			spark(b["p"], Color(1, 0.8, 0.4), 4)
			alive = false
		if alive and b["owner"] == "player":
			for n in get_tree().get_nodes_in_group("hittable"):
				if n.has_method("hit_rect") and n.hit_rect().grow(2).has_point(b["p"]):
					n.take_hit(b["dmg"], b["p"].x - sign(b["v"].x) * 20.0)
					spark(b["p"], Color(1, 0.7, 0.3), 6)
					main.hitstop(0.03)
					alive = false
					break
		elif alive and b["owner"] == "enemy" and main.player and not main.player.dead:
			if main.player.hit_rect().has_point(b["p"]):
				main.player.take_hit(b["dmg"], b["p"].x - sign(b["v"].x) * 20.0)
				alive = false
		if alive:
			keep.append(b)
	bullets = keep
	queue_redraw()


func _draw() -> void:
	for f in fires:
		var tt: float = f["t"]
		for i in 6:
			var h := 8.0 + 6.0 * absf(sin(tt * 7.0 + i))
			draw_circle(f["p"] + Vector2(-8 + i * 3, -h * 0.5), 3.0 + sin(tt * 9.0 + i) * 1.0, Color(1.0, 0.45 + 0.1 * i, 0.1, 0.8))
	for p in parts:
		var a: float = p["life"] / p["max"]
		var c: Color = p["col"]
		draw_rect(Rect2(p["p"] - Vector2.ONE * p["size"] * 0.5, Vector2.ONE * p["size"]), Color(c.r, c.g, c.b, a))
	for b in bullets:
		var col := Color(1.0, 0.9, 0.5) if b["owner"] == "player" else Color(1.0, 0.3, 0.25)
		var tail: Vector2 = b["v"].normalized() * (10.0 if b["owner"] == "player" else 6.0)
		draw_line(b["p"] - tail, b["p"], col, 2.0)
