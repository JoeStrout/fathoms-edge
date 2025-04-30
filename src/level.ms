// This module represents the currently loaded level map.

// Note that there is always just one, 2-dimensional map loaded at
// a time.  If the game world has multiple levels, those will be
// managed separately, with just one at a time in play.

import "importUtil"
ensureImport "disp"
ensureImport "listUtil"
ensureImport "qa"

width = 40
height = 25

cellSize = disp.main.cellSize - disp.main.overlap

things = null	// 2D array containing list of items for each x,y cell

clearToSize = function(width, height)
	for d in [disp.background, disp.main, disp.overlay]
		d.extent = [width, height]
		d.clear
	end for
	disp.sprite.clear
	outer.things = list.init2d(width, height, null)
end function

addThing = function(thing, x, y)
	qa.assert thing isa Thing and x isa number and y isa number
	if 0 <= x < width and 0 <= y < height then
		if things[x][y] == null then things[x][y] = []
		things[x][y].push thing
		if thing.image then
			disp.sprite.sprites.push thing.sprite
			thing.sprite.x = cellSize * x + cellSize/2
			thing.sprite.y = cellSize * y + cellSize/2
		else if thing.iconIdx then
			disp.main.setCell x, y, thing.iconIdx
			disp.main.setCellTint x, y, thing.color
		end if
	end if
end function

removeThing = function(thing)
	if 0 <= thing.x < width and 0 <= thing.y < height and things[thing.x][thing.y] then
		things[thing.x][thing.y].removeVal thing
		// ToDo: update display
	end if
end function

moveThing = function(thing, newX, newY)
	if 0 <= thing.x < width and 0 <= thing.y < height and things[thing.x][thing.y] then
		things[thing.x][thing.y].removeVal thing
	end if
	if 0 <= newX < width and 0 <= newY < height then
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
end function