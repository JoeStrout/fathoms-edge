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
	qa.assert sprite != null
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
	atkName = attacker.nameWithArticle
	defName = defender.nameWithArticle("the")
	
	// First, check for dodging
	if chance(defender.dodge * defender.statuses.dodgeModifier) then
		attacker.note "{defName} dodges your attack!".fill(locals).capitalized
		defender.note "You dodge {atkName}'s attack.".fill(locals)
		return
	end if

	// Then, apply damage.
	dam = defender.resistance.apply(attacker.damage)
	if not dam.any then
		attacker.nonte "You attack {defName}, but do no damage!".fill(locals)
		defender.note "{atkName} attacks you, but does no damage.".
		  fill(locals).capitalized
	else
		defender.takeDamage dam
		if defender.dead then
			attacker.note "You slay {defName}.".fill(locals)
			defender.note "You have been slain by {atkName}!".fill(locals)
		else
			damStr = dam.str
			attacker.note "You attack {defName} for {damStr}.".fill(locals)
			defender.note "{atkName} attacks you for {damStr}!".
			  fill(locals).capitalized
		end if
	end if
end function
