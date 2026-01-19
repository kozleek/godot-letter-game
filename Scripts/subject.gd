class_name Subject
extends Node

@onready var sound_effect: AudioStreamPlayer2D = $SoundEffect
@onready var label: Label = $Label

var subjects: Array = []           # Pole překladových klíčů kategorií z Settings.SUBJECTS (např. ["SUB_MESTO", "SUB_ZVIRE", ...])
var current_index: int = 0         # Cyklický index do pole subjects (0 až subjects.size()-1)

var current_subject_key: String = "" # Drží překladový klíč aktuální kategorie (např. "SUB_MESTO")
var current_subject: String = ""     # Drží přeložený název kategorie (např. "Město" pro CS, "City" pro EN)

func _ready() -> void:
	# Načteme pole překladových klíčů kategorií ze Settings
	subjects = Settings.SUBJECTS

	# Zamícháme pole pro náhodné pořadí
	_shuffle_subjects()

	# Zobrazíme výchozí (první) kategorii
	update_visuals()

# ========================
# Gettery pro hlavní aplikaci
# ========================

# Vrací aktuálně vybranou přeloženou kategorii (např. "Město" v češtině)
# Používá se v Game.gd po finalizaci spinování (game.gd:106)
# Pro získání odpovědi z answers.json v Answer.gd (answer.gd)
func get_current_subject() -> String:
	return current_subject

# ========================
# Logika losování
# ========================

# Zamíchá pole kategorií a resetuje index na začátek
# Volá se pouze při inicializaci v _ready()
# Zajišťuje náhodné pořadí kategorií při každém spuštění hry
# Privátní metoda - prefix '_' označuje interní použití
func _shuffle_subjects() -> void:
	subjects.shuffle()
	current_index = 0

# Posune se na další kategorii v cyklu a aktualizuje zobrazení
# Voláno z Game.gd v časovači během spinování (game.gd:158)
# Index se pohybuje cyklicky od 0 do subjects.size()-1
func draw_subject() -> void:
	if subjects.size() == 0:
		return

	# Posun indexu s automatickým návratem na nulu (modulo)
	current_index = (current_index + 1) % subjects.size()

	update_visuals()

# ========================
# Zobrazení stavu
# ========================

# Aktualizuje zobrazení kategorie podle aktuálního indexu
# Přeloží překladový klíč pomocí tr() na jazyk vybraný v nastavení
# Veřejná metoda - může být volána externě pro vynucené obnovení zobrazení
func update_visuals() -> void:
	if subjects.size() > 0:
		# Uložení aktuálního klíče
		current_subject_key = subjects[current_index] as String
		# Uložení přeloženého textu (tr = translation funkcí Godotu)
		current_subject = tr(current_subject_key)

	# Aktualizace UI labelu s přeloženým názvem kategorie
	label.text = current_subject

# ========================
# Zpracování signálů z aplikace
# ========================

# Handler pro signál signal_spin_finalize z Game.gd
# Přehraje zvukový efekt při finalizaci spinování
# Připojeno automaticky přes Godot editor (scene connection)
func _on_game_signal_spin_finalize() -> void:
	sound_effect.play()
