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
	dam = applyAttackEffect(attacker, defender)
	defColor = defender.sprite.tint
	defender.sprite.tint = color.lerp(defColor, color.red, 0.5)

	// Do the retreat animation
	for i in range(8)
		sprite.x -= dx; sprite.y -= dy
		yield
	end for
	defender.sprite.tint = defColor
end function

// Do a ranged attack.
doRangedAttack = function(attacker, defender)
	// Find a vector pointing from the attacker to the defender,
	// of length 1.
	dx = defender.x - attacker.x; dy = defender.y - attacker.y
	dist = sqrt(dx^2 + dy^2)
	dx = dx / dist; dy = dy / dist

	// Start with the visual effect of the projectile itself
	visualFX.doRangedAttack attacker, defender
	
	// Apply the attack effect
	dam = applyAttackEffect(attacker, defender)
	defColor = defender.sprite.tint
	defender.sprite.tint = color.lerp(defColor, color.red, 0.5)

	// Do a little knockback animation
	defender.sprite.x += dx * 5; defender.sprite.y += dy * 5
	for i in range(4)
		defender.sprite.x -= dx; defender.sprite.y -= dy
		yield
	end for
	defender.sprite.tint = defColor
end function

applyAttackEffect = function(attacker, defender)
	atkName = attacker.nameWithArticle
	defName = defender.nameWithArticle("the")
	
	// First, check for dodging
	dodgePct = defender.dodge * defender.statuses.dodgeModifier +
	  attacker.attackDodgeMod
	if chance(dodgePct) then
		attacker.note "{defName} dodges your attack!".fill(locals).capitalized
		defender.note "You dodge {atkName}'s attack.".fill(locals)
		return
	end if

	// Then, apply damage.
	dam = defender.resistance.apply(attacker.damage)
	if not dam.any then
		attacker.note "You attack {defName}, but do no damage!".fill(locals)
		defender.note "{atkName} attacks you, but does no damage.".
		  fill(locals).capitalized
	else
		defender.takeDamage dam
		if defender.dead then
			attacker.note "You slay {defName}.".fill(locals)
			defender.note "You have been slain by {atkName}!".fill(locals)
			if defender == currentTarget then deselectTarget
		else
			damStr = dam.str
			attacker.note "You attack {defName} for {damStr}.".fill(locals)
			defender.note "{atkName} attacks you for {damStr}!".
			  fill(locals).capitalized
		end if
	end if
	return dam
end function

_targets = []
_curTargetIdx = -1
_curTargetRange = -1

selectNextTarget = function(range)
	outer._curTargetIdx += 1
	if not _targets or _curTargetIdx >= _targets.len or range != _curTargetRange then
		// Rebuild the target list, from closest to farthest.
		outer._targets = []
		for agent in level.agents
			if not agent isa Mob or agent.disposition == Mob.FRIENDLY then continue
			if refEquals(agent, player) then continue
			agent.distToPlayer = mathUtil.distance(agent, player)
			if agent.distToPlayer <= range then _targets.push agent
		end for
		_targets.sort "distToPlayer"
		outer._curTargetIdx = 0
		outer._curTargetRange = range
	end if
	if _curTargetIdx > _targets.len then
		visualFX.showTarget null
		return		
	end if
	// ToDo: ensure this target is visible, else skip it.
	visualFX.showTarget currentTarget
end function

currentTarget = function
	if 0 <= _curTargetIdx < _targets.len then return _targets[_curTargetIdx]
	return null
end function

deselectTarget = function
	outer._curTargetIdx = _targets.len
	visualFX.showTarget null
end function