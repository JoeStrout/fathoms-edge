// This module manages visual effects: targeting reticle, projectiles,
// particle effects, etc.


privateData = {}
privateData.target = null

reticleSprite = new Sprite
reticleSprite.image = file.loadImage("/usr/pics/targetReticle.png")
reticleSprite.scale = 2
reticleSprite.tint = color.red
reticleSprite.visible = false

shotFrames = []
shotFramesImg = file.loadImage("/usr/pics/shotFrames.png")
for i in range(0,3)
	shotFrames.push shotFramesImg.getImage(0, i*5, 5, 5)
end for
ShotSprite = new Sprite
ShotSprite.image = shotFrames[0]
ShotSprite.scale = 2
ShotSprite.tint = color.yellow

// Put a targeting reticle on the given thing.  Keep it there
// as that thing moves (via update).  Pass null to remove the
// target entirely.
showTarget = function(targetThing)
	privateData.target = targetThing
	if targetThing and not reticleSprite.visible then
		disp.sprite.sprites.push reticleSprite
		reticleSprite.visible = true
	else if targetThing == null and reticleSprite.visible then
		disp.sprite.sprites.removeRef reticleSprite
		reticleSprite.visible = false
	end if
	if targetThing then
		disp.positionSprite reticleSprite, targetThing.x, targetThing.y
	end if
end function

doRangedAttack = function(attacker, defender)
	totalDx = defender.sprite.x - attacker.sprite.x
	totalDy = defender.sprite.y - attacker.sprite.y
	dist = sqrt(totalDx^2 + totalDy^2)
	
	// Prepare three sprites: a head and two tail particles.
	x = attacker.sprite.x + disp.cellSize/2 * sign(totalDx)
	y = attacker.sprite.y + disp.cellSize/2 * sign(totalDy)
	trail = []  // the head is the last of these
	for i in range(0,2)
		sp = new ShotSprite
		sp.x = x; sp.y = y
		trail.push sp
		disp.sprite.sprites.push sp
	end for
	trail[1].image = shotFrames[2]
	trail[2].image = shotFrames[3]
	
	// Now, animate towards the defender!
	for i in range(10)
		trail[0].x = trail[1].x; trail[0].y = trail[1].y
		trail[1].x = trail[2].x; trail[1].y = trail[2].y
		mathUtil.moveTowardsXY trail[2], defender.sprite, dist/8
		yield
	end for
	
	// Remove the particles from the display
	for i in range(0,2)
		disp.sprite.sprites.pop
	end for
end function

update = function
	t = privateData.target
	if t == null or (t.hasIndex("dead") and t.dead) then
		if reticleSprite.visible then showTarget null
	else
		reticleSprite.x = t.sprite.x
		reticleSprite.y = t.sprite.y
		// ToDo? Move target to end of sprite list, so it's always on top?
	end if
end function
