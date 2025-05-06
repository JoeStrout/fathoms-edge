// This module defines the equipment system — slots, compatibility,
// drawing the equipped icons, etc.  It provides a Loadout class for
// managing what equipment is in which slots.

import "importUtil"
ensureImport "qa"
ensureImport "listUtil"

// Define the base slots.  Loadout goes in one of these.
MAINHAND = "Main Hand"
OFFHAND = "Off Hand"
TWOHAND = "Both Hands"
HEAD = "Head"
NECK = "Neck"
BODY = "Body"
RING = "Ring"
FEET = "Feet"
slots = [MAINHAND, OFFHAND, TWOHAND, HEAD, NECK, BODY, RING, FEET]

slotsExceptTwoHand = slots[:]
slotsExceptTwoHand.removeVal(TWOHAND)

// Load icons for showing each base slot.
slotIcon = {}
for slot in slotsExceptTwoHand
	path = "/usr/pics/slot" + slot.replace(" ", "") + ".png"
	slotIcon[slot] = file.loadImage(path)
	qa.assert slotIcon[slot] != null
end for


// To keep track of what's equipped where, we have this structure:
Loadout = {}
for slot in slotsExceptTwoHand
	Loadout[slot] = null
end for

// Attempt to equip the given item.  Return true if successful,
// false if failed.
Loadout.equip = function(item)
	slot = item.slot
	if not slot then return false
	if slot == RING then
		// Rings are special; we allow only 2 of these, and
		// when equipping a new one, always unequip the oldest
		// of the existing pair.
		if not self[RING] then
			self[RING] = [item]
		else
			qa.assert self[RING] isa list
			if self[RING].indexOf(item) != null then return true
			self[RING].push item
			if self[RING].len > 2 then self[RING].pull
		end if
	else if slot == TWOHAND then
		// Also special are two-hand items, which go into both hand slots
		if self[MAINHAND] == item and self[OFFHAND] == item then return true
		if not self.emptySlot(MAINHAND) then return false
		if not self.emptySlot(OFFHAND) then return false
		self[MAINHAND] = item
		self[OFFHAND] = item
	else if (slot == MAINHAND or slot == OFFHAND) and
	  self[MAINHAND] == self[OFFHAND] then
		// Equipping a 1-hand item, fully unequip a previous 2-hand item
		if not self.emptySlot(MAINHAND) then return false
		if not self.emptySlot(OFFHAND) then return false
		self[slot] = item
	else
		// anything else, just empty the given slot, and store
		if self[slot] == item then return true // already equipped
		if not self.emptySlot(slot) then return false
		self[slot] = item
	end if
	return true
end function

// Attempt to un-equip the given item.  Return true if successful,
// false if failed.   It might fail if the item is cursed, for example
// (or if it's not equipped anyway).
Loadout.unequip = function(item)
	// ToDo: if item.cursed then return false
	found = false
	for slot in slotsExceptTwoHand
		if self[slot] == item then
			self[slot] = null
			found = true
		else if self[slot] isa list and self[slot].contains(item) then
			self.slot.removeVal item
			found = true
		end if
	end for
	return found
end function

// Attempt to empty the given slot.  Return true if it's empty,
// or we successfully unequipped whatever was there; else false.
Loadout.emptySlot = function(slot)
	if slot == TWOHAND then
		return self.emptySlot(MAINHAND) and self.emptySlot(OFFHAND)
	end if
	item = self[slot]
	if item == null then return true
	if item isa list then
		for i in item[:]; self.unequip i; end for
		return not self[slot]
	end if
	return self.unequip(item)
end function

Loadout.slotOfItem = function(item)
	if self[MAINHAND] == item and self[OFFHAND] == item then return TWOHAND
	for slot in slotsExceptTwoHand
		if self[slot] == item then return slot
	end for
end function

// Return the item or items in the given slot.  (May return a list
// in the case of RING or TWOHANDS.)
Loadout.itemInSlot = function(slot)
	if slot == TWOHAND then
		return [self[MAINHAND], self[OFFHAND]]
	else if slot == RING then
		result = self[RING]
		if result isa list and result.len == 1 then result = result[0]
		return result
	else
		return self[slot]
	end if
end function

Loadout.drawSlotIconForItem = function(item, x, y)

end function


runTests = function
	ensureImport "ontology"
	
	errorCount = 0
	assertEqual = function(actual, expected, note)
		if actual != expected then
			print "Unit test failure (" + note + "): expected " + expected + ", got " + actual
			outer.errorCount = errorCount + 1
		end if
	end function

	eq = new Loadout
	assertEqual eq.itemInSlot(FEET), null
	assertEqual eq.itemInSlot(RING), null
	
	// Test gear:
	dagger = Equipment.Make("dagger", null, MAINHAND)
	offDagger = Equipment.Make("offhand dagger", null, OFFHAND)
	broadsword = Equipment.Make("broadsword", null, TWOHAND)
	ring1 = Equipment.Make("ring1", null, RING)
	ring2 = Equipment.Make("ring2", null, RING)
	ring3 = Equipment.Make("ring3", null, RING)
	boots = Equipment.Make("boots", null, FEET)
	sandals = Equipment.Make("sandals", null, FEET)
	
	assertEqual eq.equip(boots), true
	assertEqual eq.itemInSlot(FEET), boots
	assertEqual eq.slotOfItem(boots), FEET

	assertEqual eq.equip(sandals), true
	assertEqual eq.itemInSlot(FEET), sandals
	assertEqual eq.slotOfItem(sandals), FEET
	assertEqual eq.slotOfItem(boots), null
	
	assertEqual eq.equip(sandals), true	// OK to equip already-equipped item!
	assertEqual eq.itemInSlot(FEET), sandals
	assertEqual eq.slotOfItem(sandals), FEET
	assertEqual eq.slotOfItem(boots), null
	
	assertEqual eq.unequip(sandals), true
	assertEqual eq.itemInSlot(FEET), null
	assertEqual eq.slotOfItem(sandals), null

	assertEqual eq.unequip(sandals), false
	
	assertEqual eq.equip(dagger), true
	assertEqual eq.itemInSlot(MAINHAND), dagger
	assertEqual eq.slotOfItem(dagger), MAINHAND
	assertEqual eq.itemInSlot(TWOHAND), [dagger, null]
	
	assertEqual eq.equip(offDagger), true
	assertEqual eq.itemInSlot(MAINHAND), dagger
	assertEqual eq.itemInSlot(OFFHAND), offDagger
	assertEqual eq.slotOfItem(offDagger), OFFHAND
	assertEqual eq.itemInSlot(TWOHAND), [dagger, offDagger]
	
	assertEqual eq.equip(broadsword), true
	assertEqual eq.itemInSlot(MAINHAND), broadsword
	assertEqual eq.itemInSlot(OFFHAND), broadsword
	assertEqual eq.itemInSlot(TWOHAND), [broadsword, broadsword]
	assertEqual eq.slotOfItem(broadsword), TWOHAND
	assertEqual eq.slotOfItem(offDagger), null
		

	print "equipment tests complete.  Failures: " + errorCount
end function

if locals == globals then runTests
