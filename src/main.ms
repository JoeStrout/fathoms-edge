import "importUtil"
ensureImport "miscUtil"
ensureImport "disp"
ensureImport "level"
ensureImport "mapTools"
ensureImport "ontology"
ensureImport "town"
ensureImport "ui"
ensureImport "keyboardInput"

setup = function
	globals.player = Player.Make
	
	sword = Equipment.Make("sword", 898, loadout.TWOHAND)
	sword.damage.physical = 3
	sword.size = 2
	player.contain sword
	player.loadout.equip sword
	
	armor = Equipment.Make("leather armor", 736, loadout.BODY)
	armor.resistance.physical = 10
	armor.size = 3
	player.contain armor
	player.loadout.equip armor
	
	town.load
	globals.turn = 0
	globals.gameOver = false
end function

runMainLoop = function
	ui.update
	while not gameOver
		yield
		cmd = keyboardInput.getNextCommand
		if cmd and player.handleCommand(cmd) then
			globals.turn += 1
			for agent in level.agents
				agent.update
			end for
			ui.update
		end if
	end while
end function


setup
runMainLoop
