// This file defines the hierarchy of classes that represent all
// the "nouns" in the game — items, entities, obstacles, etc.  Pretty
// much anything that can appear in the world, is an instance of some
// class defined in this file.

import "importUtil"
ensureImport "listUtil"
ensureImport "stringUtil"
ensureImport "status"

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
Thing.destroyed = false
Thing._sprite = null	// cache; use .sprite method!

Thing.Make = function(name=null, capacity=0)
	noob = new self
	if name != null then noob.name = name
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
CombatAgent.statuses = null	// StatusHolder object

CombatAgent.Make = function(name=null, capacity=100)
	noob = super.Make(name, capacity)
	noob.statuses = StatusHolder.Make
	return noob
end function

CombatAgent.update = function
	self.statuses.update
end function

CombatAgent.corpseName = function; return self.name + " corpse"; end function

CombatAgent.makeCorpse = function
	corpse = new Item
	corpse.name = self.corpseName
	if self.contents then
		corpse.contents = self.contents
		for item in self.contents
			item.container = corpse
		end for
	end if
	return corpse
end function
	

// Character: common code for the player and NPCs.  Characters have more
// complex behavior than generic CombatAgents.
globals.Character = new CombatAgent

// Class representing the player.
globals.Player = new Character
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
	return super.handleCommand(cmd)
end function

// Characters other than the player (but able to do most of the things the
// player could do).
globals.NPC = new Character
