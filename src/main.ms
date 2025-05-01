import "importUtil"
ensureImport "disp"
ensureImport "level"
ensureImport "mapTools"
ensureImport "ontology"
ensureImport "town"
ensureImport "ui"
ensureImport "keyboardInput"

setup = function
	globals.player = new Player
	town.load
	globals.turn = 0
	globals.gameOver = false
end function

runMainLoop = function
	while not gameOver
		cmd = keyboardInput.getNextCommand
		if cmd and player.handleCommand(cmd) then
			globals.turn += 1
			text.color = color.green
			text.row = 25; print "Turn: " + turn  + "    Last cmd: " + cmd + " "*20
			print "X: " + player.x + "   Y: " + player.y + " "*20
		end if
	end while
end function


setup
runMainLoop
