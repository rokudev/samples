' ********** Copyright 2019 Roku Corp.  All Rights Reserved. ********** 

Sub Main()
    screen = CreateObject("roSGScreen")
    scene = screen.CreateScene("HomeScene")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    screen.Show()

    while true
        msg = wait(0, port)
        print "------------------"
        print "msg = "; msg
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
End Sub