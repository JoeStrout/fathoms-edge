// This module maps keyboard keys to commands.

keys = {}

keys[char(17)] = "WEST"
keys.a = "WEST"

keys[char(19)] = "NORTH"
keys.w = "NORTH"
keys[","] = "NORTH"

keys[char(18)] = "EAST"
keys.d = "EAST"
keys.e = "EAST"

keys[char(20)] = "SOUTH"
keys.s = "SOUTH"
keys.o = "SOUTH"

keys.z = "WAIT"

keys[char(10)] = "INTERACT"
keys[" "] = "INTERACT"

keys.i = "INVENTORY"


getNextCommand = function
	while key.available
		k = key.get
		if keys.hasIndex(k) then return keys[k]
	end while
	return ""
end function


if locals == globals then
	clear
	print "Press any key to see the resulting command."
	while true
		yield
		cmd = getNextCommand
		if cmd then print cmd
	end while
end if

		