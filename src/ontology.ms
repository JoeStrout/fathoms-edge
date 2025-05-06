// This file defines the hierarchy of classes that represent all
// the "nouns" in the game — items, entities, obstacles, etc.  Pretty
// much anything that can appear in the world, is an instance of some
// class defined in this file.

import "importUtil"
ensureImport "listUtil"
ensureImport "stringUtil"
ensureImport "status"
ensureImport "damType"
ensureImport "combat"

// Thing: base class for anything that can appear in the world (or
// inside a container).  These will be drawn as sprites, if image is
// not null, or else in the main tile display, iconIdx is not null.
globals.Thing = {}
Thing.x = -1		// Coordinates always stored as MAP coordinates;
Thing.y = -1		// in a container, this may be position in container.
Thing.iconIdx = 180
Thing.image = null
Thing.color = "#AAAAAA"
Thing.container = null	// Container, if any (if null, item is on map)
Thing.capacity = 0		// total size of items this can contain
Thing.contents = null	// list of contents
Thing.name = "thing"
Thing.blocksMovement = false
Thing.destroyed = false
Thing._sprite = null	// cache; use .sprite method!

Thing.Make = function(name=null, iconIdxOrImage=null, capacity=0)
	noob = new self
	if name != null then noob.name = name
	if iconIdxOrImage isa number then
		noob.iconIdx = iconIdxOrImage
	else if iconIdxOrImage isa Image then
		noob.image = iconIdxOrImage
	end if
	if capacity > 0 then
		noob.capacity = capacity
		noob.contents = []
	end if
	return noob
end function

Thing.sprite = function
	if not self.image then return null
	if self._sprite == null then
		self._sprite = new Sprite
		self._sprite.scale = 2
	end if
	self._sprite.image = self.image
	self._sprite.tint = self.color
	return self._sprite
end function

Thing.placeOnMap = function(x, y)
	self.removeFromContainer
	self.removeFromMap
	self.x = x
	self.y = y
	level.addThing self, x, y
end function

Thing.removeFromMap = function
	level.removeThing self
	self.x = -1
	self.y = -1
end function

// Thing.removeFromContainer: remove this item from its container, if any.
Thing.removeFromContainer = function
	if self.container and self.container.contents then
		self.container.contents.removeVal self
	end if
	self.container = null
end function

// Thing.contain: add another item to this container.
Thing.contain = function(contentItem)
	contentItem.removeFromContainer
	contentItem.container = self
	if self.contents == null then self.contents = []
	self.contents.push contentItem
end function

// Thing.destroy: call this when you want to get rid of an item.
Thing.destroy = function
	self.removeFromContainer
	self.destroyed = true
end function

// Thing.nameWithArticle: return the name of this item, prefixed
// with an article -- typically "a" or "an", but could be "some"
// or whatever is appropriate for the kind of thing it is.  Note
// that if aOrThe is "the", then we want a definite (rather than
// indefinite) article.
Thing.nameWithArticle = function(aOrThe="a")
	// Default behavior:
	if aOrThe == "the" then return "the " + self.name
	if "aeiou".contains(self.name[0]) then return "an " + self.name
	return "a " + self.name
end function

Thing.drawIcon = function(gfx, x, y)
	if self.image then
		img = self.image
	else if self.iconIdx then
		img = oneBit.getTileImage(self.iconIdx)
	else
		return
	end if
	gfx.drawImage img, x, y, -1, -1, 0, 0, -1, -1, self.color
end function


// Obstacle: things that go on the map, generally don't move around,
// and block movement by the player and mobs.
globals.Obstacle = new Thing
Obstacle.iconIdx = 210
Obstacle.blocksMovement = true


// Item: inanimate objects that agents can (usually) pick up.
globals.Item = new Thing
Item.size = 1
Item.value = 1		// base value to buy/sell
Item.usable = false
Item.useBy = function(agent); end function
Item.usedVerb = "used"

// Food: items you can eat.
globals.Food = new Item
Food.usable = true
Food.usedVerb = "ate"
Food.healthGain = 5
Food.useBy = function(agent)
	if agent isa CombatAgent then agent.health += self.healthGain
end function

// Agent: things with agency, i.e., they get updates and can take actions.
// This includes things like magic fountains that change their state over
// time, etc.
globals.Agent = new Thing
Agent.iconIdx = 248
Agent.color = "#FFFFFF"
Agent.update = null
Agent.blocksMovement = true

// Agent.note: this is called with short messages describing things
// this agent does, or that happen to this agent.  If it's the Player,
// these are probably printed or logged somewhere.  If it's any other
// agent, these probably go nowhere (but you can always hook in some
// logging method if you really want to).
Agent.note = function(msg)
end function

// Agent.attemptMove: try to move in the given direction, doing whatever
// we do by default (picking up loose items, etc.).  Return true on 
// success, false if we weren't able to move.
Agent.attemptMove = function(dx, dy)
	if self.container then return false	// can't move while in container
	if not level.passable(self.x + dx, self.y + dy) then
		// Bonk!
		self.note "You can't move that way."
		return false
	end if
	stuff = level.getItems(self.x + dx, self.y + dy)
	for item in stuff
		self.pickUp item
	end for
	level.moveThing self, self.x + dx, self.y + dy
	self.x += dx
	self.y += dy
	return true
end function

// Agent.pickUp: pick up an item currently in the level, and place it
// into our inventory.
Agent.pickUp = function(item)
	item.removeFromMap
	self.contain item
	itemName = item.nameWithArticle
	self.note "Picked up {itemName}.".fill(locals)
end function

