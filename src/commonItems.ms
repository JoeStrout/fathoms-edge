// Common items that may be found in town or in any adventure.

if not globals.hasIndex("ontology") then
	import "importUtil"
	ensureImport "miscUtil"
	ensureImport "ontology"
end if

base64ToImage = @miscUtil.base64ToImage

globals.Gold = new Item
Gold.size = 0.01
Gold.color = "#FFCC66"
Gold.name = "gold coin"
Gold.pluralName = "gold"
Gold.Images = [
	base64ToImage("AAAAAAAAAAAAAAAAAAAAAAAAA+AO+B38HfwO+APgAAA="), // (1 coin)
	base64ToImage("AAAAAAAAAAAAAAAAAfAHfA7+Dv43fHHwdgA74A+AAAA="), // (2 coins)
	base64ToImage("AAAAAAAAAAAAAAHwB3wO/i7+d3x58D4ED7wAOAPgAAA="), // (3 coins)
	base64ToImage("AAAAAAAAA+AO+B38HfwO+BPkDBgT5AwYE+QMGAPgAAA="), // (4 coins)
	base64ToImage("AAAD4A74Hfwd/A74E+QMGBPkDBgT5AwYE+QMGAPgAAA="), // (5+ coins)
]

Gold.Make = function(qty=1)
	noob = new self
	noob.qty = qty
	return noob
end function

Gold.image = function
	if self.qty >= Gold.Images.len then return Gold.Images[-1]
	return Gold.Images[self.qty - 1]
end function

Gold.noteQtyChanged = function
	if self._sprite != null then self._sprite.image = self.image
end function
