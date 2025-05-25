// An object of class Inventory manages one collection of objects
// (typically either held by an agent, or in a container).  It
// manages stacking identical items together.

import "importUtil"
ensureImport "miscUtil"

globals.Inventory = {}

Inventory.capacity = 10  // total size of objects this can contain
Inventory.items = null   // list: current stacks of items in this inventory

Inventory.Make = function
	noob = new self
	noob.items = []
	return noob
end function

Inventory.str = function
	result = []
	for stack in self.items
		result.push stack.nameWithQty
	end for
	return result.join("; ")
end function

Inventory.totalOf = function(attribute)
	sum = 0
	for stack in self.items
		if stack.qty == null then qty = 1 else qty = stack.qty
		sum += stack[attribute] * qty
	end for
	return sum
end function

Inventory.totalQty = function
	return self.totalOf("qty")
end function

Inventory.totalValue = function
	return self.totalOf("value")
end function

Inventory.totalSize = function
	return self.totalOf("size")
end function

Inventory.indexByName = function(itemName)
	for i in items.indexes
		if items[i].name == itemName then return i
	end for
	return null
end function

// Add some or all of the given item stack (i.e. some quantity of 
// one type of Item) to this inventory.  Return the remainder that we 
// did not store (because of request or capacity limits), or null if we 
// successfully stored the entire stack.  Note: qtyToStore < 0 means
// to store all of the given stack (or as much as possible).
Inventory.add = function(newStack, qtyToStore=1)
	if qtyToStore < 0 then
		if newStack.qty == null then qtyToStore = 1 else qtyToStore = newStack.qty
	else if newStack.qty != null and qtyToStore > newStack.qty then
		qtyToStore = newStack.qty
	end if
	
	// Figure out how many we can fit
	availableSpace = self.capacity - self.totalSize
	canFit = floor(availableSpace / newStack.size)
	if canFit < 1 then return newStack	// (none -- return given stack)
	if qtyToStore > canFit then qtyToStore = canFit
	
	if newStack.stackable then
		// Look for an existing stack we can add these items to
		for curStack in self.items
			if newStack.canStackWith(curStack) then
				curStack.qty += qtyToStore
				newStack.qty -= qtyToStore
				qtyToStore = 0
				if newStack.qty < 1 then return null else return newStack
			end if
		end for
	end if
	
	// If we're storing less than the full given stack, split it
	if newStack.qty != null and qtyToStore < newStack.qty then
		portionToStore = newStack + {}
		portionToStore.id = Thing.UnusedId
		portionToStore.qty = qtyToStore
		newStack.qty -= qtyToStore
		self.items.push portionToStore
		return newStack
	end if
	
	// Otherwise, just add to our inventory list and we're done.
	self.items.push newStack
	return null
end function

// NOTE: to add an item to an Inventory object, call the add method
// above.  Do not call push.  That doesn't work.
Inventory.push = function(bogusParam)
	ensureImport "qa"
	qa.abort "Somebody called `push` on an Inventory object instead of `add`."
end function

// Remove some or all of the given stack, which should be an actual object
// in our items list.  If qtyToTake < 0, then it is interpreted as meaning
// the entire stack.  Otherwise, if qtyToTake is less than the entire stack,
// return a new item representing the removed portion, and reduce the qty in
// the existing stack accordingly.  In any case, return what was removed from
// this inventory.
Inventory.remove = function(curStack, qtyToTake=1)
	if qtyToTake < 0 then
		if curStack.qty == null then qtyToTake = 1 else qtyToTake = curStack.qty
	else if curStack.qty != null and qtyToTake > curStack.qty then
		qtyToTake = curStack.qty
	end if
	
	// Simple case: taking the entire stack.
	if curStack.qty == null or qtyToRemove >= curStack.qty then
		items.remove items.refIndexOf(curStack)
		return curStack
	end if
	
	// Harder case: split the stack, returning a new object representing
	// the portion removed.
	portionToTake = curStack + {}
	portionToTake.id = Thing.UnusedId
	portionToTake.qty = qtyToTake
	curStack.qty -= qtyToTake
	return portionToTake
end function

runUnitTests = function
	ensureImport "ontology"
	
	errorCount = 0
	assertEqual = function(actual, expected, note)
		if actual != expected then
			print "Unit test failure (" + note + "): expected " + expected + ", got " + actual
			print " at " + stackTrace[1]
			outer.errorCount = errorCount + 1
		end if
	end function
	
	globals.inv = Inventory.Make
	assertEqual inv.str, ""
	
	inv.add Food.Make("apple", 943)
	assertEqual inv.str, "apple"
	
	inv.add Food.Make("banana", 943)
	assertEqual inv.str, "apple; banana"
	
	remainder = inv.add(Food.Make("apple", 943))
	assertEqual remainder, null
	assertEqual inv.str, "2× apple; banana"
	
	bananas = Food.Make("banana")
	bananas.qty = 3
	remainder = inv.add(bananas, 3)
	assertEqual remainder, null
	assertEqual inv.str, "2× apple; 4× banana"
	
	bananas = Food.Make("banana")
	bananas.qty = 5
	remainder = inv.add(bananas, 1)
	assertEqual remainder.nameWithQty, "4× banana"
	assertEqual inv.str, "2× apple; 5× banana"	
	assertEqual bananas, remainder
	
	remainder = inv.add(remainder, -1)
	assertEqual remainder.nameWithQty, "banana"
	assertEqual inv.str, "2× apple; 8× banana"
	assertEqual inv.totalSize, 10
	
	taken = inv.remove(Food.Make("banana", 943))
	assertEqual taken.nameWithQty, "banana"
	assertEqual inv.str, "2× apple; 7× banana"
		
	inv2 = Inventory.Make
	watermelon = Food.Make("watermelon")
	watermelon.size = 4
	watermelon.qty = 5
	remainder = inv2.add(watermelon, -1)
	assertEqual inv2.str, "2× watermelon"
	assertEqual remainder.nameWithQty, "3× watermelon"
	assertEqual inv2.totalSize, 8

	remainder = inv2.add(watermelon, -1)
	assertEqual remainder, watermelon
	assertEqual inv2.str, "2× watermelon"
	assertEqual remainder.nameWithQty, "3× watermelon"

	remainder = inv2.add(Food.Make("apple", 943))
	assertEqual remainder, null
	assertEqual inv2.str, "2× watermelon; apple"
	assertEqual inv2.totalSize, 9

	
	print "Inventory tests complete.  Failures: " + errorCount
end function

if locals == globals then runUnitTests
