extends Area2D
@onready var screensize = get_viewport_rect().size

@export var speed = 150
@export var cooldown = .25
@export var bullet_scene : PackedScene
@export var max_shield = 10
var can_shoot = true
signal died
signal shield_changed
var shield = max_shield:
	set = set_shield

func _ready() -> void:
	start()
	pass # Replace with function body.


func start():
	position = Vector2(screensize.x / 2, screensize.y - 64)

func _process(delta):
	var input = Input.get_vector("left", "right", "up", "down")
	if input.x > 0:
		$Ship.frame = 2
		$Ship/Boosters.animation = "right"
	elif input.x < 0:
		$Ship.frame = 0
		$Ship/Boosters.animation = "left"
	else:
		$Ship.frame = 1
		$Ship/Boosters.animation = "forward"
	position += input * speed * delta
	position = position.clamp(Vector2(8, 8), screensize-Vector2(8, 8))
	
	$GunCooldown.wait_time = cooldown
	
	if Input.is_action_pressed("shoot"):
		shoot()

func shoot():
	if not can_shoot:
		return
	can_shoot = false
	$GunCooldown.start()
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start(position + Vector2(0, -8))
	
	
func _on_gun_cooldown_timeout():
	can_shoot = true

func set_shield(value):
	shield = min(max_shield, value)
	shield_changed.emit(max_shield, shield)
	if shield <= 0:
		hide()
		died.emit()
		
func _on_area_entered(area):
	if area.is_in_group("enemies"):
		area.explode()
		shield -= max_shield / 2
		
func power_up():
	cooldown = .125
	print(cooldown)
	$PowerUpTimer.start()
	return cooldown

func _on_power_up_timer_timeout() -> void:
	cooldown = 0.25
