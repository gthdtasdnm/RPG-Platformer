extends CharacterBody2D


var rng = RandomNumberGenerator.new()
var set_jump_timer = true
var set_direction_timer = true
var direction = 0
var SPEED = 50
const JUMP_VELOCITY = -300
var spawned = false
@onready var anim = $AnimationPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var jump_timer: Timer = $jump
@onready var direction_timer: Timer = $direction
@onready var sprite_enemy: Sprite2D = $Sprite2D
@onready var spawn_timer: Timer = $spawn

func _ready() -> void:
	anim.play("Spawn")
	spawn_timer.start()
	
	
func animation_handler():

	#IDLE ANIMATION
	if is_on_floor:
		anim.play("Idle")

	#DIRECTION
	if direction>0:
		sprite_enemy.flip_h = false
	elif direction<0:
		sprite_enemy.flip_h = true

func movement_handler(delta):
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if set_jump_timer:
		set_jump_timer = false
		jump_timer.wait_time = rng.randf_range(2, 10)
		jump_timer.start()
	
	if set_direction_timer:
		set_direction_timer = false
		direction = rng.randi_range(-1, 1)
		direction_timer.wait_time = rng.randf_range(0.1, 2)
		direction_timer.start()
	
	if is_on_wall():
		direction = direction * (-1)
	
		
	if direction>0:
		velocity.x = direction * SPEED
	elif direction<0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func death_handler():
	pass
	
func _on_jump_timeout() -> void:
	velocity.y = JUMP_VELOCITY
	set_jump_timer = true

func _on_direction_timeout() -> void:
	set_direction_timer = true

func _on_spawn_timeout() -> void:
	spawned = true
	
func _physics_process(delta: float) -> void:
	if spawned:
		death_handler()
		
		animation_handler()
		
		movement_handler(delta)
		
		move_and_slide()
