extends Spatial

var enabled = false

export var x_offset = 0
export var y_offset = 0
export var z_offset = 0

export var inverse_x = false
export var inverse_y = false

export var sensitivity_x = 300
export var sensitivity_y = 300

export (NodePath) var target
onready var sprite = get_node(target)

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	enabled = true
	inverse()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	transform.origin.y = sprite.transform.origin.y + y_offset
	transform.origin.z = sprite.transform.origin.z + z_offset
	transform.origin.x = sprite.transform.origin.x + x_offset
	
func inverse():
	if inverse_x:
		sensitivity_x *= -1
	if inverse_y:
		sensitivity_y *= -1

# Call this methods once for toggle axis inversion.
func _inverse_x():
	sensitivity_x *= -1
	
func _inverse_y():
	sensitivity_y *= -1

func _input(event):
	if Input.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		enabled = false
	if event is InputEventMouseMotion && enabled:
		rotation.y += event.relative.x / -sensitivity_x
		rotation.x += event.relative.y / -sensitivity_y

