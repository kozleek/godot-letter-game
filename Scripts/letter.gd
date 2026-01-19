class_name Letter
extends Node

@onready var sound_effect: AudioStreamPlayer2D = $SoundEffect
@onready var label: Label = $Label
@onready var points_container: Control = $PointsContainer
@onready var points: Label = $PointsContainer/Panel/Label


var letters: Array = []
var letter_points: Dictionary = {}  # Mapování písmeno → pevné body pro toto kolo
var current_index: int = 0

var current_letter: String = ""
var current_points: int = 0

func _ready() -> void:
	# Inicializujeme pole písmen ze Settings
	letters = Settings.LETTERS_AND_POINTS.keys()

	# Prvotní zamíchání a nastavení (vygeneruje i body)
	_shuffle_letters()

	# Zobrazíme výchozí stav a skryjeme body
	points_container.hide()
	update_visuals()

# ========================
# Gettery pro hlavní aplikaci
# ========================

# Vrátí aktuálně vybrané písmeno (voláno po ukončení otáčení)
func get_current_letter() -> String:
	return current_letter.to_upper()

# Vrátí aktuální body přiřazené k písmenu (voláno po ukončení otáčení)
func get_current_points() -> int:
	return current_points

# ========================
# Logika losování
# ========================

# Zamíchá pole, resetuje index a přiřadí pevné body každému písmenu pro toto kolo
func _shuffle_letters() -> void:
	letters.shuffle()
	current_index = 0

	# Vygeneruj pevné body pro každé písmeno v tomto kole
	letter_points.clear()
	for letter in letters:
		letter_points[letter] = get_random_points()

# Vylosuje další písmeno v sekvenci (voláno časovačem během otáčení)
# Cyklicky prochází pole písmen, aktualizuje vizuál a přehrává zvuk
func draw_letter() -> void:
	# Posuneme index na další pozici (cyklicky pomocí modulo)
	current_index = (current_index + 1) % letters.size()

	# Aktualizujeme data a vizuál pro tento nový index
	update_visuals()

	# Přehrajeme zvuk s náhodnou variací výšky tónu
	if sound_effect:
		sound_effect.pitch_scale = randf_range(0.9, 1.1)
		sound_effect.play()

# ========================
# Zobrazení stavu
# ========================

# Aktualizuje zobrazení písmena a bodů podle aktuálního indexu
# Body jsou načítány z dictionary (přiřazené při zamíchání), takže stejné písmeno
# má během celého kola stejné body
func update_visuals() -> void:
	if letters.size() > 0:
		current_letter = letters[current_index] as String
		# Načteme pevné body z dictionary (přiřazené při zamíchání)
		current_points = letter_points.get(current_letter, 1)

		# Aktualizace UI
		label.text = current_letter.to_upper()		

# ========================
# Zobrazení bodů
# ========================

# Zobrazí body aktuálního písmena (pokud je v nastavení povoleno)
func points_show() -> void:
	if Settings.is_points_visible:
		points.text = str(current_points)
		points_container.show()

# Skryje zobrazení bodů
func points_hide() -> void:
	points_container.hide()

# ========================
# Výpočty a pomocné funkce
# ========================

# Generuje náhodné body v rozsahu daném nastavením (použito při inicializaci)
func get_random_points() -> int:
	return randi_range(Settings.points_range.x, Settings.points_range.y)

# ========================
# Zpracovani signalu aplikace
# ========================

# Obsluhuje signál Game.signal_spin_finalize (když se otáčení zastaví)
# Zobrazí body a zastaví zvukový efekt
func _on_game_signal_spin_finalize() -> void:
	points_show()
	sound_effect.stop()

# Obsluhuje signál Game.signal_spin_start (když začne otáčení)
# Skryje zobrazení bodů
func _on_game_signal_spin_start() -> void:
	points_hide()
