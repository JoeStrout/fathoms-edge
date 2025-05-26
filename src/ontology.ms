// This file defines the hierarchy of classes that represent all
// the "nouns" in the game — items, entities, obstacles, etc.  Pretty
// much anything that can appear in the world, is an instance of some
// class defined in this file.

import "importUtil"
ensureImport "listUtil"
ensureImport "stringUtil"
ensureImport "status"
ensureImport "damType"
ensureImport "loadout"
ensureImport "combat"
ensureImport "inventory"

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
Thing.contents = null	// Inventory of contents
Thing.name = "thing"
Thing.blocksMovement = false
Thing.destroyed = false
Thing._sprite = null	// cache; use .sprite method!
Thing.ByID = {}    // key: id number; value: Thing
Thing._LastId = 0

Thing.UnusedId = function
	Thing._LastId += 1
	return Thing._LastId
end function

Thing.Make = function(name=null, iconIdxOrImage=null, capacity=0)
	noob = new self
	noob.id = Thing.UnusedId
	Thing.ByID[noob.id] = noob
	if name != null then noob.name = name
	if iconIdxOrImage isa number then
		noob.iconIdx = iconIdxOrImage
	else if iconIdxOrImage isa Image then
		noob.image = iconIdxOrImage
	end if
	if capacity > 0 then
		noob.contents = Inventory.Make
		noob.contents.capacity = capacity
	end if
	return noob
end function

Thing.pluralName = function
	s = self.name.plural
	self.pluralName = s  // (calculate once, cache the result)
	return s
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
//	if self isa Item then print "placing " + self.nameWithQty + " at " + x + "," + y
	self.removeFromContainer
	self.removeFromMap
	self.x = x
	self.y = y
	zone.addThing self, x, y
end function

Thing.removeFromMap = function
	zone.removeThing self
	self.x = -1
	self.y = -1
end function

// Thing.removeFromContainer: remove this item from its container, if any.
Thing.removeFromContainer = function
	if self.container and self.container.contents then
		self.container.contents.removeItem self, -1
	end if
	self.container = null
end function

// Thing.contain: add another item to this container.
Thing.contain = function(contentItem)
	contentItem.removeFromContainer
	contentItem.container = self
	if self.contents == null then self.contents = Inventory.Make	// or fail?
	self.contents.add contentItem, -1
end function

// Thing.destroy: call this when you want to get rid of an item.
Thing.destroy = function
	self.removeFromContainer
	self.destroyed = true
	Thing.ByID.remove self.id
end function

// Thing.nameWithArticle: return the name of this item, prefixed
// with an article -- typically "a" or "an", but could be "some"
// or whatever is appropriate for the kind of thing it is.  Note
// that if aOrThe is "the", then we want a definite (rather than
// indefinite) article.
Thing.nameWithArticle = function(aOrThe="a", forceSingular=false)
	// Default behavior:
	if not forceSingular and self isa Item and self.qty > 1 then
		if aOrThe == "the" then return "the " + self.nameWithQty
		return self.nameWithQty
	end if
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


// Item: inanimate objects that agents can (usually) pick up, or
// a stack of identical items.
globals.Item = new Thing
Item.size = 1       // size *per item*
Item.value = 1		// base value (per item) to buy/sell
Item.usable = false
Item.useBy = function(agent); end function
Item.usedVerb = "used"
Item.qty = 1        // how many are in this stack; or null if not stackable

Item.noteQtyChanged = null  // (function called when quantity changes)

Item.stackable = function; return self.qty != null; end function

Item.canStackWith = function(other)
	if not refEquals(self.__isa, other.__isa) then return false
	if not self.stackable or not other.stackable then return false
	for kv in self
		if ["qty", "id", "pluralName", "_sprite", "x", "y"].
		  indexOf(kv.key) != null then continue
		if not other.hasIndex(kv.key) then return false
		if @other[kv.key] != @kv.value then return false
	end for
	return true
end function

Item.nameWithQty = function
	if self.qty > 1 then return self.qty + " " + self.pluralName
	return self.name
end function
		
Item.totalSize = function
	if self.qty == null then return self.size
	return self.size * self.qty
end function

Item.totalValue = function
	if self.qty == null then return self.value
	return self.value * self.qty
end function
		
Item.destroyOne = function
	if self.qty == null or self.qty <= 1 then return self.destroy
	self.qty -= 1
end function

// Food: items you can eat.
globals.Food = new Item
Food.usable = true
Food.usedVerb = "ate"
Food.healthGain = 5
Food.useBy = function(agent)
	if agent isa CombatAgent then agent.health += self.healthGain
	self.destroyOne
end function


// Equipment: items you can equip (i.e. put in an equipment slot).
globals.Equipment = new Item
Equipment.usable = true
Equipment.usedVerb = "equipped"
Equipment.slot = loadout.MAINHAND
Equipment.cursed = false
Equipment.qty = null
Equipment.stackable = false

Equipment.Make = function(name=null, iconIdxOrImage=null, slot=null)
	noob = super.Make(name, iconIdxOrImage)
	if slot then noob.slot = slot
	noob.resistance = new Resistance
	noob.damage = new Damage
	return noob
end function

Equipment.useBy = function(agent)
	if not agent isa CombatAgent then return
	agent.loadout.equip self
end function

// Weapon: an Equipment item you can attack with.
globals.Weapon = new Equipment
Weapon.attackDodgeMod = 0  // e.g., -10 reduces defender dodge by 10%
Weapon.attackRange = 1	// 1 for melee, > 1 for ranged weapons


