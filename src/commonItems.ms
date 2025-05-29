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


globals.Bone = new Item
Bone.Make = function
	bone = super.Make("bone", 784)
	bone.color = "#CCCCCC"
	bone.size = 2
	return bone
end function

globals.Chest = new Container
Chest.Make = function
	chest = Container.Make("chest")
	chest.color = "#CC9933"
	return chest
end function

globals.Ring = new Equipment
Ring.Make = function(name="ring", iconIdx=910, value=75)
	item = super.Make(name, iconIdx, loadout.RING)
	item.color = color.silver
	item.value = value
	return item
end function

globals.DiamondRing = new Ring
DiamondRing.Make = function
	return new Ring.Make("diamond ring", 910, 75)
end function

globals.RingOfProtection = new Ring
RingOfProtection.Make = function
	ring = super.Make("Ring of Protection", 907)
	ring.value = 325
	ring.resistance.fire = 10
	ring.resistance.cold = 10
	ring.resistance.shock = 5
	return ring
end function


globals.Amulet = new Equipment
Amulet.Make = function(name="amulet", iconIdx=940, value=120)
	item = super.Make(name, iconIdx, loadout.NECK)
	item.color = "#FFCC33"
	item.value = value
	return item
end function

globals.Apple = new Food
Apple.Make = function
	item = super.Make("apple", 943)
	item.color = "#FF3333"
	item.value = 2
	return item
end function

globals.Bread = new Food
Bread.Make = function
	item = Food.Make("bread", 911)
	item.color = "#CCCC33"
	item.size = 2
	return item
end function

globals.Buckler = new Equipment
Buckler.Make = function
	item = Equipment.Make("buckler", 809, loadout.OFFHAND)
	item.color = "#CC9966"
	item.resistance.physical = 5
	item.size = 3
	return item
end function


