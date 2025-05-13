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

MapElement.pick = function(scalarOrList, x, y)
	if scalarOrList isa list then
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
	
	tile = self.pick(tile, x, y)
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
	td.setCellTint x, y, self.pick(color, x, y)
end function

MapElement.apply = function(x, y)
	disp.bgColor.setCellTint x, y, self.pick(self.bgColor, x, y)
	self.applyTileId disp.background, self.bgTileId, self.bgTileColor, x, y
	self.applyTileId disp.main, self.mainTileId, self.mainTileColor, x, y
	self.applyTileId disp.overlay, self.overlayTileId, self.overlayTileColor, x, y
	self.applyTileId disp.overlay, self.up1TileId, self.overlayTileColor, x, y + 1
	self.applyTileId disp.overlay, self.up2TileId, self.overlayTileColor, x, y + 2
end function

// Load and return a list of MapElement objects from a .tsv (tab-separated
// value) file.
MapElement.LoadFromFile = function(path)
	globals.data = tsv.parseFile(path)
	while data[-1].id == ""; data.pop; end while
	maxId = val(data[-1].id)
	result = [null] * (maxId+1)
	print result.len
	for d in data
		// clear out empty columns
		for k in d.indexes; if d[k] == "" then d.remove k; end for
		// then create a MapElement out of it -- and possibly a previous one
		if d.hasIndex("basedOnId") then
			result[d.id] = new MapElement + result[d.basedOnId] + d
		else
			result[d.id] = new MapElement + d
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

	