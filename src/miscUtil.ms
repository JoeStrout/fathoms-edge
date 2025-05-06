// Miscellaneous utility functions.

// Roll against a % probability (0-100).
// Return true on success, false on failure.
globals.chance = function(percentChance)
	roll = round(100 * rnd)
	return roll < percentChance
end function
