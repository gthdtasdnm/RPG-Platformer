extends CharacterBody2D

class_name enemy
@onready var sprite_slime: Sprite2D = $SpriteSlime
@onready var anim: AnimationPlayer = $AnimationPlayer2

var move_speed := 50
var move_direction : float
var wander_time : float
var jump_time : float
var jump_velocity = -200
var knockback : float
var attack_dir : int

func randomize_wander():
	move_direction = randf_range(-1, 1)
	wander_time = randf_range(1, 5)

func randomize_jump():
	jump_time = randf_range(2, 5)
	
func _ready() -> void:
	randomize_wander()
	randomize_jump()
	
func movement_handler(delta):
	#GRAVITY
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#BOUNCE BACK FROM WALL
	if is_on_wall():
		move_direction = move_direction * (-1)
	velocity.x =  sign(move_direction) * move_speed
	
	#RANDOM WANDER
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()
	
	#RANDOM JUMP
	if jump_time > 0:
		jump_time -= delta
	elif jump_time <= 0:
		velocity.y = jump_velocity
		randomize_jump()
		
	#KNOCKBACK
	if knockback>50:
		velocity.x = knockback * attack_dir
		velocity.y = -knockback
		knockback = lerp(knockback, 0.0, 0.5)

func animation_handler():
	if move_direction>0:
		$SpriteSlime.flip_h = false
	else:
		$SpriteSlime.flip_h = true
	
	anim.play("Idle")
	
func _physics_process(delta: float) -> void:
	movement_handler(delta)
	animation_handler()
	move_and_slide()
	
func damage(attack : Attack):
	knockback = attack.knockback_force
	attack_dir = sign( global_position.x - attack.attack_position)
	
