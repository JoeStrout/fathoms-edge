// This file defines our damage/resistance types, and some little utility
// code related to that.


types = ["physical", "fire", "cold", "shock", "poison", "necrotic"]

// Damage: represents *points* of damage, e.g., if fire = 5,
// then this represents 5 points of fire damage.
globals.Damage = {}
for type in types; Damage[type] = 0; end for

Damage.str = function
	result = ""
	for type in types
		if not self[type] then continue
		if result then
			if self[type] > 0 then result += " + " else result += " - "
		end if
		result += abs(self[type])
		if type != "physical" then
			result += " " + type[0].upper + type[1:]
		end if
	end for
	if not result then result = "No damage"
	return result
end function


// Resistance: *percentage* resistance, e.g., if fire = 25,
// then this means 25% resistance to fire damage (actualy 
// damage applied is only 75% of normal).
globals.Resistance = {}
for type in types; Resistance[type] = 0; end for

Resistance.str = function
	result = []
	for type in types
		if self[type] then result.push self[type] + "% " + type[0].upper + type[1:]
	end for
	return result.join(", ")
end function

// Add the other resistance to this one, return result as a new Damage object.
Resistance.add = function(other, capAt100=true)
	result = self + {}
	for type in types
		result[type] += other[type]
		if capAt100 and result[type] > 100 then result[type] = 100
	end for
	return result
end function

// Apply this resistance to the given damage; return a new Damage object
// representing the final damage to apply.
Resistance.apply = function(damage)
	result = damage + {}
	for type in types
		pct = 100 - self[type]
		if pct != 100 then result[type] = ceil(result[type] * pct / 100)
	end for
	return result
end function

runTests = function
	errorCount = 0
	assertEqual = function(actual, expected, note)
		if actual != expected then
			print "Unit test failure (" + note + "): expected " + expected + ", got " + actual
			outer.errorCount = errorCount + 1
		end if
	end function

	dam = new Damage
	assertEqual dam.str, "No damage"
	
	dam.physical = 5
	assertEqual dam.str, "5"

	dam.cold = 3
	assertEqual dam.str, "5 + 3 Cold"
	
	dam.poison = -1  // (not sure why you would do this, but...)
	assertEqual dam.str, "5 + 3 Cold - 1 Poison"

	res = new Resistance
	assertEqual res.str, ""
	
	res.fire = 25
	assertEqual res.str, "25% Fire"
	
	res.physical = 100
	assertEqual res.str, "100% Physical, 25% Fire"
	
	res2 = (new Resistance) + {"fire":10, "cold":50}
	assertEqual res2.str, "10% Fire, 50% Cold"
	
	resSum = res.add(res2)
	assertEqual resSum.str, "100% Physical, 35% Fire, 50% Cold"
	
	d = resSum.apply(dam)
	assertEqual d.str, "2 Cold - 1 Poison"
	
	print "damType tests complete.  Failures: " + errorCount
end function

if locals == globals then runTests
