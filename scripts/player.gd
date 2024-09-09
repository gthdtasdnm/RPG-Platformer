extends CharacterBody2D


var SPEED = 200
const JUMP_VELOCITY = -300
var second_jump = true
var timer_startet = false
@onready var anim = $AnimationPlayer
@onready var sprite_player: Sprite2D = %SpritePlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var kill_timer: Timer = $KillTimer

func animation_handler():

	#IDLE ANIMATION
	if is_on_floor:
		anim.play("Idle")

	#JUMP ANIMATION
	if Input.is_action_just_pressed("Up") and is_on_floor():
		anim.play("Jump")
		
	#SLASH ANIMATION
	if Input.is_action_just_pressed("ClickLeft"):
		animated_sprite_2d.visible = true
		animated_sprite_2d.play()

	#DIRECTION
	var direction := Input.get_axis("Left", "Right")
	if direction>0:
		sprite_player.flip_h = false
		animated_sprite_2d.flip_h = true
	elif direction<0:
		sprite_player.flip_h = true
		animated_sprite_2d.flip_h = false

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
	
	animation_handler()
	
	movement_handler(delta)
	
	move_and_slide()


func _on_kill_timer_timeout() -> void:
	get_tree().reload_current_scene()
