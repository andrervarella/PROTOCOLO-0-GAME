extends CharacterBody2D
## Silas Venn — controle do jogador.
## era "2054": prisioneiro fraco, ferramenta de manutenção (combo de 3 golpes).
## era "2051": soldado forte e equipado, fuzil (segurar AÇÃO = rajada).

signal died
signal hp_changed(hp: int, max_hp: int)

const GRAVITY := 980.0
const W := 14.0
const H := 34.0

var main: Node
var era := "2054"
var has_tool := false
var max_hp := 6
var hp := 6
var facing := 1
var controllable := true
var dead := false

var speed := 135.0
var jump_vel := -335.0
var coyote := 0.0
var jump_buffer := 0.0

# ataque corpo a corpo
var attacking := false
var attack_t := 0.0
var attack_step := 0
var queued_attack := false
var hit_ids := {}
const ATTACK_DUR := [0.26, 0.26, 0.38]
const ATTACK_ACTIVE := [Vector2(0.06, 0.14), Vector2(0.06, 0.14), Vector2(0.12, 0.22)]
const ATTACK_DMG := [1, 1, 2]

# fuzil (2051)
var fire_cd := 0.0
var muzzle := 0.0
var aiming := false  # usado na cena da hesitação

var dodge_t := 0.0
var dodge_cd := 0.0
var invuln := 0.0
var hurt_t := 0.0
var anim_t := 0.0
var land_squash := 0.0
var auto_walk := 0.0  # para cenas: anda sozinho nessa direção


func setup(p_main: Node, p_era: String, p_has_tool: bool) -> void:
	main = p_main
	era = p_era
	has_tool = p_has_tool
	if era == "2051":
		max_hp = 9
		speed = 150.0
	else:
		max_hp = 6
		speed = 135.0
	hp = max_hp
	collision_layer = 2
	collision_mask = 1
	var cs := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = Vector2(W, H)
	cs.shape = rs
	cs.position = Vector2(0, -H / 2.0)
	add_child(cs)
	floor_snap_length = 4.0
	add_to_group("player")


func hit_rect() -> Rect2:
	return Rect2(global_position + Vector2(-W / 2.0, -H), Vector2(W, H))


func _process(_delta: float) -> void:
	var blink: bool = invuln > 0.0 and controllable and not dead and int(anim_t * 20.0) % 2 == 0
	modulate.a = 0.35 if blink else 1.0


func _physics_process(delta: float) -> void:
	anim_t += delta
	invuln = max(0.0, invuln - delta)
	hurt_t = max(0.0, hurt_t - delta)
	dodge_cd = max(0.0, dodge_cd - delta)
	fire_cd = max(0.0, fire_cd - delta)
	muzzle = max(0.0, muzzle - delta)
	land_squash = max(0.0, land_squash - delta)

	if not is_on_floor():
		velocity.y = min(velocity.y + GRAVITY * delta, 520.0)

	var dir := 0.0
	var can_act := controllable and not dead
	if can_act:
		dir = Input.get_axis("left", "right")
	if auto_walk != 0.0:
		dir = auto_walk

	if is_on_floor():
		coyote = 0.1
	else:
		coyote -= delta
	jump_buffer -= delta

	if can_act:
		var down := Input.is_action_pressed("down")
		if Input.is_action_just_pressed("jump"):
			if down and is_on_floor():
				_start_dodge()
			else:
				jump_buffer = 0.12
		if Input.is_action_just_pressed("dodge"):
			_start_dodge()
		if era == "2054":
			if Input.is_action_just_pressed("attack") and has_tool:
				if attacking:
					queued_attack = true
				else:
					_start_attack(0)
		else:
			if Input.is_action_pressed("attack") and fire_cd <= 0.0 and dodge_t <= 0.0:
				_fire()

	# esquiva
	if dodge_t > 0.0:
		dodge_t -= delta
		velocity.x = facing * 290.0
		move_and_slide()
		queue_redraw()
		return

	# pulo
	var can_cancel: bool = not attacking or attack_t > ATTACK_ACTIVE[attack_step].y
	if jump_buffer > 0.0 and coyote > 0.0 and can_cancel:
		attacking = false
		velocity.y = jump_vel
		jump_buffer = 0.0
		coyote = 0.0
	if can_act and Input.is_action_just_released("jump") and velocity.y < -120.0:
		velocity.y *= 0.45

	# movimento horizontal
	var spd := speed
	if attacking and is_on_floor():
		spd *= 0.25
	if era == "2051" and fire_cd > 0.0 and is_on_floor():
		spd *= 0.7
	if hurt_t > 0.0:
		velocity.x = move_toward(velocity.x, 0.0, 600.0 * delta)
	else:
		var target := dir * spd
		var acc := 1400.0 if is_on_floor() else 900.0
		velocity.x = move_toward(velocity.x, target, acc * delta)
		if dir != 0.0 and not attacking:
			facing = 1 if dir > 0.0 else -1

	if attacking:
		_update_attack(delta)

	var was_air := not is_on_floor()
	move_and_slide()
	if was_air and is_on_floor():
		land_squash = 0.08
	queue_redraw()


