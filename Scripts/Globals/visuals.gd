extends Node

# ========================
# Obrazovka / Kamera
# ========================

# zatřesení obrazovkou
func screen_shake(target_node, intensity: float = 5.0, duration: float = 0.2, repeat: int = 5):
	var original_pos = target_node.position # nebo camera.position
	var tween = create_tween()
	
	# Zatřeseme obrazovkou několikrát
	for i in range(repeat):
		var random_offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(target_node, "position", original_pos + random_offset, duration / repeat)
	
	# Vrátíme na původní pozici
	tween.tween_property(target_node, "position", original_pos, duration / repeat)

# ========================
# Animace
# ========================

# POP animace
func pop_animation(target_node, factor: float = 1.4, duration: float = 0.2, repeat: int = 1):
	# Ujistěte se, že pivot bod je ve středu (aby se zvětšoval ze středu)
	target_node.pivot_offset = target_node.size / 2
	var tween = create_tween()
	
	for i in range(repeat):
		# Rychlé zvětšení na 120% během 0.1s
		tween.tween_property(target_node, "scale", Vector2(factor, factor), duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		# Návrat na 100%
		tween.tween_property(target_node, "scale", Vector2(1.0, 1.0), duration)

# ========================
# Pozadí a barvy
# ========================

# DEPRECATED: Tato funkce už není používána
# Pozadí si nyní generuje gradient automaticky ve Scripts/background.gd
# target_node by měl být Panel node s ColorRect child node pojmenovaným "GradientOverlay"
func change_background_color(target_node) -> void:
	# Najdeme ColorRect pro gradient overlay
	var gradient_overlay = target_node.get_node_or_null("GradientOverlay")

	if gradient_overlay == null:
		push_warning("[Visuals] GradientOverlay node not found in background")
		return

	# Vygenerujeme dvě náhodné barvy pro gradient
	var color_start = background_color_generator()
	var color_end = background_color_generator()

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

	# Aplikujeme texturu na ColorRect/TextureRect
	if gradient_overlay is TextureRect:
		gradient_overlay.texture = gradient_texture
	elif gradient_overlay is ColorRect:
		# Pro ColorRect použijeme material s texturou
		var material = CanvasItemMaterial.new()
		gradient_overlay.material = material
		# ColorRect nepodporuje přímo textury, musíme použít jiný přístup
		push_warning("[Visuals] ColorRect needs to be TextureRect for gradient support")

	print("[Visuals] Generated gradient from ", color_start, " to ", color_end)

# Funkce, která vrací náhodnou barvu v modelu HSV
func background_color_generator() -> Color:
	# Hue (Odstín): 
	# 0.75 je čistá fialová (270 stupňů)
	# 0.92 je sytá růžová (cca 330 stupňů)
	var h = randf_range(0.75, 0.92)
	
	# Saturation (Sytost): 0.6 až 1.0 (aby barva nebyla vybledlá)
	var s = randf_range(0.5, 0.9)
	
	# Value (Jas): 0.8 až 1.0 (aby barva byla jasná)
	var v = randf_range(0.5, 1.0)
	
	# Vytvoření barvy z HSV modelu
	return Color.from_hsv(h, s, v)
