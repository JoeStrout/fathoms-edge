// This file defines the hierarchy of classes that represent all
// the "nouns" in the game — items, entities, obstacles, etc.  Pretty
// much anything that can appear in the world, is an instance of some
// class defined in this file.

import "importUtil"
ensureImport "listUtil"

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

// Item: inanimate objects that agents can (usually) pick up.
globals.Item = new Thing
Item.size = 1		// 1 size (mass/volume) unit ~= 1 apple
Item.value = 1		// base value to buy/sell

// Agent: things with agency, i.e., they get updates and can take actions.
// This includes things like magic fountains that change their state over
// time, etc.
globals.Agent = new Thing
Agent.iconIdx = 248
Agent.color = "#FFFFFF"
Agent.update = null

Agent.attemptMove = function(dx, dy)
	if self.container then return false	// can't move while in container
	level.moveThing self, self.x + dx, self.y + dy
	self.x += dx
	self.y += dy
end function	

// Handle a command -- typically this is called on the Player, and the
// command comes from some keyboard input.  But NPC code can use this too,
// if that's an easier way to control your character.  Return 1 if this
// command takes time (i.e. should give all other agents a turn); 0 if there
// was no valid command, or it took no time.
Agent.handleCommand = function(cmd)
	dx = 0; dy = 0
	if cmd == "WAIT" then return 1
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

	

// Characters other than the player (but able to do most of the things the
// player could do).
globals.NPC = new Character