// Handle a command -- typically this is called on the Player, and the
// command comes from some keyboard input.  But NPC code can use this too,
// if that's an easier way to control your character.  Return 1 if this
// command takes time (i.e. should give all other agents a turn); 0 if there
// was no valid command, or it took no time.
Agent.handleCommand = function(cmd)
	dx = 0; dy = 0
	if cmd == "WAIT" then
		self.note "Time passes."
		return 1
	end if
	if cmd == "NORTH" then dy = 1
	if cmd == "SOUTH" then dy = -1
	if cmd == "EAST" then dx = 1
	if cmd == "WEST" then dx = -1
	if dx or dy then
		self.attemptMove dx, dy
		return 1
	end if
	return 0
end function

// CombatAgent: an agent with all the support code for combat.  This is
// where most of the complexity of the game lives.  CombatAgent may be 
// used directly for simple mobs, or you may use NPC for mobs that act
// more like the player (able to speak, use weapons, etc.)
globals.CombatAgent = new Agent
CombatAgent.health = 100
CombatAgent.statuses = null	  // StatusHolder object
CombatAgent.damage = null     // Damage object (for current attack)
CombatAgent.resistance = null // Resistance object
CombatAgent.dodge = 1         // % chance of dodging
CombatAgent.leavesCorpse = false

CombatAgent.Make = function(name=null, iconIdxOrImage=null, capacity=100)
	noob = super.Make(name, iconIdxOrImage, capacity)
	noob.statuses = StatusHolder.Make
	noob.damage = new Damage
	noob.damage.physical = 1   // just to have something by default
	noob.resistance = new Resistance
	return noob
end function

CombatAgent.dead = function; return self.health <= 0; end function

CombatAgent.update = function
	self.statuses.update
end function

CombatAgent.corpseName = function; return self.name + " corpse"; end function

CombatAgent.takeDamage = function(damage)
	if damage isa Damage then
		self.health -= damage.sum
	else
		self.health -= damage
	end if
	if self.health <= 0 then self.die
end function

CombatAgent.die = function
	self.dead = true
	level.removeThing self
	if self.leavesCorpse then
		level.addThing self.makeCorpse, self.x, self.y
	else if self.contents then
		loot = self.contents
		self.contents = null
		for item in loot
			level.addThing item
		end for
	end if
end function	

CombatAgent.makeCorpse = function
	corpse = new Item
	corpse.name = self.corpseName
	corpse.iconIdx = 786
	corpse.color = color.gray
	if self.contents then
		corpse.contents = self.contents
		for item in self.contents
			item.container = corpse
		end for
	end if
	return corpse
end function

// Mob: a CombatAgent that is, basically, a monster.  These may or may not
// attack the player on sight, but it's always a possibility.
globals.Mob = new CombatAgent
Mob.HOSTILE = "HOSTILE"   // Mob is chasing/attacking player/allies
Mob.NEUTRAL = "NEUTRAL"   // Mob is ignoring the player
Mob.FLEEING = "FLEEING"   // Mob is fleeing (use sparingly — can be annoying!0
Mob.FRIENDLY = "FRIENDLY" // Mob is friendly to the player
Mob.disposition = Mob.NEUTRAL
Mob.sightRadius = 10

Mob.Make = function(name=null, iconIdxOrImage=null, capacity=100)
	noob = super.Make(name, iconIdxOrImage, capacity)
	// To support combat animations, mobs always need a sprite.
	if noob.image == null and noob.iconIdx > 0 then
		noob.image = oneBit.getTileImage(noob.iconIdx)
	end if
	return noob
end function

Mob.availableSteps = function
	// Return a list of [dx, dy, distToPlayer] steps we can take from here,
	// sorted in order of most-towards the player first.
	result = []
	for dx in [-1, 0, 1]
		for dy in [-1, 0, 1]
			if not dx and not dy then continue
			x = self.x + dx
			y = self.y + dy
			if level.passable(x, y, self) then
				d = mathUtil.distance([x,y], player)
				result.push [dx, dy, d]
			end if
		end for
	end for
	result.sort 2  // sort by element 2, the distance to the player
	return result
end function

Mob.update = function
	super.update
	playerDist = mathUtil.distance(player, self)
	if playerDist > self.sightRadius or self.disposition == Mob.NEUTRAL then
		// player's too far away... do normal behavior
		// (which may be nothing)
		return
	end if
	avail = self.availableSteps
	if not avail then return
	if self.disposition == Mob.HOSTILE then
		if playerDist < 2 then
			combat.doMeleeAttack self, player
		else
			self.attemptMove avail[0][0], avail[0][1]
		end if
	else if self.disposition == Mob.FLEEING then
		self.attemptMove avail[-1][0], avail[-1][1]	
	end if
	
end function

// Character: common code for the player and NPCs.  Characters have more
// complex behavior than generic CombatAgents.
globals.Character = new CombatAgent

// Class representing the player.
globals.Player = new Character
Player.name = "Player"
Player.iconIdx = null
Player.image = oneBit.getTileImage(25)

Player.note = function(msg)
	ui.addLogMessage msg
end function

Player.handleCommand = function(cmd)
	if cmd == "INVENTORY" then
		ui.showInventory self
		return 0
	end if
	dx = 0; dy = 0
	if cmd == "NORTH" then dy = 1
	if cmd == "SOUTH" then dy = -1
	if cmd == "EAST" then dx = 1
	if cmd == "WEST" then dx = -1
	if dx or dy then
		// check for mob to melee attack in this direction
		mob = level.getMob(self.x + dx, self.y + dy)
		if mob then
			combat.doMeleeAttack self, mob
			return 1
		end if
	end if
	return super.handleCommand(cmd)
end function

// Characters other than the player (but able to do most of the things the
// player could do).
globals.NPC = new Character
