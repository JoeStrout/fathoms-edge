// Miscellaneous utility functions.

import "importUtil"
ensureImport "base64"

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

if locals == globals then
	img = file.loadImage("/usr/pics/shroom.png")
	clear
	gfx.drawImage img, 400, 500
	print imageToBase64(img)
end if
