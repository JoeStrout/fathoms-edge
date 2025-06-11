// This module represents the currently loaded zone map.

// Note that there is always just one, 2-dimensional map loaded at
// a time.  If the game world has multiple levels, those will be
// managed separately, with just one at a time in play.

import "importUtil"
ensureImport "disp"
ensureImport "listUtil"
ensureImport "qa"
ensureImport "mapElement"

cellSize = disp.main.cellSize - disp.main.overlap

OOBElement = new MapElement
OOBElement.name = "Out of Bounds"
OOBElement.blocksWalk = true
OOBElement.blocksFly = true


globals.Zone = {}
Zone.width = 40
Zone.height = 25
Zone.things = null		// 2D array containing list of things for each [x][y] cell
Zone.mapElems = null	// 2D array of MapElement instance (static content), [x][y]
Zone.agents = null		// flat list of agents in the zone
Zone.elemPalette = null	// palette of MapElements we draw from
Zone.active = false		// true when this zone is current and shown on screen

Zone.Make = function(palette, width, height, defaultElemIndex=null)
	zone = new Zone
	if palette == null then palette = [null] * 255
	zone.elemPalette = palette
	zone.agents = []
	
	zone.width = width
	zone.height = height
	zone.things = list.init2d(width, height, null)
	defaultElem = null
	if defaultElemIndex != null then defaultElem = zone.elemPalette[defaultElemIndex]
	zone.mapElems = list.init2d(width, height, defaultElem)
	if defaultElem then
		for y in range(height-1)
			for x in range(0, width-1)
				defaultElem.apply zone, x, y
			end for
		end for
	end if
	return zone
end function

Zone.activate = function
	for d in [disp.bgColor, disp.background, disp.main, disp.overlay]
		d.extent = [self.width, self.height]
		d.clear
	end for
	disp.bgColor.clear 0
	disp.bgColor.setCellTint range(0, self.width), range(0, self.height), color.black
	disp.sprite.clear
	for y in range(self.height-1)
		for x in range(0, self.width-1)
			elem = self.element(x, y)
			if elem != null then elem.apply x, y
			stuff = self.things[x][y]
			if not stuff then continue
			for i in stuff.indexes
				thing = stuff[i]
				if thing.image then
					disp.sprite.sprites.push thing.sprite
					disp.positionSprite thing.sprite, x, y
				end if
				thing.decorate
			end for
			self.updateMainCell x, y
		end for
	end for
	outer.current = self
	self.active = true
end function

Zone.inBounds = function(x,y)
	return 0 <= x < self.width and 0 <= y < self.height
end function

Zone.element = function(x,y)
	if 0 <= x < self.width and 0 <= y < self.height then return self.mapElems[x][y]
	return OOBElement
end function

Zone.setElement = function(x, y, elementRefOrIndex)
	if not self.inBounds(x, y) then return
	if elementRefOrIndex isa number then
		self.mapElems[x][y] = self.elemPalette[elementRefOrIndex]
	else
		self.mapElems[x][y] = elementRefOrIndex
	end if
end function

// saveElemMap: write out our 2D array of MapElements, defining the
// static contents of this zone, to the given file.
Zone.saveElemMap = function(path)
	rd = new RawData
	rd.resize 4 + self.width * self.height
	rd.setUshort 0, self.width
	rd.setUshort 2, self.height
	i = 4
	for y in range(self.height-1)  // NOTE: top-down
		for x in range(0, self.width-1)
			if self.mapElems[x][y] == null then idx = 0 else idx = self.mapElems[x][y].id
			rd.setByte i, idx
			i += 1
		end for
	end for
	file.saveRaw path, rd
end function

// LoadMapElems: read a 2D array of MapElements, defining the
// static contents of this new zone, from the given file.
Zone.LoadMapElems = function(elemPalette, path)
	globals.rd = file.loadRaw(path)
	width = rd.ushort(0)
	height = rd.ushort(2)
	zone = Zone.Make(elemPalette, width, height)
	globals.wtf = zone
	i = 4
	for y in range(height-1)  // NOTE: top-down
		for x in range(0, width-1)
			elem = elemPalette[rd.byte(i)]
			zone.mapElems[x][y] = elem
			i += 1
		end for
	end for
	return zone
end function

Zone.addThing = function(thing, x, y)
	qa.assert thing isa Thing and x isa number and y isa number
	if 0 <= x < self.width and 0 <= y < self.height then
		if self.things[x][y] == null then self.things[x][y] = []
		if thing isa Item and thing.qty != null then
