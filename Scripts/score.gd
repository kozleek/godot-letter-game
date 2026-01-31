class_name Score
extends HBoxContainer

@onready var sound_effect: AudioStreamPlayer2D = $SoundEffect
@onready var team1_button: Button = $Team1
@onready var team2_button: Button = $Team2
@onready var team1_score_label: Label = $Team1/Score
@onready var team2_score_label: Label = $Team2/Score

var scoring_enabled: bool = false
var current_points_to_add: int = 0
var team1_scored: bool = false  # Zda už Team1 získal body v aktuálním bodování
var team2_scored: bool = false  # Zda už Team2 získal body v aktuálním bodování

# LineEdit nody pro ruční editaci skóre (vytvořeny programaticky)
var team1_score_input: LineEdit
var team2_score_input: LineEdit

func _ready() -> void:
	disable_scoring()
	update_display()
	update_visibility()
	_create_score_input_fields()

func _input(event: InputEvent) -> void:
	# Přičítání bodů pomocí klávesových zkratek
	if event.is_action_pressed("team1_score"):
		add_points_to_team1()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("team2_score"):
		add_points_to_team2()
		get_viewport().set_input_as_handled()

	# Ruční editace skóre pravým tlačítkem myši
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			var mouse_pos = get_global_mouse_position()

			# Kontrola, zda se myš nachází nad Team1 tlačítkem
			if team1_button.get_global_rect().has_point(mouse_pos):
				_start_manual_score_edit(1)
				get_viewport().set_input_as_handled()
			# Kontrola, zda se myš nachází nad Team2 tlačítkem
			elif team2_button.get_global_rect().has_point(mouse_pos):
				_start_manual_score_edit(2)
				get_viewport().set_input_as_handled()

# ========================
# Veřejné funkce
# ========================

## Povolí přičítání bodů a nastaví hodnotu bodů, které se přičtou při kliknutí
func enable_scoring(points: int) -> void:
	# Pokud není zobrazování bodů povoleno, nepovoluji scoring
	if not Settings.is_points_visible:
		print("[Score] Skorování není povoleno - zobrazování bodů je vypnuto")
		return

	scoring_enabled = true
	current_points_to_add = points
	team1_scored = false
	team2_scored = false
	_update_buttons_state()
	print("[Score] Skorování povoleno, Body: ", points)

## Zakáže přičítání bodů
func disable_scoring() -> void:
	scoring_enabled = false
	current_points_to_add = 0
	team1_scored = false
	team2_scored = false
	_update_buttons_state()
	print("[Score] Skorování zakazáno")

## Přičte body týmu 1
func add_points_to_team1() -> void:
	if not scoring_enabled or team1_scored:
		print("[Score] Team 1: Body nelze přidat")
		return

	Settings.team1_score += current_points_to_add
	team1_scored = true
	update_display()
	_update_buttons_state()
	UserData.save_settings()
	print("[Score] Team 1: +", current_points_to_add, " b. Score: ", Settings.team1_score)

	# Vizuální efekt
	if Visuals:
		Visuals.pop_animation(team1_button, 1.3, 0.1)
		
	sound_effect.play()

## Přičte body týmu 2
func add_points_to_team2() -> void:
	if not scoring_enabled or team2_scored:
		print("[Score] Team 2: Body nelze přidat")
		return

	Settings.team2_score += current_points_to_add
	team2_scored = true
	update_display()
	_update_buttons_state()
	UserData.save_settings()
	print("[Score] Team 2: +", current_points_to_add, " b. Score: ", Settings.team2_score)

	# Vizuální efekt
	if Visuals:
		Visuals.pop_animation(team2_button, 1.3, 0.1)
		
	sound_effect.play()

## Aktualizuje zobrazení skóre
func update_display() -> void:
	team1_score_label.text = str(Settings.team1_score)
	team2_score_label.text = str(Settings.team2_score)	

## Resetuje skóre obou týmů
func reset_scores() -> void:
	Settings.team1_score = 0
	Settings.team2_score = 0
	update_display()
	UserData.save_settings()
	print("[Score] Skorování resetováno")

## Aktualizuje viditelnost podle nastavení
func update_visibility() -> void:
	visible = Settings.is_points_visible
	if not visible:
		disable_scoring()
	print("[Score] Viditelnost nastavena na: ", visible)

# ========================
# Privátní funkce
# ========================

## Aktualizuje stav tlačítek podle toho, zda je scoring povolený a zda už týmy bodovaly
func _update_buttons_state() -> void:
	# Team1 tlačítko - aktivní pouze pokud je scoring enabled a team1 ještě nebodoval
	var team1_enabled = scoring_enabled and not team1_scored
	team1_button.disabled = not team1_enabled
	team1_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if team1_enabled else Control.CURSOR_FORBIDDEN

	# Team2 tlačítko - aktivní pouze pokud je scoring enabled a team2 ještě nebodoval
	var team2_enabled = scoring_enabled and not team2_scored
	team2_button.disabled = not team2_enabled
	team2_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if team2_enabled else Control.CURSOR_FORBIDDEN

# ========================
# Ruční editace skóre
# ========================

## Vytvoří LineEdit pole pro ruční editaci skóre
func _create_score_input_fields() -> void:
	# Vytvoření LineEdit pro Team1
	team1_score_input = LineEdit.new()
	team1_button.add_child(team1_score_input)
	_configure_line_edit(team1_score_input, str(Settings.team1_score))
	team1_score_input.text_submitted.connect(_on_team1_score_submitted)
	team1_score_input.focus_exited.connect(_on_team1_focus_exited)

	# Vytvoření LineEdit pro Team2
	team2_score_input = LineEdit.new()
	team2_button.add_child(team2_score_input)
	_configure_line_edit(team2_score_input, str(Settings.team2_score))
	team2_score_input.text_submitted.connect(_on_team2_score_submitted)
	team2_score_input.focus_exited.connect(_on_team2_focus_exited)

