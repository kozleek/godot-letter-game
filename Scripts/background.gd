extends Panel

# Skript pro dynamické generování gradientního pozadí
# Nahrazuje bitmapový gradient (background_gradient.png) za procedurálně generovaný
# Gradient se generuje při každém načtení scény s náhodnými barvami z rozsahu fialová-růžová

# Odkaz na TextureRect node, kam se aplikuje vygenerovaný gradient
@onready var gradient_overlay: TextureRect = $GradientOverlay

func _ready() -> void:
	# Vygeneruj náhodný gradient při startu scény
	_generate_gradient()

# Generuje náhodný gradient s barvami v rozsahu fialová-růžová
# Začátek gradientu je průhledný, aby prosvítalo pozadí pod ním
func _generate_gradient() -> void:
	# Začátek gradientu je průhledný (prosvítá tile textura pod gradientem)
	var color_start = Color.TRANSPARENT
	# Konec gradientu je náhodná barva z generátoru
	var color_end = Visuals.background_color_generator()

	# Vytvoříme gradient
	var gradient = Gradient.new()
	gradient.set_color(0, color_start)  # Barva na začátku (nahoře)
	gradient.set_color(1, color_end)    # Barva na konci (dole)

	# Vytvoříme GradientTexture2D
	var gradient_texture = GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.fill_from = Vector2(0.5, 0.0)  # Začátek gradientu (střed nahoře)
	gradient_texture.fill_to = Vector2(0.5, 1.0)    # Konec gradientu (střed dole)
	gradient_texture.width = 1920
	gradient_texture.height = 1080

	# Aplikujeme texturu
	gradient_overlay.texture = gradient_texture

	print("[Background] Generated gradient: transparent -> ", color_end)
