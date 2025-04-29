// This file defines the hierarchy of classes that represent all
// the "nouns" in the game — items, entities, obstacles, etc.  Pretty
// much anything that can appear in the world, is an instance of some
// class defined in this file.

import "importUtil"
ensureImport "listUtil"

// Thing: base class for anything that can appear in the world (or
// inside a container).
Thing = {}
Thing.x = 0		// Coordinates always stored as MAP coordinates;
Thing.y = 0		// in a container, this may be position in container.
Thing.iconIdx = 180
Thing.color = "#AAAAAA"
Thing.container = null	// Container, if any (if null, item is on map)
Thing.capacity = 0		// total size of items this can contain
Thing.contents = null	// list of contents
Thing.name = "thing"
Thing.destroyed = false

// Thing.removeFromContainer: remove this item from its container, if any.
Thing.removeFromContainer = function
	if self.container and self.container.contents then
		self.container.contents.removeVal self
	end if
	self.container = null
end function

// Thing.destroy: call this when you want to get rid of an item.
Thing.destroy = function
	self.removeFromContainer
	self.destroyed = true
end function

// Thing.contain: add another item to this container.
Thing.contain = function(contentItem)
	contentItem.removeFromContainer
	contentItem.container = self
	if self.contents == null then self.contents = []
	self.contents.push contentItem
end function

// Item: inanimate objects that agents can (usually) pick up.
Item = new Thing
Item.size = 1		// 1 size (mass/volume) unit ~= 1 apple
Item.value = 1		// base value to buy/sell

// Agent: things with agency, i.e., they get updates and can take actions.
// This includes things like magic fountains that change their state over
// time, etc.
Agent = new Thing
Agent.iconIdx = 248
Agent.color = "#FFFFFF"
Agent.update = null

// CombatAgent: an agent with all the support code for combat.  This is
// where most of the complexity of the game lives.  CombatAgent may be 
// used directly for simple mobs, or you may use NPC for mobs that act
// more like the player (able to speak, use weapons, etc.)
CombatAgent = new Agent
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
Character = new CombatAgent

// Class representing the player.
Player = new Character
Player.iconIdx = 25

// Characters other than the player (but able to do most of the things the
// player could do).
NPC = new Character