//			print "adding " + thing.nameWithQty + " to zone at " + x + "," + y
			for item in self.things[x][y]
				if item isa Item and thing.canStackWith(item) then
					// just add to the existing item stack!
					item.qty += 1
					item.noteQtyChanged
					return
				end if
			end for
		end if
		self.things[x][y].push thing
		thing.x = x
		thing.y = y
		if self.active then
			if thing.image then
				disp.sprite.sprites.push thing.sprite
				disp.positionSprite thing.sprite, x, y
			else
				self.updateMainCell x, y
			end if
			thing.decorate
		end if
	end if
	if thing isa Agent and not self.agents.contains(thing) then self.agents.push thing
end function

Zone.removeThing = function(thing)
	if 0 <= thing.x < self.width and 0 <= thing.y < self.height and self.things[thing.x][thing.y] then
//		print "removing " + thing.nameWithQty + " from zone at " + thing.x + "," + thing.y
		self.things[thing.x][thing.y].removeRef thing
		if thing.image then
			disp.sprite.sprites.removeVal thing.sprite
		else
			self.updateMainCell thing.x, thing.y
		end if
		thing.removeDecorations
	end if
	if thing isa Agent then self.agents.removeRef thing
end function

Zone.getItems = function(x, y)
	result = []
	if self.things[x][y] != null then
		for thing in self.things[x][y]
			if thing isa Item then result.push thing
		end for
	end if
	return result
end function

Zone.getMob = function(x, y)
	if self.inBounds(x, y) and self.things[x][y] != null then
		for thing in self.things[x][y]
			if thing isa Mob then return thing
		end for
	end if
	return null
end function

Zone.updateMainCell = function(x,y)
	stuff = self.things[x][y]
	if not stuff then
		disp.main.setCell x, y, null	 // ToDo: or from mapElement?
	else
		for i in range(stuff.indexes.len-1, 0, -1)
			thing = stuff[i]
			if not thing.image and thing.iconIdx then
				disp.main.setCell x, y, thing.iconIdx
				disp.main.setCellTint x, y, thing.color
				break
			end if
		end for
	end if
end function

Zone.moveThing = function(thing, newX, newY)
	if self.inBounds(thing.x, thing.y) and self.things[thing.x][thing.y] then
		self.things[thing.x][thing.y].removeRef thing
	end if
	if self.inBounds(newX, newY) then
		if self.things[newX][newY] == null then self.things[newX][newY] = []
		self.things[newX][newY].push thing
	end if
	
	if thing.image then
		// Easy case: just move the sprite!
		thing.sprite.x = cellSize * newX + cellSize/2
		thing.sprite.y = cellSize * newY + cellSize/2
	else if thing.iconIdx then
		// Almost-as-easy case: update the tile display
		self.updateMainCell thing.x, thing.y
		self.updateMainCell newX, newY
	end if
	thing.decorate
end function

// Return whether the given x,y position can be passed by the given agent.
Zone.passable = function(x, y, byAgent)
	if x < 0 or x >= self.width or y < 0 or y >= self.height then return false
	elem = self.mapElems[x][y]
	if elem.blockWalk then return false // ToDo: handle flying
	if self.things[x][y] == null then return true
	for thing in self.things[x][y]
		if thing.blocksMovement then return false
	end for
	return true
end function

// Deal with an agent attempting to interact with a location (usually,
// by bumping into it as if trying to move).
Zone.interact = function(x, y, byAgent)
	if not self.inBounds(x, y) then
		byAgent.note "You can't move that way."
	else if self.things[x][y] then
		for thing in self.things[x][y]
			thing.interact byAgent
		end for
	else
		elem = self.mapElems[x][y]
		elem.bump byAgent, x, y
	end if
end function

Zone.connectPortal = function(x, y, targetZone, targetX, targetY, msg)
	// First, confirm that the map actually has a portal at that location
	elem = self.element(x, y)
	tileName = elem.name
	if tileName != "caveEntrance" then
		print "OOPS!  Expected some portal at " + x + "," + y +
		  ", but found " + tileName + " (#" + elem.id + ") instead."
		exit
	end if
	// Then, add the portal to the map.
	portal = Portal.Make(targetZone, targetX, targetY, 0)
	if msg != null then portal.useMsg = msg
	self.addThing portal, x, y
end function

// Current (loading or active) zone:
current = new Zone

// Cache of loaded zones
zoneCache = {}  // key: zone name; value: Zone object

// module-level function to load or reactivate a zone, by name:
load = function(zoneName)
	if zoneCache.hasIndex(zoneName) then
		// already loaded — just reactivate it
		zoneCache[zoneName].activate
		return
	end if
	
	// Not loaded; load it!
	import zoneName
	zoneModule = locals[zoneName]
	zoneModule.load
	zoneCache[zoneName] = zone.current
end function

