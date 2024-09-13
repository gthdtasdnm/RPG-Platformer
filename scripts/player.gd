extends CharacterBody2D


var SPEED = 200
const JUMP_VELOCITY = -300
var second_jump = true
var timer_startet = false
var attack_damage = 10
var knockback_force = 300.0
@onready var anim = $AnimationPlayer
@onready var sprite_player: Sprite2D = %SpritePlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var kill_timer: Timer = $KillTimer
@onready var slash_timer: Timer = $Slash
@onready var collisionsword: CollisionShape2D = $Area2D/Collisionsword
@onready var spritesword: Sprite2D = $Spritesword
@onready var anim_tree: AnimationTree = $AnimationTree

func _ready() -> void:
	anim_tree.active = true
	
func _process(delta: float) -> void:
	animation_handler()
	
func update_anim_parameters():
	if velocity.x == 0 and is_on_floor():
		anim_tree["parameters/conditions/idle"] = true
		anim_tree["parameters/conditions/isJumping"] = false
		anim_tree["parameters/conditions/isMoving"] = false
	elif velocity.y != 0:
		anim_tree["parameters/conditions/idle"] = false
		anim_tree["parameters/conditions/isJumping"] = true
		anim_tree["parameters/conditions/isMoving"] = false
	else:
		anim_tree["parameters/conditions/idle"] = false
		anim_tree["parameters/conditions/isJumping"] = false
		anim_tree["parameters/conditions/isMoving"] = true
	
	if Input.is_action_just_pressed("ClickLeft") :
		anim_tree["parameters/conditions/attack"] = true
	else: 
		anim_tree["parameters/conditions/attack"] = false

func animation_handler():
	
	update_anim_parameters()
	
	#DIRECTION
	var direction := Input.get_axis("Left", "Right")
	if direction>0:
		sprite_player.flip_h = false
		collisionsword.position.x = 10
		spritesword.flip_h = true
	elif direction<0:
		sprite_player.flip_h = true
		spritesword.flip_h = false
		collisionsword.position.x = -10
		
	
func movement_handler(delta):
	
	if is_on_floor():
		second_jump = true
	else:
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
		
	if Input.is_action_just_pressed("Up") and not is_on_floor() and second_jump:
		velocity.y = JUMP_VELOCITY
		second_jump = false
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("Left", "Right")
	
	if direction>0:
		velocity.x = direction * SPEED
	elif direction<0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func death_handler():
	if not timer_startet and not is_on_floor():
		kill_timer.start()
		timer_startet = true
	if is_on_floor():
		kill_timer.stop()
		timer_startet = false
	
func _physics_process(delta: float) -> void:
	death_handler()
	
	movement_handler(delta)
	
	move_and_slide()

func _on_kill_timer_timeout() -> void:
	get_tree().reload_current_scene()
	
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("damage"):
		var attack = Attack.new()
		attack.attack_damage = attack_damage
		attack.knockback_force = knockback_force
		attack.attack_position = global_position.x
		body.damage(attack)