// Agent: things with agency, i.e., they get updates and can take actions.
// This includes things like magic fountains that change their state over
// time, etc.
globals.Agent = new Thing
Agent.iconIdx = 248
Agent.color = "#FFFFFF"
Agent.update = null
Agent.blocksMovement = true
Agent.qty = null
Agent.stackable = false

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
	if not zone.passable(self.x + dx, self.y + dy) then
		// Bonk!
		self.note "You can't move that way."
		return false
	end if
	stuff = zone.getItems(self.x + dx, self.y + dy)
	for item in stuff
		self.pickUp item
	end for
	zone.moveThing self, self.x + dx, self.y + dy
	self.x += dx
	self.y += dy
	return true
end function

// Agent.pickUp: pick up an item currently in the zone, and place it
// into our inventory.
Agent.pickUp = function(item)
	if item.qty > 1 then what = item.nameWithQty else what = item.nameWithArticle
	item.removeFromMap
	self.contain item
	self.note "Picked up {what}.".fill(locals)
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
CombatAgent.statuses = null	   // StatusHolder object
CombatAgent.damage = null      // Damage object (for current attack)
CombatAgent.resistance = null  // Resistance object
CombatAgent.loadout = null     // Loadout object
CombatAgent.dodge = 1          // % chance of dodging
CombatAgent.attackDodgeMod = 0 // modifier to defender's dodge when attacking
CombatAgent.attackRange = 1    // 1 for melee, >1 for ranged
CombatAgent.attacksPerTurn = 1 // how many attacks we get per turn
CombatAgent.leavesCorpse = false

CombatAgent.Make = function(name=null, iconIdxOrImage=null, capacity=100)
	noob = super.Make(name, iconIdxOrImage, capacity)
	noob.statuses = StatusHolder.Make
	noob.damage = Damage.Default
	noob.resistance = new Resistance
	noob.loadout = new Loadout
	qa.assert noob.image, "CombatAgents must always have a sprite image"
	return noob
end function

CombatAgent.dead = function; return self.health <= 0; end function

CombatAgent.update = function
	// update status effects
	e = zone.element(self.x, self.y)
	if e.waterDepth == 1 then
		self.statuses.apply status.WADING, 1
	else if e.waterDepth > 1 then
		self.statuses.apply status.SWIMMING, 1
	end if
	self.statuses.update
	
	// update resistance and attack info
	parentClass = self.__isa
	self.attacksPerTurn = parentClass.attacksPerTurn
	self.resistance = parentClass.resistance
	if self.resistance == null then self.resistance = new Resistance
	self.attackDodgeMod = parentClass.attacksPerTurn
	self.attackRange = parentClass.attackRange
	damage = null  // (weapon damage)
	
	for item in self.loadout.items
		self.resistance = self.resistance.add(item.resistance)
		if damage then damage = damage.add(item.damage) else damage = item.damage
		if item isa Weapon then
			self.attackDodgeMod += item.attackDodgeMod
			self.attackRange = max(self.attackRange, item.attackRange)
		end if
	end for
	// Damage: use that of the equipment, else the default empty-hand
	// damage inherited from the parent class.
	if damage and damage.any then
		self.damage = damage
	else
		self.damage = parentClass.damage
		if not self.damage then self.damage = Damage.Default
	end if
	
	if self.statuses.hasStatus(status.STUNNED) then
		self.attacksPerTurn = 0
	else
		if self.statuses.hasStatus(status.HASTENED) then self.attacksPerTurn += 1
		if self.statuses.hasStatus(status.SLOWED) then self.attacksPerTurn /= 2
	end if

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
	zone.removeThing self
	if self.leavesCorpse then
		zone.addThing self.makeCorpse, self.x, self.y
	else if self.contents then
		loot = self.contents.items
		self.contents = null
		for item in loot
			zone.addThing item, self.x, self.y
		end for
	end if
end function	

CombatAgent.makeCorpse = function
	corpse = new Item
	corpse.name = self.corpseName
	corpse.iconIdx = 480
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
	if iconIdxOrImage isa number and iconIdxOrImage > 0 then
		// To support combat animations, mobs always need a sprite.
		iconIdxOrImage = oneBit.getTileImage(iconIdxOrImage)
	end if
	noob = super.Make(name, iconIdxOrImage, capacity)
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
			if zone.passable(x, y, self) then
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
			// attack!
			if self.attacksPerTurn < 1 then
				if turn % (1 / self.attacksPerTurn) == 0 then
					combat.doMeleeAttack self, player
				end if
			else
				for i in range(1, self.attacksPerTurn)
					combat.doMeleeAttack self, player
				end for
			end if
		else
			// ToDo: implement movesPerTurn!
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
Player.damage = new Damage
Player.damage.physical = 1  // set player empty-hand damage here

Player.Make = function
	noob = super.Make("Player", oneBit.getTileImage(25))
	return noob
end function

Player.note = function(msg)
	ui.addLogMessage msg
end function

Player.handleCommand = function(cmd)
	if cmd == "INVENTORY" then
		ui.showInventory self
		return 0
	else if cmd == "TARGET" then
		combat.selectNextTarget player.attackRange + 0.9
		return 0
	else if cmd == "ATTACK" then
		target = combat.currentTarget
		if target == null then
			combat.selectNextTarget player.attackRange + 0.9
			target = combat.currentTarget
			if target == null then return 0
		end if
		if player.attackRange > 1 then
			combat.doRangedAttack player, target
		else
			combat.doMeleeAttack player, target
		end if
		return 1
	end if
	dx = 0; dy = 0
	if cmd == "NORTH" then dy = 1
	if cmd == "SOUTH" then dy = -1
	if cmd == "EAST" then dx = 1
	if cmd == "WEST" then dx = -1
	if dx or dy then
		// check for mob to melee attack in this direction
		mob = zone.getMob(self.x + dx, self.y + dy)
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
