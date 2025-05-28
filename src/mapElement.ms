// This defines the MapElement class — each instance of this class represents
// data about a particular type of cell on the map, including both visual 
// (tile IDs for the various display layers) and semantic (whether it blocks
// walking, applies certain status effects, etc.).

import "importUtil"
ensureImport "stringUtil"
ensureImport "listUtil"
ensureImport "disp"
ensureImport "tsv"

globals.MapElement = {}
MapElement.id = 0
MapElement.name = ""
MapElement.blockWalk = false
MapElement.blockFly = false
MapElement.waterDepth = 0
MapElement.portalTo = null
MapElement.enterFrom = "NSEW"
MapElement.enterLabel = ""
MapElement.enterKey = null

MapElement["bgColor$"] = "#FFFFFF"
MapElement["bgTileId$"] = null
MapElement["bgTileColor$"] = "#AAAAAA"
MapElement["mainTileId$"] = null
MapElement["mainTileColor$"] = "#AAAAAA"
MapElement["overlayTileId$"] = null
MapElement["overlayTileColor$"] = "#AAAAAA"
MapElement["up1TileId$"] = null
MapElement["up1TileColor$"] = "#AAAAAA"
MapElement["up2TileId$"] = null
MapElement["up2TileColor$"] = "#AAAAAA"


parseListOrString = function(s)
	if s == null then return ""
	if s isa number then return str(s)
	if s.indexOf(",") == null then return s
	s = s.replace(", ", ",")
	return s.split(",")
end function

MapElement.bgColor = function
	self.bgColor = parseListOrString(self["bgColor$"])
	return self.bgColor
end function

MapElement.bgTileId = function
	self.bgTileId = parseListOrString(self["bgTileId$"])
	return self.bgTileId
end function

MapElement.bgTileColor = function
	self.bgTileColor = parseListOrString(self["bgTileColor$"])
	return self.bgTileColor
end function

MapElement.mainTileId = function
	self.mainTileId = parseListOrString(self["mainTileId$"])
	return self.mainTileId
end function

MapElement.mainTileColor = function
	self.mainTileColor = parseListOrString(self["mainTileColor$"])
	return self.mainTileColor
end function

MapElement.overlayTileId = function
	self.overlayTileId = parseListOrString(self["overlayTileId$"])
	return self.overlayTileId
end function

MapElement.overlayTileColor = function
	self.overlayTileColor = parseListOrString(self["overlayTileColor$"])
	return self.overlayTileColor
end function

MapElement.up1TileId = function
	self.up1TileId = parseListOrString(self["up1TileId$"])
	return self.up1TileId
end function

MapElement.up1TileColor = function
	self.up1TileColor = parseListOrString(self["up1TileColor$"])
	return self.up1TileColor
end function

MapElement.up2TileId = function
	self.up2TileId = parseListOrString(self["up2TileId$"])
	return self.up2TileId
end function

MapElement.up2TileColor = function
	self.up2TileColor = parseListOrString(self["up2TileColor$"])
	return self.up2TileColor
end function

pick = function(scalarOrList, x, y)
	if scalarOrList isa list then
		if x == null then return scalarOrList[0]
		// reset our rnd generator based on the map position
		rnd hash(x * 1567 + y); rnd
		// and then draw a "random" element of the list accordingly
		idx = floor(rnd * 1601) % scalarOrList.len
		return scalarOrList[idx]
	end if
	return scalarOrList
end function

MapElement.applyTileId = function(td, tile, color, x, y)
	if not tile then
		td.setCell x, y, null
		td.setCellTransform x, y, 0
		return
	end if
	
	tile = pick(tile, x, y)
	if tile[-1] >= "A" then
		c = tile[-1]
		tile = tile[:-1]
		if c == "R" then // right
			t = 3
		else if c == "L" then // left
			t = 1
		else if c == "U" then // upside-down (180° rotation)
			t = 2
		else if c == "F" then // flipped...
			c = tile[-1]
			tile = tile[:-1]
			if c == "R" then  // right flipped
				t = 7
			else if c == "L" then // left flipped
				t = 5
			else if c == "U" then // upside-down and flipped
				t = 6
			else // flipped only
				t = 4
				tile += c
			end if
		end if
		td.setCell x, y, val(tile)
		td.setCellTransform x, y, t
	else
		td.setCell x, y, val(tile)
		td.setCellTransform x, y, 0
	end if
	td.setCellTint x, y, pick(color, x, y)
