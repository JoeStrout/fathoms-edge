// This module builds the map of Fathom's Edge (the home town).

import "importUtil"
ensureImport "disp"
ensureImport "mapTools"
ensureImport "zone"
ensureImport "status"
ensureImport "commonItems"

palettePath = "/usr/data/mapElements.tsv"
zonePath = "/usr/data/town.dat"

load = function
	zone.elemPalette = MapElement.LoadFromFile(palettePath)
	zone.loadElemMap zonePath

	bone = Item.Make("bone", 784)
	bone.color = "#CCCCCC"
	bone.size = 2
	bone.placeOnMap 8, 3
	
	chest = Container.Make("chest")
	chest.color = "#CC9933"
	chest.placeOnMap 15, 8

	item = Equipment.Make("Diamond Ring", 910, loadout.RING)
	item.color = color.silver
	item.value = 75
	chest.contain item
	
	item = Equipment.Make("Amulet", 940, loadout.NECK)
	item.color = "#FFCC33"
	item.value = 120
	item.resistance.shock = 5
	chest.contain item
	
	item = Food.Make("Bread", 911)
	item.color = color.yellow
	item.size = 2
	chest.contain item
	
	item = Equipment.Make("Buckler", 809, loadout.OFFHAND)
	item.color = color.brown
	item.resistance.physical = 5
	item.size = 3
	chest.contain item
	
	
	Sign.Make("Welcome to Fathom's Edge").placeOnMap 20, 20
	Sign.Make("East: Fathom's Edge; South: Fathom", 224).placeOnMap 16, 7
	
	for i in [0,1,2,4,5]
		globals.apple = Food.Make("apple", 943)
		apple.color = "#FF4444"
		apple.value = 2
		if i == 5 then apple.qty = 5
		apple.placeOnMap 10+i, 12
	end for
	
	for i in range(0,4)
		gold = Gold.Make(i+1)
		gold.placeOnMap 10+i, 8
	end for
	
	Shroom = Food.Make("shroom", file.loadImage("/usr/pics/shroom.png"))
	Shroom.Colors = [color.red, color.green, color.brown, color.yellow,
	  "#CCCCFF", "#CCCCCC", "#CCCCAA"]
	Shroom.size = 1
	Shroom.value = 1
	Shroom.healthValue = 2
	Shroom.useBy = function(agent)
		super.useBy agent
		// Add some crazy random effect!
		fx = [
		  status.POISONED,
		  status.WEAKENED,
		  status.VULNERABLE,
		  status.INVULNERABLE,
		  status.STUNNED,
		  status.SLOWED,
		  status.HASTENED,
		  status.CONFUSED,
		  status.BLIND,
		  status.DEAF,
		  status.HALLUCINATING,
		  status.BLESSED,
		  status.CURSED,
		  status.CHARMED,
		  status.ENCUMBERED,
		  status.FATIGUED,
		  status.GLOWING,
		  status.MUTE,
		  status.PANICKED,
		  status.SERENE]
		agent.statuses.apply fx.any, 5  // (lasts 5 turns)
	end function
	
//	for i in range(5)
//		shroom = new Shroom
//		shroom.color = Shroom.Colors.any
//		shroom.placeOnMap floor(40*rnd), floor(30*rnd)
//	end for
//	
	Ring = Equipment.Make("Ring of Protection", 907, loadout.RING)
	Ring.resistance.fire = 10
	Ring.resistance.cold = 10
	Ring.resistance.shock = 5
//	
//	ring = new Ring
//	ring.placeOnMap 7, 9
	
	Rat = Mob.Make("rat", 287)
	Rat.color = color.brown
	Rat.disposition = Mob.HOSTILE
	Rat.health = 5
	Rat.leavesCorpse = true
	Rat.attacksPerTurn = 2
	for i in [] //range(2)
		rat = Rat.Make
		rat.placeOnMap floor(40*rnd), floor(30*rnd)
	end for	
	
	Slime = Mob.Make("slime", 283)
	Slime.color = color.lime
	Slime.disposition = Mob.HOSTILE
	Slime.health = 10
	Slime.attacksPerTurn = 0.5
	Slime.damage.physical = 3
	for i in [] // range(2)
		slime = Slime.Make
		if rnd < 0.5 then slime.contain new Ring
		slime.placeOnMap floor(40*rnd), floor(30*rnd)
	end for
	
	player.placeOnMap 15, 10
end function

