@tool
extends VBoxContainer

@export var _left_value : LineEdit

var _screen_console : ScreenConsole = ScreenConsole.new()

var _plugin_config : ConfigFile

var _config_path : String = "res://addons/screen_console/plugin.cfg"

# Called when the node enters the scene tree for the first time.
func _ready():
	_load_config()
	
	$SaveButton.connect("pressed", _on_save_button_pressed)


func _on_save_button_pressed():
	_save_config()


func _load_config():
	_plugin_config = ConfigFile.new()
	
	# Load data from a file.
	var err = _plugin_config.load(_config_path)

	# If the file didn't load, ignore it.
	if err != OK:
		return

	_screen_console._debug_enabled = bool(_plugin_config.get_value("config", "debug_enabled"))
	$BasicConfigVBoxContainer/DebugEnabledHBoxContainer/DebugEnabledCheckBox.button_pressed = _screen_console._debug_enabled
	_screen_console._messages_buffer = float(_plugin_config.get_value("config", "buffer"))
	$BasicConfigVBoxContainer/BufferHBoxContainer/BufferLineEdit.value = _screen_console._messages_buffer
	_screen_console._timeout = float(_plugin_config.get_value("config", "timeout"))
	$BasicConfigVBoxContainer/TimeoutHBoxContainer/TimeoutLineEdit.value = _screen_console._timeout
	_screen_console._show_timestamp = bool(_plugin_config.get_value("config", "show_timestamp"))
	$BasicConfigVBoxContainer/TimestampHBoxContainer/TimestampCheckBox.button_pressed = _screen_console._show_timestamp
	_screen_console._vertical_space = float(_plugin_config.get_value("config", "vertical_space"))
	$LayoutVBoxContainer/VerticalSpaceHBoxContainer/VerticalSpaceLineEdit.value = _screen_console._vertical_space
	_screen_console._font_color = _plugin_config.get_value("config", "font_color")
	$AppearanceVBoxContainer/FontColorHBoxContainer/ColorPickerButton.color = Color(_screen_console._font_color)
	_screen_console._background_color = _plugin_config.get_value("config", "background_color")
	$AppearanceVBoxContainer/BackgroundColorHBoxContainer/ColorPickerButton.color = Color(_screen_console._background_color)
	_screen_console._font_size = float(_plugin_config.get_value("config", "font_size"))
	$AppearanceVBoxContainer/FontSizeHBoxContainer/FontSizeLineEdit.value = _screen_console._font_size
	_screen_console._anchor = int(_plugin_config.get_value("config", "anchor"))
	$LayoutVBoxContainer/AnchorHBoxContainer/AnchorOptionButton.select(_screen_console._anchor)
	
	
func _save_config():
	_screen_console._debug_enabled = $BasicConfigVBoxContainer/DebugEnabledHBoxContainer/DebugEnabledCheckBox.button_pressed
	_plugin_config.set_value("config", "debug_enabled", _screen_console._debug_enabled)
	_screen_console._timeout = float($BasicConfigVBoxContainer/BufferHBoxContainer/BufferLineEdit.value)
	_plugin_config.set_value("config", "buffer", _screen_console._messages_buffer)
	_screen_console._timeout = float($BasicConfigVBoxContainer/TimeoutHBoxContainer/TimeoutLineEdit.value)
	_plugin_config.set_value("config", "timeout", _screen_console._timeout)
	_screen_console._show_timestamp = $BasicConfigVBoxContainer/TimestampHBoxContainer/TimestampCheckBox.button_pressed
	_plugin_config.set_value("config", "show_timestamp", _screen_console._show_timestamp)
	_screen_console._vertical_space = float($LayoutVBoxContainer/VerticalSpaceHBoxContainer/VerticalSpaceLineEdit.value)
	_plugin_config.set_value("config", "vertical_space", _screen_console._vertical_space)
	_screen_console._font_color = $AppearanceVBoxContainer/FontColorHBoxContainer/ColorPickerButton.color.to_html(true)
	_plugin_config.set_value("config", "font_color", _screen_console._font_color)
	_screen_console._background_color = $AppearanceVBoxContainer/BackgroundColorHBoxContainer/ColorPickerButton.color.to_html(true)
	_plugin_config.set_value("config", "background_color", _screen_console._background_color)
	_screen_console._font_size = float($AppearanceVBoxContainer/FontSizeHBoxContainer/FontSizeLineEdit.value)
	_plugin_config.set_value("config", "font_size", _screen_console._font_size)
	_screen_console._anchor = int($LayoutVBoxContainer/AnchorHBoxContainer/AnchorOptionButton.selected)
	_plugin_config.set_value("config", "anchor", _screen_console._anchor)
	
	_plugin_config.save(_config_path)
