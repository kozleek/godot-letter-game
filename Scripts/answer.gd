extends Node

# Odkazy na UI prvky
@onready var answer_container: PanelContainer = $"."
@onready var label: Label = $MarginContainer/Label

# Dictionary s předgenerovanými odpověďmi ve struktuře: { "SUB_KEY": { "A": "odpověď", "B": ... } }
var answers: Dictionary = {}

func _ready() -> void:
	_load_answers()
	hide_answer()

# ========================
# Načtení předgenerovaných odpovědí
# ========================

func _load_answers() -> void:
	# Kontrola, zda je aktuální jazyk podporován (má předgenerované odpovědi)
	if Settings.current_language not in Settings.LANGS_WITH_HELP:
		push_warning("[Answer] Jazyk %s nemá předgenerované odpovědi" % Settings.current_language)
		answers = {}  # Vyčistíme odpovědi
		return

	# Určení cesty k souboru podle jazyka
	var path = _get_answers_path()

	# Kontrola existence souboru s odpověďmi
	if not FileAccess.file_exists(path):
		push_warning("[Answer] Soubor nenalezen: %s" % path)
		return

	# Pokus o otevření souboru - může selhat kvůli oprávněním nebo jiným IO problémům
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("[Answer] Soubor nelze otevřít: %s. Chyba: %s" % [path, FileAccess.get_open_error()])
		return

	# Načtení celého obsahu souboru jako text
	var json_text = file.get_as_text()
	file.close()

	# Parsování JSON dat
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result != OK:
		push_error("[Answer] Nelze načíst JSON formát. Chyba na řádku %d: %s" % [json.get_error_line(), json.get_error_message()])
		return

	# Validace typu - root musí být Dictionary
	if typeof(json.data) != TYPE_DICTIONARY:
		push_error("[Answer] JSON musí být typ Dictationary. Typ: %s" % type_string(typeof(json.data)))
		return

	# Úspěšné načtení - uložení dat do globální proměnné
	answers = json.data

# ========================
# Helper funkce pro určení cesty k souboru s odpověďmi
# ========================

# Vrací cestu k souboru s odpověďmi podle aktuálního jazyka
func _get_answers_path() -> String:
	if Settings.current_language == "cs":
		return Settings.ANSWERS_PATH
	elif Settings.current_language == "en":
		return Settings.ANSWERS_EN_PATH
	else:
		# Pro ostatní jazyky používáme vzor: res://Data/answers_{lang}.json
		return "res://Data/answers_%s.json" % Settings.current_language

# ========================
# Získání odpovědi pro kategorii a písmeno
# ========================

func get_answer(subject: String, letter: String) -> String:
	# Vyhledání kategorie v načtených datech
	if answers.has(subject):
		var subject_data = answers[subject]
		# Vyhledání písmena v rámci kategorie
		if subject_data.has(letter):
			return subject_data[letter]
	# Pokud odpověď neexistuje, vrací prázdný řetězec
	return ""
	
# ========================
# Zobrazení a skrytí odpovědi
# ========================

func show_answer(subject: String, letter: String) -> void:
	# Získání odpovědi pro zadanou kategorii a písmeno
	var answer_text = get_answer(subject, letter)
	if answer_text != "":
		# Pokud odpověď existuje, zobrazíme kontejner a nastavíme text
		answer_container.show()
		label.text = answer_text
	else:
		# Pokud odpověď neexistuje, schováme kontejner
		hide_answer()

func hide_answer() -> void:
	# Skrytí kontejneru s odpovědí a vyčištění textu
	answer_container.hide()
	label.text = ""