## Konfiguruje vzhled a chování LineEdit pole
func _configure_line_edit(line_edit: LineEdit, placeholder: String) -> void:
	# Layout - stejné nastavení jako Label (full rect)
	line_edit.layout_mode = 1
	line_edit.set_anchors_preset(Control.PRESET_FULL_RECT)
	line_edit.anchor_right = 1.0
	line_edit.anchor_bottom = 1.0
	line_edit.grow_horizontal = Control.GROW_DIRECTION_BOTH
	line_edit.grow_vertical = Control.GROW_DIRECTION_BOTH
	line_edit.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
	line_edit.size_flags_vertical = Control.SIZE_FILL | Control.SIZE_EXPAND
	line_edit.offset_left = 0
	line_edit.offset_top = 0
	line_edit.offset_right = 0
	line_edit.offset_bottom = 0

	# Nastavení fontu a zarovnání
	line_edit.add_theme_font_size_override("font_size", 48)
	line_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Vypnutí default padding/margins, které způsobují větší šířku
	line_edit.add_theme_constant_override("minimum_character_width", 0)
	line_edit.expand_to_text_length = false

	# Průhledné pozadí bez ohraničení
	var transparent_style = StyleBoxFlat.new()
	transparent_style.bg_color = Color(0, 0, 0, 0)  # Průhledná barva
	transparent_style.border_width_left = 0
	transparent_style.border_width_top = 0
	transparent_style.border_width_right = 0
	transparent_style.border_width_bottom = 0

	line_edit.add_theme_stylebox_override("normal", transparent_style)
	line_edit.add_theme_stylebox_override("focus", transparent_style)
	line_edit.add_theme_stylebox_override("read_only", transparent_style)

	# Hezčí barva výběru textu (světle modrá)
	line_edit.add_theme_color_override("selection_color", Color(0.4, 0.6, 1.0, 0.5))

	# Vlastnosti vstupu
	line_edit.max_length = 4
	line_edit.placeholder_text = placeholder
	line_edit.select_all_on_focus = true
	line_edit.virtual_keyboard_enabled = true

	# Defaultně skryté
	line_edit.visible = false

## Zahájí ruční editaci skóre pro daný tým
func _start_manual_score_edit(team_number: int) -> void:
	var score_label: Label
	var score_input: LineEdit
	var button: Button

	if team_number == 1:
		score_label = team1_score_label
		score_input = team1_score_input
		button = team1_button
	else:
		score_label = team2_score_label
		score_input = team2_score_input
		button = team2_button

	# Skrytí Label a zobrazení LineEdit
	score_label.visible = false
	score_input.visible = true

	# Nastavení textu a focus
	score_input.text = score_label.text
	score_input.grab_focus()
	score_input.select_all()

	# Dočasná deaktivace tlačítka
	button.disabled = true

	print("[Score] Zahájení ruční editace skóre pro Team", team_number)

## Dokončí ruční editaci skóre s validací
func _finish_manual_score_edit(team_number: int, new_score_text: String) -> void:
	# Validace vstupu
	var new_score: int = 0

	# Kontrola, že obsahuje pouze čísla
	if new_score_text.is_valid_int():
		new_score = new_score_text.to_int()

		# Kontrola na záporné hodnoty
		if new_score < 0:
			new_score = 0
			push_warning("[Score] Záporné skóre není povoleno, nastaveno na 0")
	else:
		# Prázdný nebo nevalidní vstup = 0
		if new_score_text != "":
			push_warning("[Score] Neplatný vstup '%s', nastaveno na 0" % new_score_text)
		new_score = 0

	# Aktualizace skóre
	if team_number == 1:
		Settings.team1_score = new_score
		print("[Score] Team1 skóre ručně upraveno na: ", new_score)
	else:
		Settings.team2_score = new_score
		print("[Score] Team2 skóre ručně upraveno na: ", new_score)

	# Uložení a aktualizace zobrazení
	UserData.save_settings()
	update_display()

	# Ukončení editace
	_cancel_manual_score_edit(team_number)

## Zruší ruční editaci skóre bez změn
func _cancel_manual_score_edit(team_number: int) -> void:
	var score_label: Label
	var score_input: LineEdit
	var button: Button

	if team_number == 1:
		score_label = team1_score_label
		score_input = team1_score_input
		button = team1_button
	else:
		score_label = team2_score_label
		score_input = team2_score_input
		button = team2_button

	# Zobrazení Label a skrytí LineEdit
	score_input.visible = false
	score_label.visible = true

	# Obnovení stavu tlačítka
	_update_buttons_state()

	print("[Score] Zrušení ruční editace skóre pro Team", team_number)

# ========================
# Signal handlery pro LineEdit
# ========================

## Handler pro potvrzení nového skóre Team1 (Enter)
func _on_team1_score_submitted(new_text: String) -> void:
	_finish_manual_score_edit(1, new_text)

## Handler pro potvrzení nového skóre Team2 (Enter)
func _on_team2_score_submitted(new_text: String) -> void:
	_finish_manual_score_edit(2, new_text)

## Handler pro ztrátu fokusu Team1 (zrušení editace)
func _on_team1_focus_exited() -> void:
	# Zrušení editace pouze pokud je LineEdit viditelný (editace probíhá)
	if team1_score_input.visible:
		_cancel_manual_score_edit(1)

## Handler pro ztrátu fokusu Team2 (zrušení editace)
func _on_team2_focus_exited() -> void:
	# Zrušení editace pouze pokud je LineEdit viditelný (editace probíhá)
	if team2_score_input.visible:
		_cancel_manual_score_edit(2)
