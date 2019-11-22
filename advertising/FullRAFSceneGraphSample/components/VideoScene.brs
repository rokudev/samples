' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 

'Main Scene Initialization with menu, facade and video.
function init()
	m.top.backgroundURI = ""
	m.top.backgroundColor="0x000000FF"
	m.video = m.top.FindNode("MainVideo")
	m.list = m.top.FindNode("MenuList")
	m.list.setFocus(true) 
end function