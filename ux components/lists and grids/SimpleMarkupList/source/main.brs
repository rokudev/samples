'********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

sub Main()
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)
    scene = screen.CreateScene("SimpleMarkupListScene")
    screen.show()

    while(true)
        msg = wait(0, m.port)
	msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
end sub

