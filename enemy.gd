extends CharacterBody2D


var rng = RandomNumberGenerator.new()
var set_jump_timer = true
var set_direction_timer = true
var direction = 0
var SPEED = 50
var hitted = false
var hittable = true
const JUMP_VELOCITY = -300
var spawned = false
@onready var anim = $AnimationPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var jump_timer: Timer = $jump
@onready var direction_timer: Timer = $direction
@onready var sprite_enemy: Sprite2D = $Sprite2D
@onready var spawn_timer: Timer = $spawn
@onready var hit_area: Area2D = $hitArea



func _ready() -> void:
	anim.play("Spawn")
	spawn_timer.start()
	
	
func animation_handler():

	#IDLE ANIMATION
	if is_on_floor and not anim.is_playing():
		anim.play("Idle")

	#DIRECTION
	if direction>0:
		sprite_enemy.flip_h = false
	elif direction<0:
		sprite_enemy.flip_h = true
		
	if hitted:
		anim.play("Hit")

func movement_handler(delta):
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		hitted = false
	else:
		hittable = true
	
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
		
	if not hitted and hittable:
		if direction>0:
			velocity.x = direction * SPEED
		elif direction<0:
			velocity.x = direction * SPEED
	
	if hitted and hittable:
		hittable = false
		velocity = Vector2(100,-200)
			
			

func death_handler():
	pass
	
func _on_jump_timeout() -> void:
	if is_on_floor():
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



func _on_hit_area_area_entered(area: Area2D) -> void:
	hitted = true
