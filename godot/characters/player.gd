extends CharacterBody2D
@export var speed = Global.playerSpeed
@export var life = Global.playerLife
@onready var posicion_pistola = $Marker2D
@onready var weapon = $weapon
#cambio de armas
@onready var weapon_slot = $WeaponSlots
var current_weapon: Node = null
var weapon_list: Array = []
var current_weapon_index = 0


func _ready():
	# Guardamos todas las armas en el slot
	weapon_list = weapon_slot.get_children()
	print(weapon_list)
	if weapon_list.size() > 0:
		select_weapon(0)

func _physics_process(_delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	# Normalizamos para evitar que se mueva más rápido en diagonal
	input_vector = input_vector.normalized()
	velocity = input_vector * speed
	move_and_slide()
   # para que rote hacia el mouse
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	rotation = direction.angle()
	#SELECCION DE ARMAS##
	if Input.is_action_just_pressed("arma1"):
		select_weapon(0)
		print("arma 1 revolver")
	elif Input.is_action_just_pressed("arma2"):
		select_weapon(1)
		print("arma 2 escopeta")
	elif Input.is_action_just_pressed("arma3"):
		select_weapon(2)
		print("arma 3 faca")
	
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var direction = (get_global_mouse_position() - global_position).normalized()
		shoot_current_weapon(direction)
		
		
#disparar arma seleccionado
func shoot_current_weapon(direction: Vector2):
	match current_weapon_index:
		0:
			weapon.shoot_pistola(posicion_pistola.global_position, direction, get_parent())
		1:
			weapon.shoot_escopeta(posicion_pistola.global_position, direction, get_parent())
		2:
			weapon.shoot_faca(posicion_pistola.global_position, direction, get_parent())

func select_weapon(index: int):
	current_weapon_index = index
	if index >= weapon_list.size():
		return
	for i in range(weapon_list.size()):
		weapon_list[i].visible = (i == index)
	current_weapon = weapon_list[index]
