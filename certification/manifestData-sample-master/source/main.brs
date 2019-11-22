'* Copyright (c) 2017 Roku, Inc. All rights reserved.
'
' File: main.brs
'

' This is the function called by the Roku device to start this channel
sub Main()
    print chr(10) + "======================== CHANNEL STARTING =========================" + chr(10)

    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)
    scene = screen.CreateScene("MainScene")
    screen.show()

    while(true)
        msg = wait(0, m.port)
        ' print "msg: " + roToString(msg)
	    msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
end sub
