// Miscellaneous utility functions.

// Roll against a % probability (0-100).
// Return true on success, false on failure.
globals.chance = function(percentChance)
	roll = round(100 * rnd)
	return roll < percentChance
end function

// Get a non-hidden copy of refIndexOf (finding index of an item
// by reference), since that is a thing we often need.
list.refIndexOf = @list._refIndexOf

// A version of list.indexOf that compares object by reference,
// instead of by their values.  Use this when you might have
// identical objects in the list, but you want to find some 
// specific object (not just an equivalent one).
list.containsRef = function(item)
	return self._refIndexOf(item) != null
end function


// Similarly, remove a list element by reference.
list.removeRef = function(item)
	idx = self._refIndexOf(item)
	if idx != null then self.remove idx
end function
