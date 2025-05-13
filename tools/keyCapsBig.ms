// Program to prototype the key-cap glyphs for all
// all ASCII characters (though we will use only a
// subset of these).

clear
gfx.clear color.clear

w = 27
h = 27
pw = w * 16
ph = h * 8

capImg = file.loadImage("keyCap.png")

drawChar = function(c, x, y)
	gfx.drawImage capImg, x, y
	gfx.print c, x + w/2 - 7, y + h/2 - 11, "small", color.black
end function


for i in range(1, 127)
	row = floor(i/16)
	col = i - 16 * row
	drawChar char(i), col*w, ph - h - row*h
end for

path = "/usr/pics/keyCaps.png"
file.saveImage path, gfx.getImage(0, 0, pw, ph)
print "Saved image to " + path
