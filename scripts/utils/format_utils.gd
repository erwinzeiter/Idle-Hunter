class_name FormatUtils
## Utility class for formatting numbers and text
## 
## Static utility class - no instance needed

## Format large numbers in a readable way (K, M, B notation)
static func format_number(num: float) -> String:
	if num < 1000:
		return str(int(num))
	elif num < 1000000:
		return "%.2fK" % (num / 1000.0)
	elif num < 1000000000:
		return "%.2fM" % (num / 1000000.0)
	else:
		return "%.2fB" % (num / 1000000000.0)

## Format a stat value based on its type
static func format_stat(stat_name: String, value: float) -> String:
	# For percentages (stats like crit_chance)
	if stat_name.contains("chance"):
		return "%.1f%%" % (value * 100.0)
	
	# For multipliers
	if stat_name.contains("multiplier"):
		return "%.2fx" % value
	
	# For regular numbers
	if value < 1000:
		return "%.1f" % value
	elif value < 1000000:
		return "%.2fK" % (value / 1000.0)
	else:
		return "%.2fM" % (value / 1000000.0)
