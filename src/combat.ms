// Herein lies the combat code, including combat animations, calculating
// and applying damage and effects, etc.



// Do a melee attack.  This is shown by animating the attacker towards
// the defender, applying the attack, and animating back.
doMeleeAttack = function(attacker, defender)
	// Find a vector pointing from the attacker to the defender,
	// of a length corresponding to our movement per frame.
	dx = defender.x - attacker.x; dy = defender.y - attacker.y
	dist = sqrt(dx^2 + dy^2)
	dx = 2 * dx / dist; dy = 2 * dy/ dist
	
	// Ensure proper Z-ordering of sprites based on Y position
	sprite = attacker.sprite
	defSprite = defender.sprite
	if defSprite then
		atkIdx = disp.sprite.sprites.indexOf(sprite)
		defIdx = disp.sprite.sprites.indexOf(defSprite)
		if dy < 0 and atkIdx > defIdx then
			disp.sprite.sprites.remove atkIdx
			disp.sprite.sprites.insert defIdx, sprite
		else if dy > 0 and atkIdx < defIdx then
			disp.sprite.sprites.remove atkIdx
			disp.sprite.sprites.insert defIdx, sprite
		end if			
	end if
	
	// Do the advance animation
	for i in range(8)
		sprite.x += dx; sprite.y += dy
		yield
	end for
	
	// Apply the attack effect
	applyAttackEffect attacker, defender

	// Do the retreat animation
	for i in range(8)
		sprite.x -= dx; sprite.y -= dy
		yield
	end for
end function


applyAttackEffect = function(attacker, defender)
	attacker.note "You attack " + defender.name + "."
	defender.note attacker.name + " attacks you!"
end function
