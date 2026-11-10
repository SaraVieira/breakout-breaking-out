extends CharacterBody2D

const SPEED = 500.0
const NUDGE_DISTANCE := 2.0
const BOUNCE_WAIT := 0.05
const BOUNCE_TIME := 0.1

const SIDE_WIDTH := 12.0
const TILE_WIDTH := 8.0
const BASE_TILES := 7
const TILES_PER_EXPAND := 3
const RESIZE_TIME := 0.2

@onready var left: Sprite2D = $"paddle/p-left"
@onready var middle: Sprite2D = $"paddle/p-middle"
@onready var right: Sprite2D = $"paddle/p-right"
@onready var collision: CollisionShape2D = $CollisionShape2D

var bounce_tween: Tween
var resize_tween: Tween
var middle_width: float
var middle_rest_y: float

func _ready() -> void:
	middle_rest_y = middle.position.y
	middle.region_enabled = true
	middle_width = BASE_TILES * TILE_WIDTH
	GameState.level_changed.connect(_on_level_changed)
	_apply_width(_target_width())

func _target_width() -> float:
	var tiles := BASE_TILES + (GameState.count_powerup(&"paddle_expand") -  GameState.count_powerup(&"paddle_contract")) * TILES_PER_EXPAND
	return tiles * TILE_WIDTH

func _on_level_changed(_level: int) -> void:
	_resize_to_target()

func _resize_to_target() -> void:
	var target := _target_width()
	if is_equal_approx(target, middle_width):
		return
	if resize_tween and resize_tween.is_valid():
		resize_tween.kill()
	resize_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	resize_tween.tween_method(_apply_width, middle_width, target, RESIZE_TIME)

func _apply_width(width: float) -> void:
	width = roundf(width / 2.0) * 2.0
	middle_width = width
	var half := width / 2.0
	middle.region_rect.size.x = width
	left.position.x = -(half + SIDE_WIDTH / 2.0)
	right.position.x = half + SIDE_WIDTH / 2.0
	collision.shape.height = width + SIDE_WIDTH * 2.0

func nudge_down() -> void:
	if bounce_tween and bounce_tween.is_valid():
		bounce_tween.kill()
	middle.position.y = middle_rest_y + NUDGE_DISTANCE
	bounce_tween = create_tween()
	bounce_tween.tween_interval(BOUNCE_WAIT)
	bounce_tween.tween_property(middle, "position:y", middle_rest_y, BOUNCE_TIME)

func _physics_process(delta: float) -> void:
	if GameState.paused:
		return

	var direction := Input.get_axis("left", "right")
	var is_shift_pressed := Input.is_action_pressed("shift")
	var window_size := get_viewport_rect().size
	var constrain = window_size.x / 2 - 16
	var speed_multiplier = 1.0
	if is_shift_pressed:
		speed_multiplier = 2


	position.x = clamp(position.x, -constrain,constrain)

	if direction:
		velocity.x = direction * (SPEED * speed_multiplier)
	else:
		velocity.x = move_toward(velocity.x, 0, (SPEED))

	move_and_slide()
