class_name FormatUtils
## Utility class for formatting numbers and text
## 
## Static utility class - no instance needed

# Format thresholds
const THOUSAND: float = 1000.0
const MILLION: float = 1000000.0
const BILLION: float = 1000000000.0

## Format large numbers in a readable way (K, M, B notation)
static func format_number(num: float) -> String:
	if num < THOUSAND:
		return str(int(num))
	elif num < MILLION:
		return "%.2fK" % (num / THOUSAND)
	elif num < BILLION:
		return "%.2fM" % (num / MILLION)
	else:
		return "%.2fB" % (num / BILLION)

## Format a stat value based on its type
static func format_stat(stat_name: String, value: float) -> String:
	# For percentages (stats like crit_chance)
	if stat_name.contains("chance"):
		return "%.1f%%" % (value * 100.0)
	
	# For multipliers
	if stat_name.contains("multiplier"):
		return "%.2fx" % value
	
	# For regular numbers
	if value < THOUSAND:
		return "%.1f" % value
	elif value < MILLION:
		return "%.2fK" % (value / THOUSAND)
	else:
		return "%.2fM" % (value / MILLION)
