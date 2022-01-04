extends KinematicBody

# ------------------------------------------------------------
# Use 'W', 'S' keys for move + 'Shift'/'Ctrl' to sprint/creep.
# For enter/exit view mode press 'Tab'.
# Script author: Warrpy
# -------------------------------------------------------------

var velocity = Vector3()
var direction = Vector3()
var speed = 0
var gravity = -14
var accelerating = false
var define_direction = false
var initial_speed = 0
var forward = false
var backward = false
var view_mode = false
var slowly = 0

# variables that can be edited in the Inspector tab.
export var acceleration = 0.01
export var deceleration = 0.05
export var max_speed = 5
export var angle_ease = 5

var jump = false
var fall = false
var creep = false
var sprint = false

var boost = 0

onready var axis = get_parent().get_node("Axis")
onready var animator = $"atomic-robot/AnimationPlayer"

# ------------------------------------------------------------------
# Robot 3D model from Atomic Game Engine examples, author Bartheinz.
# ------------------------------------------------------------------

func _physics_process(delta):
	direction = Vector3()
	if Input.is_action_pressed("forward"):
		forward = true
		direction.z = 1
		define_direction = true
		# walking animation control block.
		if not jump and not fall and not sprint and not creep:
			animator.play("Walking", 0.2)
	else:
		forward = false
		# default pose.
		if not jump and not fall and not backward:
			animator.play("Default", 0.3) 
			# previous animation/s will be blend to "Default" for 0.3 sec.
	if Input.is_action_pressed("backward"):
		backward = true
		direction.z = -1
		define_direction = false
		# walking backwards.
		if not jump and not fall and not sprint:
			animator.play_backwards("Walking")
	else:
		backward = false
	if Input.is_action_pressed("sprint"):
		if forward and not jump and not fall:
			sprint = true
			boost = 1.4
			animator.play("Running", 0.3)
	else:
		sprint = false
		boost = 1
	if Input.is_action_pressed("creep"):
		if forward:
			creep = true
			animator.play("Creep", 0.3)
	else:
		creep = false
	if Input.is_action_just_pressed("view_mode"):
		if view_mode:
			view_mode = false
		else:
			view_mode = true
		
	if forward or backward:
		if not view_mode:
			# smoothly rotates from one rotation to another.
			slowly = lerp_angle(rotation.y, axis.rotation.y, deg2rad(angle_ease))
			rotation.y = slowly
		# acceleration.
		initial_speed = lerp(speed, max_speed, acceleration)
		speed = initial_speed
	else:
		# determines where the movement was directed last,
		# forward or backward.
		if define_direction:
			direction.z = 1
		else:
			direction.z = -1
		# deceleration.
		initial_speed = lerp(speed, 0, deceleration)
		speed = initial_speed
	
	direction = direction.normalized() 
	direction *= speed * boost
	
	# rotates the direction of movement depending on the rotation.
	# easier, body moves where it is directed/faced.
	direction = direction.rotated(Vector3(0, 1, 0), rotation.y)
	
	velocity.x = direction.x
	velocity.z = direction.z
	velocity.y += gravity * delta
	
	velocity = move_and_slide(velocity, Vector3.UP)
	
	# if all boolean values are false, the body is falling.
	if not is_on_floor() and not jump and not fall:
		fall = true
		animator.play("Fall")
	
	if is_on_floor() and fall:
		fall = false
	
	if is_on_floor() and jump:
		jump = false
	
	if is_on_floor() and Input.is_action_pressed("jump"):
		velocity.y = 10
		animator.play("Jump")
		jump = true
