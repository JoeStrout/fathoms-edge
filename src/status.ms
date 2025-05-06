// This file defines and manages status effects -- things like STUNNED,
// POISONED, BLESSED, etc.  These effects alter your effective stats or
// abilities while they are in effect.  Most of them wear off after some
// number of turns, or can be cured (removed) by various means.


POISONED = "POISONED"
WEAKENED = "WEAKENED"
VULNERABLE = "VULNERABLE"
INVULNERABLE = "INVULNERABLE"
STUNNED = "STUNNED"
SLOWED = "SLOWED"
HASTENED = "HASTENED"
CONFUSED = "CONFUSED"
BLIND = "BLIND"
DEAF = "DEAF"
HALLUCINATING = "HALLUCINATING"
ONFIRE = "ONFIRE"
FROZEN = "FROZEN"
WET = "WET"
BLESSED = "BLESSED"
CURSED = "CURSED"
CHARMED = "CHARMED"
ENCUMBERED = "ENCUMBERED"
FATIGUED = "FATIGUED"
STARVING = "STARVING"
GLOWING = "GLOWING"
MUTE = "MUTE"
PANICKED = "PANICKED"
SERENE = "SERENE"


// A special "max" function which considers null to be greater
// than any non-null number (i.e., null means infinite):
max = function(a,b)
	if a == null or b == null then return null
	if a > b then return a else return b
end function

// StatusHolder: a class that can contain any number of current
// statuses.  This will be used by the player and other agents
// to keep track of what status effects currently apply.
globals.StatusHolder = {}
// items: a map with key: status; value: turn at which the effect
//        will wear off (or null for a permanent effect)
StatusHolder.items = null

StatusHolder.Make = function
	noob = new StatusHolder
	noob.items = {}
	return noob
end function

StatusHolder.dodgeModifier = function
	if self.items.hasIndex(STUNNED) then return 0
	if self.items.hasIndex(FROZEN) then return 0
	modifier = 1
	for st in [WEAKENED, SLOWED, BLIND, ENCUMBERED, FATIGUED, PANICKED]
		if self.items.hasIndex(st) then modifier *= 0.5
	end for
	return modifier
end function

// Add a new status effect to this set of statuses.
// Makes use of the global turn number.
StatusHolder.apply = function(newStatus="BLESSED", duration=10)
	endTurn = duration + turn // (yields null if duration is null)
	if self.items.hasIndex(newStatus) then
		self.items[newStatus] = max(self.items[newStatus], endTurn)
	else
		self.items[newStatus] = endTurn
	end if
	self.update
end function

// Remove the given status effect.  This is used when a player
// employs some active means of removing statuses, e.g., an altar
// or some such.  It's not used when status effects simply wear off.
StatusHolder.remove = function(statusToRemove="BLESSED")
	self.items.remove statusToRemove
end function

// Return whether this set of statuses includes the given one.
StatusHolder.hasStatus = function(status="BLESSED")
	return self.items.hasIndex(status)
end function

// Return all current status effects, in alphabetical order.
StatusHolder.all = function
	fx = self.items.indexes
	fx.sort
	return fx
end function

// Helper method to handle opposite effects which cancel each
// other out.  But note that if one is permanent and the other is
// not, then the permanent effect always cancels the temporary one.
StatusHolder.cancelOut = function(status1, status2)
	has1 = self.items.hasIndex(status1)
	has2 = self.items.hasIndex(status2)
	if not has1 or not has2 then return
	if self.items[status1] == null and self.items[status2] == null then
		// BOTH effects are permanent -- cancel both
		self.items.remove status1
		self.items.remove status2
	else
		// cancel temporary effects
		if self.items[status1] != null then self.items.remove status1
		if self.items[status2] != null then self.items.remove status2
	end if
end function

// Update our current status effects, based on the global turn
// number.  This removes any effects which have worn off, and also
// removes any effects that cancel each other out.
StatusHolder.update = function
	for status in self.items.indexes
		endTurn = self.items[status]
		if endTurn != null and turn >= endTurn then self.items.remove status
	end for
	
	self.cancelOut VULNERABLE, INVULNERABLE
	self.cancelOut SLOWED, HASTENED
	self.cancelOut BLESSED, CURSED
	self.cancelOut PANICKED, SERENE
	self.cancelOut FROZEN, ONFIRE
	if self.hasStatus(FROZEN) and self.hasStatus(WET) then self.remove WET	
end function


runTests = function
	errorCount = 0
	assertEqual = function(actual, expected, note)
		if actual != expected then
			print "Unit test failure (" + note + "): expected " + expected + ", got " + actual
			outer.errorCount = errorCount + 1
		end if
	end function

	globals.turn = 5
	sh = StatusHolder.Make
	assertEqual sh.hasStatus("FOO"), false
	sh.apply "FOO", 10
	sh.apply "PERM", null
	assertEqual sh.items["FOO"], 15
	assertEqual sh.hasStatus("FOO"), true
	assertEqual sh.hasStatus("BAR"), false
	assertEqual sh.hasStatus("PERM"), true
	globals.turn = 10
	sh.update
	sh.apply "FOO", 3
	sh.apply "BAR", 3
	assertEqual sh.items["FOO"], 15
	assertEqual sh.hasStatus("FOO"), true
	assertEqual sh.hasStatus("BAR"), true
	assertEqual sh.hasStatus("PERM"), true
	assertEqual sh.all, ["BAR", "FOO", "PERM"]
	globals.turn = 15
	sh.update
	assertEqual sh.hasStatus("FOO"), false
	assertEqual sh.hasStatus("BAR"), false
	assertEqual sh.hasStatus("PERM"), true
	sh.remove "PERM"
	assertEqual sh.hasStatus("PERM"), false
	
	sh.apply SLOWED, 5
	sh.update; globals.turn += 1
	assertEqual sh.hasStatus(SLOWED), true
	assertEqual sh.dodgeModifier, 0.5
	sh.apply HASTENED, 3
	assertEqual sh.hasStatus(SLOWED), false
	assertEqual sh.hasStatus(HASTENED), false
	sh.update; globals.turn += 1
	sh.apply INVULNERABLE, null
	assertEqual sh.hasStatus(INVULNERABLE), true
	assertEqual sh.hasStatus(VULNERABLE), false
	sh.apply VULNERABLE, 5
	assertEqual sh.hasStatus(INVULNERABLE), true
	assertEqual sh.hasStatus(VULNERABLE), false
	sh.apply VULNERABLE, null
	assertEqual sh.hasStatus(INVULNERABLE), false
	assertEqual sh.hasStatus(VULNERABLE), false
	sh.apply INVULNERABLE, 5
	assertEqual sh.hasStatus(INVULNERABLE), true
	assertEqual sh.hasStatus(VULNERABLE), false
	sh.apply VULNERABLE, null
	assertEqual sh.hasStatus(INVULNERABLE), false
	assertEqual sh.hasStatus(VULNERABLE), true
	
	print "statusEffects tests complete.  Failures: " + errorCount
end function

if locals == globals then runTests
