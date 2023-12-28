' ********** Copyright 2017 Roku, Inc.  All Rights Reserved. ********** 
function Main()
    screen = createObject("roSGScreen")
    m.port = createObject("roMessagePort")
    screen.setMessagePort(m.port)
    m.scene = screen.createScene("MainScene")
    screen.show()

    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return true
        end if
    end while
end function
