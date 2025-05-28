// Miscellaneous utility functions.

import "importUtil"
ensureImport "base64"
ensureImport "styledText"	// (for bug fix below)

// Roll against a % probability (0-100).
// Return true on success, false on failure.
globals.chance = function(percentChance)
	roll = round(100 * rnd)
	return roll < percentChance
end function

// Get maximum of 2, 3, or 4 values.
globals.max = function(a, b, c, d)
	if a > b then result = a else result = b
	if c and c > result then result = c
	if d and d > result then result = d
	return result
end function


// Get a non-hidden copy of refIndexOf (finding index of an item
// by reference), since that is a thing we often need.
list.refIndexOf = @list._refIndexOf

// A version of list.indexOf that compares object by reference,
// instead of by their values.  Use this when you might have
// identical objects in the list, but you want to find some 
// specific object (not just an equivalent one).
list.containsRef = function(item)
	return self._refIndexOf(item) != null
end function


// Handy helpers for modifier keys.
key.shiftPressed = function
	return key.pressed("left shift") or key.pressed("right shift")
end function

key.altPressed = function
	return key.pressed("left alt") or key.pressed("right alt")
end function

key.controlPressed = function
	return key.pressed("left control") or key.pressed("right control")
end function



// Similarly, remove a list element by reference.
list.removeRef = function(item)
	idx = self._refIndexOf(item)
	if idx != null then self.remove idx
end function

imageToBase64 = function(img)
	raw = new RawData
	raw.resize img.width * img.height / 8
	outp = 0
	d = 0
	bits = 0
	for y in range(img.height-1)
		for x in range(0, img.width-1)
			c = img.pixel(x, y)
			d = d * 2 + (c[1:3] > "88" and c[-2:] > "88")
			bits += 1
			if bits == 8 then
				raw.setByte outp, d
				outp += 1
				d = 0
				bits = 0
			end if
		end for
	end for
	return base64.toBase64(raw)
end function

base64ToImage = function(b64)
	globals.raw = base64.toRaw(b64)
	w = sqrt(raw.len * 8)
	h = floor(raw.len * 8 / w)
	img = Image.create(w, h, color.clear)
	inp = 0
	bitmask = 0
	for y in range(h-1)
		for x in range(0, img.width-1)
			if bitmask < 1 then
				bitmask = 128
				d = raw.byte(inp)
				inp += 1
			end if
			if bitAnd(d, bitmask) then img.setPixel x, y, color.white
			bitmask /= 2
		end for
	end for
	return img
end function

// Example base64 string of a mushroom:
// AAAAAAAAB8Ad8D/YP/we/Af4AAABwAHAA8AHwAOAAAA=

// Find the plural form of a regular noun.  Note: this does not handle
// irregular nouns (e.g. man -> men, sheep -> sheep, etc).  It also does
// not handle upper-case words (they must at least end in lower case).
string.plural = function
	s = self
	if s == "" then return s
	if s[-1] == "s" or s[-1] == "x" or s[-2:] == "sh" or s[-2:] == "ch" then
		return s + "es"  // box -> boxes
	else if s[-1] == "z" then
		return s + "zes" // quiz -> quizzes
	else if s[-1] == "y" then
		if "aeoiu".indexOf(s[-2]) != null then return s + "s"  // boy -> boys
		return s[:-1] + "ies"  // city -> cities
	else if s[-1] == "f" then
		return s[:-1] + "ves"  // leaf -> leaves
	else if s[-2:] == "fe" then
		return s[:-2] + "ves"  // life -> lives
	else if s[-1] == "o" and "aeiou".indexOf(s[-2]) == null then
		return s + "es"  // potato -> potatoes
	else
		return s + "s"  // car -> cars
	end if
end function

// Fix for bug in /sys/lib/styledText (in Mini Micro 1.6.2 and earlier):
styledText.BmfPrinter.calcHeight = function(markup, x, wrapAt=null, wrapTo=null)
	if wrapAt == null then wrapAt = self.wrapAt
	if wrapTo == null then wrapTo = x
	y = 0
	top = y - self.font.sizeOver
	for styleRun in styledText.parseMarkup(markup)
		while wrapAt - x < self.font.width(styleRun.text)
			partialText = self.cutToFit(styleRun, wrapAt - x, x <= wrapTo)
			x = wrapTo
			y = y - self.font.lineHeight
		end while
		x = self.printOneRun(styleRun, styleRun.text, x, y, true)
	end for
	bottom = y - self.font.sizeUnder
	return top - bottom
end function

// And, an improved printStyleRuns method that supports line breaks!
styledText.BmfPrinter.printStyleRuns = function(runs)
	for styleRun in runs
		hardlines = styleRun.text.split(char(10))
		for i in hardlines.indexes
			styleLine = new styleRun
			styleLine.text = hardlines[i]
			while self.wrapAt - self.x < self.font.width(styleLine.text)
				partialText = self.cutToFit(styleLine, self.wrapAt - self.x, self.x <= self.wrapTo)
				self.printOneRun styleRun, partialText, self.x, self.y
				self.x = self.wrapTo
				self.y -= self.font.lineHeight
			end while
			self.x = self.printOneRun(styleRun, styleLine.text, self.x, self.y)
			self.y -= self.font.lineHeight
			if i < hardlines.len-1 then self.x = self.wrapTo
		end for
	end for
	self.x = self.wrapTo
	self.y -= self.font.lineHeight
end function


if locals == globals then
	img = file.loadImage("/usr/pics/shroom.png")
	clear
	gfx.drawImage img, 400, 500
	print imageToBase64(img)
end if
