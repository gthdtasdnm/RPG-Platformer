extends CharacterBody2D


var SPEED = 200
const JUMP_VELOCITY = -300
var second_jump = true
@onready var anim = $AnimationPlayer
@onready var sprite_player: Sprite2D = %SpritePlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer




func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if is_on_floor():
		second_jump = true
		anim.play("Idle")
	else:
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		anim.play("Jump")
	
		

	
	if Input.is_action_just_pressed("Up") and not is_on_floor() and second_jump:
		velocity.y = JUMP_VELOCITY
		second_jump = false
		
	if Input.is_action_just_pressed("ClickLeft"):
		animated_sprite_2d.visible = true
		animated_sprite_2d.play()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("Left", "Right")
	
	if direction>0:
		velocity.x = direction * SPEED
		sprite_player.flip_h = false
		animated_sprite_2d.flip_h = true
	elif direction<0:
		sprite_player.flip_h = true
		animated_sprite_2d.flip_h = false
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	

	move_and_slide()
