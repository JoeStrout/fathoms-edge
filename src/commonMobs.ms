// This file defines common mobs that may be found in town or on adventures.

globals.Rat = new Mob
Rat.Make = function
	rat = super.Make("rat", 287)
	rat.color = color.brown
	rat.disposition = Mob.HOSTILE
	rat.health = 5
	rat.leavesCorpse = true
	rat.attacksPerTurn = 2
	rat.damage.physical = 1
	return rat
end function

globals.Slime = new Mob
Slime.Make = function
	slime = super.Make("slime", 283)
	slime.color = color.lime
	slime.disposition = Mob.HOSTILE
	slime.health = 10
	slime.attacksPerTurn = 0.5
	slime.damage.physical = 3
	return slime
end function