func _start_attack(step: int) -> void:
	attacking = true
	attack_step = step
	attack_t = 0.0
	queued_attack = false
	hit_ids.clear()
	if step == 2:
		velocity.x = facing * 170.0


func _update_attack(delta: float) -> void:
	attack_t += delta
	var act: Vector2 = ATTACK_ACTIVE[attack_step]
	if attack_t >= act.x and attack_t <= act.y:
		var reach := 30.0 if attack_step < 2 else 36.0
		var r := Rect2(global_position + Vector2(4 if facing > 0 else -4 - reach, -30), Vector2(reach, 22))
		for n in get_tree().get_nodes_in_group("hittable"):
			if hit_ids.has(n.get_instance_id()):
				continue
			if n.has_method("hit_rect") and r.intersects(n.hit_rect()):
				hit_ids[n.get_instance_id()] = true
				n.take_hit(ATTACK_DMG[attack_step], global_position.x)
				if main:
					var p: Vector2 = n.hit_rect().get_center()
					main.spark(Vector2(clamp(p.x, r.position.x, r.end.x), p.y), Color(1.0, 0.8, 0.4))
					main.hitstop(0.05 if attack_step < 2 else 0.09)
					main.shake(2.0 if attack_step < 2 else 4.0)
	if attack_t >= ATTACK_DUR[attack_step]:
		attacking = false
		if queued_attack and attack_step < 2:
			_start_attack(attack_step + 1)


func _fire() -> void:
	fire_cd = 0.16
	muzzle = 0.06
	if main:
		main.spawn_bullet(global_position + Vector2(facing * 22, -22), Vector2(facing * 540.0, randf_range(-12, 12)), "player", 1)


func _start_dodge() -> void:
	if dodge_cd > 0.0 or not is_on_floor() or attacking:
		return
	dodge_t = 0.22
	dodge_cd = 0.5
	invuln = max(invuln, 0.3)


func take_hit(dmg: int, from_x: float) -> void:
	if dead or invuln > 0.0 or dodge_t > 0.0:
		return
	hp = max(0, hp - dmg)
	invuln = 0.9
	hurt_t = 0.22
	attacking = false
	var kdir := 1.0 if global_position.x >= from_x else -1.0
	velocity = Vector2(kdir * 180.0, -150.0)
	if main:
		main.shake(5.0)
		main.hitstop(0.07)
		main.spark(global_position + Vector2(0, -20), Color(1.0, 0.25, 0.2))
	hp_changed.emit(hp, max_hp)
	if hp <= 0:
		dead = true
		died.emit()


func heal_full() -> void:
	hp = max_hp
	hp_changed.emit(hp, max_hp)


