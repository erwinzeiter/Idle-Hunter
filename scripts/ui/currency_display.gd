extends Label
## CurrencyDisplay - Displays a single currency amount
## 
## Pure UI component - no game logic, only displays data from GameState

## Currency type to display
@export var currency_type: String = "souls"

## Format string for display (use %s for amount)
@export var format_string: String = "Souls: %s"

func _ready() -> void:
	# Connect to GameState signals
	GameState.currency_changed.connect(_on_currency_changed)
	
	# Initial update
	_update_display()

func _on_currency_changed(changed_currency_type: String, new_amount: float) -> void:
	# Only update if this is our currency type
	if changed_currency_type == currency_type:
		_update_display()

func _update_display() -> void:
	var amount: float = GameState.get_currency(currency_type)
	text = format_string % _format_number(amount)

## Format large numbers in a readable way
func _format_number(num: float) -> String:
	if num < 1000:
		return str(int(num))
	elif num < 1000000:
		return "%.2fK" % (num / 1000.0)
	elif num < 1000000000:
		return "%.2fM" % (num / 1000000.0)
	else:
		return "%.2fB" % (num / 1000000000.0)
