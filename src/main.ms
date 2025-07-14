import "importUtil"
ensureImport "miscUtil"
ensureImport "disp"
ensureImport "zone"
ensureImport "mapTools"
ensureImport "ontology"
ensureImport "ui"
ensureImport "keyboardInput"
ensureImport "visualFX"

setup = function
	if not env.importPaths.contains("/usr/town") then
		env.importPaths.push "/usr/town"
	end if
	
	globals.player = Player.Make
	
	sword = Weapon.Make("sword", 898, loadout.TWOHAND)
	sword.color = color.silver
	sword.damage.physical = 3
	sword.size = 2
	sword.value = 45
	player.contain sword
	player.loadout.equip sword
	
	wand = Weapon.Make("Wand of Frost", 864, loadout.MAINHAND)
	wand.color = "#CCCCFF"
	wand.attackRange = 10
	wand.damage.cold = 2
	wand.value = 215
	player.contain wand
	
	armor = Equipment.Make("leather armor", 736, loadout.BODY)
	armor.color = color.brown
	armor.resistance.physical = 10
	armor.size = 5
	armor.value = 24
	player.contain armor
	player.loadout.equip armor
	
	zone.load "town"
	globals.turn = 0
	globals.gameOver = false
end function

updateAll = function(newTurn=false)
	if newTurn then
		globals.turn += 1
		for agent in zone.current.agents
			agent.update
			if agent == player then disp.centerOn player.x, player.y
		end for
	end if
	ui.update
	visualFX.update
	
end function

runMainLoop = function
	updateAll true
	while not gameOver
		yield
		cmd = keyboardInput.getNextCommand
		if cmd then updateAll(player.handleCommand(cmd))
	end while
end function


setup
runMainLoop
