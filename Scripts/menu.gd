extends MarginContainer

# Signály pro komunikaci s game controllerem
signal signal_open_settings  # Vyslán při kliknutí na tlačítko nastavení
signal signal_play_pressed   # Vyslán při kliknutí na play/pause tlačítko
signal signal_help_pressed   # Vyslán při kliknutí na help tlačítko

# Odkazy na tlačítka v menu
@onready var button_play: TextureButton = $HBoxContainer/HBoxContainerRight/ButtonPlay
@onready var button_help: TextureButton = $HBoxContainer/HBoxContainerRight/ButtonHelp
@onready var button_settings: TextureButton = $HBoxContainer/HBoxContainerLeft/ButtonSettings

# Textury pro play/pause stavy hlavního tlačítka
var texture_play: Texture2D = preload("res://Assets/Icons/play.svg")
var texture_pause: Texture2D = preload("res://Assets/Icons/pause.svg")


func _ready() -> void:
	# Připojení hover efektů pro všechna tlačítka
	# (změna průhlednosti při najetí myší)
	button_settings.mouse_entered.connect(_on_button_settings_mouse_entered)
	button_settings.mouse_exited.connect(_on_button_settings_mouse_exited)
	button_play.mouse_entered.connect(_on_button_play_mouse_entered)
	button_play.mouse_exited.connect(_on_button_play_mouse_exited)
	button_help.mouse_entered.connect(_on_button_help_mouse_entered)
	button_help.mouse_exited.connect(_on_button_help_mouse_exited)


# ========================
# Hover efekty tlačítek
# ========================

# Helper pro nastavení průhlednosti tlačítka
# Používá se pro hover efekty (1.0 = plně viditelné, 0.5 = poloviční průhlednost)
func _set_button_alpha(button: TextureButton, alpha: float) -> void:
	button.modulate.a = alpha

# Tlačítko nastavení - hover efekt
func _on_button_settings_mouse_entered() -> void:
	_set_button_alpha(button_settings, 1.0)

func _on_button_settings_mouse_exited() -> void:
	_set_button_alpha(button_settings, 0.5)

# Tlačítko play/pause - hover efekt (pouze pokud není disabled)
func _on_button_play_mouse_entered() -> void:
	if not button_play.disabled:
		_set_button_alpha(button_play, 1.0)

func _on_button_play_mouse_exited() -> void:
	if not button_play.disabled:
		_set_button_alpha(button_play, 0.5)

# Tlačítko nápovědy - hover efekt
func _on_button_help_mouse_entered() -> void:
	_set_button_alpha(button_help, 1.0)

func _on_button_help_mouse_exited() -> void:
	_set_button_alpha(button_help, 0.5)


# ========================
# Veřejné API pro ovládání menu
# ========================

# Nastaví ikonu play tlačítka podle stavu hry
# is_active: true = zobrazí pause ikonu, false = zobrazí play ikonu
func set_play_button_text(is_active: bool) -> void:
	button_play.texture_normal = texture_pause if is_active else texture_play

# Zapne/vypne play tlačítko a upraví jeho vzhled
# disabled: true = tlačítko nelze kliknout (během kola), false = tlačítko aktivní
func set_play_button_disabled(disabled: bool) -> void:
	button_play.disabled = disabled
	# Průhlednost: disabled = 0.1, enabled = 0.5 (0.5 je výchozí, 1.0 při hoveru)
	button_play.modulate.a = 0.1 if disabled else 0.5
	# Kurzor myši: disabled = zakázaný, enabled = ukazovátko
	button_play.mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN if disabled else Control.CURSOR_POINTING_HAND

# Zobrazí tlačítko nápovědy (volá se po dokončení otáčení)
func show_help_button() -> void:
	button_help.visible = true

# Skryje tlačítko nápovědy (volá se při startu nového otáčení)
func hide_help_button() -> void:
	button_help.visible = false


# ========================
# Callback funkce pro kliknutí na tlačítka
# ========================

# Callback pro tlačítko nastavení - otevře settings dialog
func _on_button_settings_pressed() -> void:
	signal_open_settings.emit()

# Callback pro play/pause tlačítko - spustí/zastaví otáčení
func _on_button_play_pressed() -> void:
	signal_play_pressed.emit()

# Callback pro help tlačítko - zobrazí správnou odpověď
func _on_button_help_pressed() -> void:
	signal_help_pressed.emit()
