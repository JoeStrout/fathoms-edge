import "importUtil"
ensureImport "disp"
ensureImport "level"
ensureImport "mapTools"
ensureImport "ontology"
ensureImport "town"
ensureImport "ui"
ensureImport "keyboardInput"

setup = function
	globals.player = Player.Make
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
			player.update
			ui.update
		end if
	end while
end function


setup
runMainLoop
