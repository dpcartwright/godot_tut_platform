extends KinematicBody2D
class_name Player

enum {
	MOVE,
	CLIMB
}

export(Resource) var moveData

var velocity = Vector2.ZERO
var state = MOVE

onready var animatedSprite = $AnimatedSprite
onready var ladderCheck = $LadderCheck

func _ready():
	animatedSprite.frames = load("res://PlayerBlueSkin.tres")

func _physics_process(delta):	
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	
	match state:
		MOVE: move_state(input)
		CLIMB: climb_state(input)
	

func move_state(input):
	if  is_on_ladder() && Input.is_action_pressed("ui_up"):
		state = CLIMB
		
	apply_gravity()
	if input.x == 0:
		apply_friction()
		animatedSprite.animation = "Idle"
	else:
		apply_acceleration(input.x)
		animatedSprite.animation = "Run"
		
		if input.x > 0:
			animatedSprite.flip_h = true
		else:
			animatedSprite.flip_h = false

	if is_on_floor():
		if Input.is_action_pressed("ui_up"):
			velocity.y = moveData.JUMP_FORCE
	else:
		animatedSprite.animation = "Jump"
		if Input.is_action_just_released("ui_up") and velocity.y < moveData.JUMP_RELEASE_FORCE:
			velocity.y = moveData.JUMP_RELEASE_FORCE

		if velocity.y > 0:
			velocity.y += moveData.ADDITIONAL_FALL_GRAVITY

	var was_in_air = !is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP)
	if is_on_floor() == was_in_air:
		animatedSprite.animation = "Run"
		animatedSprite.frame = 1
	
func climb_state(input):
	if !is_on_ladder(): state = MOVE
	if input.length() != 0:
		animatedSprite.animation = "Run"
	else:
		animatedSprite.animation = "Idle"
		
	velocity = input * 50
	velocity = move_and_slide(velocity, Vector2.UP)
	pass

func is_on_ladder():
	if !ladderCheck.is_colliding(): return false
	var collider = ladderCheck.get_collider()
	if !collider is Ladder: return false
	return true

func apply_gravity():
	velocity.y += moveData.GRAVITY
	velocity.y = min(velocity.y, 300)

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, moveData.FRICTION)

func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, moveData.MAX_SPEED * amount, moveData.ACCELERATION)
