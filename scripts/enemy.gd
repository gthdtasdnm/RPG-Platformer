extends CharacterBody2D

class_name enemy
##################################################
#
# Variables and Dependencies
#
##################################################
@onready var sprite_slime: Sprite2D = $SpriteSlime
@onready var anim: AnimationPlayer = $AnimationPlayer2
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var player: CharacterBody2D = $"../Player"
@onready var ray_cast_floor: RayCast2D = $RayCastfloor

var move_speed := 50
var move_direction : float
var wander_time : float
var jump_time : float = 1
var jump_velocity = -200
var knockback_force : float = 0
var attack_position : int
var attack_force : float = 80

var isHit = false
var knockback_time : float = 0.1

##################################################
#
# Help Functions
#
##################################################

func randomize_wander():
	move_direction = randf_range(-1, 1)
	wander_time = randf_range(1, 5)

func randomize_jump():
	jump_time = randf_range(2, 5)
	
func damage(attack : Attack):
	knockback_force = attack.knockback_force 
	attack_position = sign( global_position.x - attack.attack_position)
	
func jump(delta):
	if is_on_floor():
		velocity.y = jump_velocity
	
func attack(move_direction, delta):
	velocity.x = attack_force * move_direction
	
	
	
##################################################
#
# States
#
##################################################
		
func chase_state(delta):
	#GRAVITY
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = -knockback_force
	#CHASE PLAYER
	if abs(player.global_position.x - global_position.x) > 5:
		move_direction = sign(player.global_position.x - global_position.x)
		ray_cast_floor.position.x = move_direction * 6
	else:
		move_direction = 0
	velocity.x = 100 * move_direction + (knockback_force * attack_position)
	
	if knockback_force>0:
		knockback_force -= delta * 500
	#JUMP OVER OBSTACLE
	if is_on_wall() and player.global_position.distance_to(global_position) > 12:
		jump(delta)
	
	if is_on_floor() and not ray_cast_floor.is_colliding():
		velocity.x = 0

func wander_state(delta):
	#GRAVITY
	ray_cast_floor.position.x = sign(move_direction)*6
	if not ray_cast_floor.is_colliding():
		move_direction *= -1
		
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
		
	

##################################################
#
# Handlers
#
##################################################

func movement_handler(delta):
	if player.global_position.distance_to(global_position) < 100:
		chase_state(delta)
	else:
		wander_state(delta)
		
func animation_handler(delta):
	# 0 = Idle
	# 1 = Hit
	# 2 = Spawn
	# 3 = Attack
	if move_direction>0:
		$SpriteSlime.flip_h = false
	else:
		$SpriteSlime.flip_h = true
	
	if knockback_force>0:
		anim_tree["parameters/blend_position"] = 1
	else:
		anim_tree["parameters/blend_position"] = 0
##################################################
#
# System Function
#
##################################################

func _ready() -> void:
	randomize_wander()
	randomize_jump()
	
func _physics_process(delta: float) -> void:
	movement_handler(delta)
	animation_handler(delta)
	move_and_slide()
