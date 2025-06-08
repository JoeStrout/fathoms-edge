// This module represents the currently loaded zone map.

// Note that there is always just one, 2-dimensional map loaded at
// a time.  If the game world has multiple levels, those will be
// managed separately, with just one at a time in play.

import "importUtil"
ensureImport "disp"
ensureImport "listUtil"
ensureImport "qa"
ensureImport "mapElement"

width = 40
height = 25

cellSize = disp.main.cellSize - disp.main.overlap

things = null	// 2D array containing list of things for each [x][y] cell
mapElems = null	// 2D array of MapElement instance (static content), [x][y]
agents = []		// flat list of agents in the zone
portals = []	// list of Portal instances in the zone
elemPalette = [null] * 256	// palette of MapElements we draw from

OOBElement = new MapElement
OOBElement.name = "Out of Bounds"
OOBElement.blocksWalk = true
OOBElement.blocksFly = true


clearToSize = function(width, height, defaultElemIndex=null)
	outer.width = width
	outer.height = height
	for d in [disp.bgColor, disp.background, disp.main, disp.overlay]
		d.extent = [width, height]
		d.clear
	end for
	disp.bgColor.clear 0
	disp.bgColor.setCellTint range(0, width), range(0, height), color.black
	disp.sprite.clear
	outer.things = list.init2d(width, height, null)
	defaultElem = null
	if defaultElemIndex != null then defaultElem = elemPalette[defaultElemIndex]
	outer.mapElems = list.init2d(width, height, defaultElem)
	if defaultElem then
		for y in range(height-1)
			for x in range(0, width-1)
				defaultElem.apply x, y
			end for
		end for
	end if
end function

inBounds = function(x,y)
	return 0 <= x < width and 0 <= y < height
end function

element = function(x,y)
	if 0 <= x < width and 0 <= y < height then return mapElems[x][y]
	return OOBElement
end function

setElement = function(x, y, elementRefOrIndex)
	if not inBounds(x, y) then return
	if elementRefOrIndex isa number then
		mapElems[x][y] = elemPalette[elementRefOrIndex]
	else
		mapElems[x][y] = elementRefOrIndex
	end if
end function

// saveElemMap: write out our 2D array of MapElements, defining the
// static contents of this zone, to the given file.
saveElemMap = function(path)
	rd = new RawData
	rd.resize 4 + width * height
	rd.setUshort 0, width
	rd.setUshort 2, height
	i = 4
	for y in range(height-1)  // NOTE: top-down
		for x in range(0, width-1)
			if mapElems[x][y] == null then idx = 0 else idx = mapElems[x][y].id
			rd.setByte i, idx
			i += 1
		end for
	end for
	file.saveRaw path, rd
end function

// loadElemMap: read our 2D array of MapElements, defining the
// static contents of this zone, from the given file.
loadElemMap = function(path)
	globals.rd = file.loadRaw(path)
	width = rd.ushort(0)
	height = rd.ushort(2)
	clearToSize width, height
	i = 4
	for y in range(height-1)  // NOTE: top-down
		for x in range(0, width-1)
			elem = elemPalette[rd.byte(i)]
			mapElems[x][y] = elem
			elem.apply x, y
			i += 1
		end for
	end for
end function

addThing = function(thing, x, y)
	qa.assert thing isa Thing and x isa number and y isa number
	if 0 <= x < width and 0 <= y < height then
		if things[x][y] == null then things[x][y] = []
		if thing isa Item and thing.qty != null then
//			print "adding " + thing.nameWithQty + " to zone at " + x + "," + y
			for item in things[x][y]
				if item isa Item and thing.canStackWith(item) then
					// just add to the existing item stack!
					item.qty += 1
					item.noteQtyChanged
					return
				end if
			end for
		end if
		things[x][y].push thing
		thing.x = x
		thing.y = y
		if thing.image then
			disp.sprite.sprites.push thing.sprite
			disp.positionSprite thing.sprite, x, y
		else if thing.iconIdx then
			disp.main.setCell x, y, thing.iconIdx
			disp.main.setCellTint x, y, thing.color
		end if
		thing.decorate
	end if
	if thing isa Agent and not agents.contains(thing) then agents.push thing
end function

removeThing = function(thing)
	if 0 <= thing.x < width and 0 <= thing.y < height and things[thing.x][thing.y] then
//		print "removing " + thing.nameWithQty + " from zone at " + thing.x + "," + thing.y
		things[thing.x][thing.y].removeRef thing
		if thing.image then
			disp.sprite.sprites.removeVal thing.sprite
		else if disp.main.cell(thing.x, thing.y) == thing.iconIdx then
			disp.main.setCell thing.x, thing.y, null
		end if
		thing.removeDecorations
	end if
	if thing isa Agent then agents.removeRef thing
end function

getItems = function(x, y)
	result = []
	if things[x][y] != null then
		for thing in things[x][y]
			if thing isa Item then result.push thing
		end for
	end if
	return result
end function

getMob = function(x, y)
	if inBounds(x, y) and things[x][y] != null then
		for thing in things[x][y]
			if thing isa Mob then return thing
		end for
	end if
	return null
end function

moveThing = function(thing, newX, newY)
	if inBounds(thing.x, thing.y) and things[thing.x][thing.y] then
		things[thing.x][thing.y].removeRef thing
	end if
	if inBounds(newX, newY) then
		if things[newX][newY] == null then things[newX][newY] = []
		things[newX][newY].push thing
	end if
	
	if thing.image then
		// Easy case: just move the sprite!
		thing.sprite.x = cellSize * newX + cellSize/2
		thing.sprite.y = cellSize * newY + cellSize/2
	else if thing.iconIdx then
		// Almost-as-easy case: update the tile display
		disp.main.setCell thing.x, thing.y, null
		disp.main.setCell newX, newY, thing.iconIdx
		disp.main.setCellTint newX, newY, thing.color
	end if
	thing.decorate
end function

// Return whether the given x,y position can be passed by the given agent.
passable = function(x, y, byAgent)
	if x < 0 or x >= width or y < 0 or y >= height then return false
	elem = mapElems[x][y]
	if elem.blockWalk then return false // ToDo: handle flying
	if things[x][y] == null then return true
	for thing in things[x][y]
		if thing.blocksMovement then return false
	end for
	return true
end function

// Deal with an agent attempting to interact with a location (usually,
// by bumping into it as if trying to move).
interact = function(x, y, byAgent)
	if not inBounds(x, y) then
		byAgent.note "You can't move that way."
	else if things[x][y] then
		for thing in things[x][y]
			thing.interact byAgent
		end for
	else
		elem = mapElems[x][y]
		elem.bump byAgent, x, y
	end if	
end function