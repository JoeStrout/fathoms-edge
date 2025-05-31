// The Canversation class represents an NPC conversation.  This can be
// anything from a simple comment, to a rich conversation tree.

globals.ConvIcon = {}
// Icons that appear (in a speech bubble) above an NPCs head while this
// conversation is available (if the player hasn't already done it).
ConvIcon.NONE
ConvIcon.GIVEQUEST = "GIVEQUEST"   // ?
ConvIcon.GIVEREWARD = "GIVEREWARD" // !
ConvIcon.CANCELED = "CANCELED"     // X
ConvIcon.HAPPY = "HAPPY"           // :)
ConvIcon.SAD = "SAD"               // :(
ConvIcon.HEART = "HEART"           // heart icon
ConvIcon.SKULL = "SKULL"           // skull icon

// ConvNode: represents a single message, with possible responses.
globals.ConvNode = {}
ConvNode.speech = "..."
ConvNode.responses = []
ConvNode.Make = function(speech)
	node = new ConvNode
	node.speech = speech
	return node
end function
	

// ConvResponse: a response the player can select to a ConvNode.  These
// may lead to more ConvNodes, or they may terminate the conversation.
globals.ConvResponse = {}
ConvResponse.speech = "Yes."
ConvResponse.next = null      // ConvNode, or null
ConvResponse.callback = null  // function invoked when this response is selected

// Conversation: wraps up a whole ConvNode tree.
globals.Conversation = {}
Conversation.icon = null  // one of the ConvIcon constants above
Conversation.done = false // true after the player has been through it
Conversation.top = null   // ConvNode object

Conversation.Make = function(speech, icon="HAPPY")
	conv = new Conversation
	conv.icon = icon
	conv.top = ConvNode.Make(speech)
	return conv
end function