# ---------------------------------------------------------------- desenho provisório
func _draw() -> void:
	var f := float(facing)
	var moving: bool = absf(velocity.x) > 10.0 and is_on_floor()
	var swing := sin(anim_t * 14.0) * 5.0 if moving else 0.0
	var squash := 2.0 if land_squash > 0.0 else 0.0
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(f, 1.0))
	if dead:
		draw_set_transform(Vector2(0, -4), PI / 2.0 * f, Vector2(f, 1.0))
	if dodge_t > 0.0:
		_draw_dodge()
		return

	var skin := Color("c69878")
	var hair := Color("0d0d0f")
	var beard := Color("241914")
	var body_main: Color
	var body_dark: Color
	var accent := Color("a3191f")
	var feet := Color("151515")
	if era == "2051":
		body_main = Color("1f2024")  # tático preto (ref. PZ-SILAS-OFICIAL-03)
		body_dark = Color("18191c")
	else:
		body_main = Color("6b6258")  # camiseta rasgada sem manga (ref. PZ-SILAS-OFICIAL-02)
		body_dark = Color("5a534b")
		feet = Color("c8b8a0")  # pés enfaixados

	# pernas
	draw_rect(Rect2(-5 + swing * 0.6, -14 + squash, 4, 14 - squash), body_dark)
	draw_rect(Rect2(1 - swing * 0.6, -14 + squash, 4, 14 - squash), body_dark)
	draw_rect(Rect2(-6 + swing * 0.6, -3, 6, 3), feet)
	draw_rect(Rect2(0 - swing * 0.6, -3, 6, 3), feet)
	# tronco
	draw_rect(Rect2(-6, -26 + squash, 12, 13), body_main)
	if era == "2051":
		draw_rect(Rect2(-6, -25 + squash, 12, 8), Color("2c2d32"))  # colete
		draw_rect(Rect2(-6, -24 + squash, 3, 3), accent)  # ombreira vermelha
		draw_rect(Rect2(-1, -15 + squash, 2, 2), accent)
	else:
		draw_rect(Rect2(-6, -26 + squash, 2, 6), skin)  # ombro à mostra
		draw_rect(Rect2(1, -18 + squash, 3, 2), Color("4a443d"))  # rasgo
		draw_rect(Rect2(-4, -21 + squash, 1, 3), Color("b02020"))  # implante discreto
	# cabeça
	draw_rect(Rect2(-4, -34 + squash, 9, 9), skin)
	draw_rect(Rect2(-5, -35 + squash, 10, 4), hair)  # cabelo preto curto
	draw_rect(Rect2(-5, -32 + squash, 2, 3), hair)
	draw_rect(Rect2(-3, -28 + squash, 8, 3), beard)  # barba
	draw_rect(Rect2(2, -31 + squash, 2, 1), Color("1a1a1a"))  # olho
	if era == "2054":
		draw_rect(Rect2(3, -33 + squash, 1, 2), Color("8a5a4a"))  # cicatriz (só depois de 2051)
	# braço / arma
	if era == "2051":
		var aim_up := -2.0 if aiming else 0.0
		draw_rect(Rect2(-2, -23 + squash, 14, 3), Color("181818"))  # fuzil
		draw_rect(Rect2(10, -24 + squash + aim_up, 8, 2), Color("2a2a2a"))
		draw_rect(Rect2(0, -22 + squash, 5, 4), skin)
		if muzzle > 0.0:
			draw_circle(Vector2(20, -23 + squash), 3.5, Color(1.0, 0.85, 0.4))
	else:
		var arm_ang := 0.0
		var ext := 0.0
		if attacking:
			var p := attack_t / float(ATTACK_DUR[attack_step])
			if attack_step == 2:
				arm_ang = lerp(-1.6, 1.2, clamp(p * 2.0, 0.0, 1.0))
				ext = 6.0
			else:
				arm_ang = lerp(-1.0, 0.9, clamp(p * 2.2, 0.0, 1.0))
				ext = 4.0
		var shoulder := Vector2(1, -23 + squash)
		var hand := shoulder + Vector2(7 + ext, 0).rotated(arm_ang)
		draw_line(shoulder, hand, skin, 3.0)
		if has_tool:
			var tip := hand + Vector2(10, 0).rotated(arm_ang - 0.3)
			draw_line(hand, tip, Color("9aa0a6"), 2.0)
			draw_rect(Rect2(tip - Vector2(2, 2), Vector2(4, 4)), Color("c0c6cc"))
			if attacking and attack_t > ATTACK_ACTIVE[attack_step].x and attack_t < ATTACK_ACTIVE[attack_step].y:
				draw_arc(shoulder, 15.0, -1.2, 1.1, 10, Color(1.0, 0.85, 0.6, 0.7), 2.0)
		draw_rect(Rect2(hand - Vector2(1.5, 1.5), Vector2(3, 3)), skin)


func _draw_dodge() -> void:
	var c := Color("6b6258") if era == "2054" else Color("1f2024")
	draw_rect(Rect2(-10, -12, 18, 10), c)
	draw_rect(Rect2(6, -14, 7, 7), Color("c69878"))
	draw_rect(Rect2(6, -15, 7, 3), Color("0d0d0f"))
	for i in 3:
		draw_rect(Rect2(-14 - i * 6, -10 + i, 4, 1), Color(1, 1, 1, 0.35 - i * 0.1))
