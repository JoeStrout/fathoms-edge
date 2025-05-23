import "importUtil"
ensureImport "miscUtil"
ensureImport "disp"
ensureImport "zone"
ensureImport "mapTools"
ensureImport "ontology"
ensureImport "town"
ensureImport "ui"
ensureImport "keyboardInput"
ensureImport "visualFX"

setup = function
	globals.player = Player.Make
	
	sword = Weapon.Make("sword", 898, loadout.TWOHAND)
	sword.color = color.silver
	sword.damage.physical = 3
	sword.size = 2
	player.contain sword
	player.loadout.equip sword
	
	wand = Weapon.Make("Wand of Frost", 864, loadout.MAINHAND)
	wand.color = "#CCCCFF"
	wand.attackRange = 10
	wand.damage.cold = 2
	player.contain wand
	
	armor = Equipment.Make("leather armor", 736, loadout.BODY)
	armor.color = color.brown
	armor.resistance.physical = 10
	armor.size = 3
	player.contain armor
	player.loadout.equip armor
	
	town.load
	globals.turn = 0
	globals.gameOver = false
end function

updateAll = function(newTurn=false)
	if newTurn then
		globals.turn += 1
		for agent in zone.agents
			agent.update
			if agent == player then disp.centerOn player.x, player.y
		end for
	end if
	ui.update
	visualFX.update
	
end function

runMainLoop = function
	updateAll
	while not gameOver
		yield
		cmd = keyboardInput.getNextCommand
		if cmd then updateAll(player.handleCommand(cmd))
	end while
end function


setup
runMainLoop
