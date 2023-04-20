sub Main()
	screen = CreateObject("roSGScreen")
	port = CreateObject("roMessagePort")
	screen.setMessagePort(m.port)
	scene = screen.CreateScene("TestScene")
	screen.show()
	scene.setFocus(true)

	while(true)
		msg = wait(0, port)
		msgType = type(msg)
		if msgType = "roSGScreenEvent"
			if msg.isScreenClosed() then return
		end if
	end while
end sub