end function

drawTileImage = function(tile, color, x, y, g=null)
	if g == null then g = gfx
	if not tile then return
	tint = pick(color)
	tile = pick(tile)
	if tile[-1] >= "A" then
		c = tile[-1]
		tile = tile[:-1]
		img = oneBit.getTileImage(val(tile))
		img = img.getImage  // (get a copy to mutate)
		if c == "R" then // right
			img.rotate -90
		else if c == "L" then // left
			img.rotate 90
		else if c == "U" then // upside-down (180° rotation)
			img.rotate 180
		else if c == "F" then // flipped...
			c = tile[-1]
			tile = tile[:-1]
			img = oneBit.getTileImage(val(tile))
			img = img.getImage  // (get a copy to mutate)
			img.flip
			if c == "R" then  // right flipped
				img.rotate -90
			else if c == "L" then // left flipped
				img.rotate 90
			else if c == "U" then // upside-down and flipped
				img.rotate 180
			end if
		end if
	else
		img = oneBit.getTileImage(val(tile))
	end if
	g.drawImage img, x, y, -1, -1, 0, 0, -1, -1, tint
end function

MapElement.apply = function(x, y)
	disp.bgColor.setCellTint x, y, pick(self.bgColor, x, y)
	self.applyTileId disp.background, self.bgTileId, self.bgTileColor, x, y
	self.applyTileId disp.main, self.mainTileId, self.mainTileColor, x, y
	self.applyTileId disp.overlay, self.overlayTileId, self.overlayTileColor, x, y
	if self.up1TileId then
		self.applyTileId disp.overlay, self.up1TileId, self.overlayTileColor, x, y + 1
	end if
	if self.up2TileId then
		self.applyTileId disp.overlay, self.up2TileId, self.overlayTileColor, x, y + 2
	end if
end function

MapElement.drawPaletteEntry = function(x, y, g=null)
	if g == null then g = gfx
	g.fillRect x, y, 16, 16, pick(self.bgColor)
	drawTileImage self.bgTileId, self.bgTileColor, x, y, g
	drawTileImage self.mainTileId, self.mainTileColor, x, y, g
	drawTileImage self.overlayTileId, self.overlayTileColor, x, y, g
end function

MapElement.bump = function(agent, x, y)
	agent.note "You can't move that way."
end function
	

// Load and return a list of MapElement objects from a .tsv (tab-separated
// value) file.
MapElement.LoadFromFile = function(path)
	globals.data = tsv.parseFile(path)
	while data[-1].id == ""; data.pop; end while
	maxId = val(data[-1].id)
	result = [null] * (maxId+1)
	for d in data
		// figure out what map element class to use
		if d.class then
			elemClass = outer[d.class]
		else if d.basedOnId isa number then
			elemClass = result[d.basedOnId].__isa
		else
			elemClass = MapElement
		end if
		// clear out empty columns
		for k in d.indexes; if d[k] == "" then d.remove k; end for
		// then create a MapElement out of it -- possibly based on a previous one
		if d.hasIndex("basedOnId") then
			result[d.id] = new MapElement + result[d.basedOnId] + d
			result[d.id].__isa = elemClass // (since the + above could overwrite it)
		else
			result[d.id] = new elemClass + d
		end if
	end for
	return result
end function


test = function
	globals.m = new MapElement
	m["bgColor$"] = color.purple
	m.apply 0, 19
	
	globals.m2 = new MapElement
	m2["bgColor$"] = "#FF0000, #00FF00, #0000FF"
	m2["bgTileId$"] = "0, 1, 1F, 5, 5F"
	m2["bgTileColor$"] = "#006600"
	for x in range(0,30)
		for y in range(3, 18)
			m2.apply x, y
		end for
	end for
end function

if locals == globals then test

	