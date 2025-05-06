// This module builds the map of Fathom's Edge (the home town).

import "importUtil"
ensureImport "disp"
ensureImport "mapTools"
ensureImport "level"
ensureImport "status"

load = function
	level.clearToSize 40, 30
	mapTools.fillTiles disp.background, [1,5,5,5], "#006600", 50
	
	Tree = Obstacle.Make("tree", 211)
	Tree.color = color.brown
	for i in range(20)
		tree = new Tree
		tree.placeOnMap floor(40*rnd), floor(30*rnd)
		disp.overlay.setCell tree.x, tree.y+1, 179 // tree top
		disp.overlay.setCellTint tree.x, tree.y+1, "#88FF88"
	end for
	
	bone = Item.Make("bone", 784)
	bone.color = "#CCCCCC"
	bone.size = 2
	bone.placeOnMap 8, 3
	
	globals.apple = Food.Make("apple", 943)
	apple.color = "#FF4444"
	apple.value = 2
	apple.placeOnMap 10, 15
	
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
	
	for i in range(5)
		shroom = new Shroom
		shroom.color = Shroom.Colors.any
		shroom.placeOnMap floor(40*rnd), floor(30*rnd)
	end for
	
	Rat = Mob.Make("rat", 287)
	Rat.color = color.brown
	Rat.disposition = Mob.FLEEING
	Rat.health = 5
	Rat.leavesCorpse = true
	for i in range(2)
		rat = new Rat
		rat.placeOnMap floor(40*rnd), floor(30*rnd)
	end for	
	
	Slime = Mob.Make("slime", 283)
	Slime.color = color.lime
	Slime.disposition = Mob.HOSTILE
	Slime.health = 10
	for i in range(2)
		slime = new Slime
		slime.placeOnMap floor(40*rnd), floor(30*rnd)
	end for
	
	player.placeOnMap 15, 10
end function

