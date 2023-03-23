sub RunScreenSaver()
    screen = createObject("roSGScreen")
    port = createObject("roMessagePort")
    port2 = createObject("roMessagePort")
    screen.setMessagePort(port)

    m.global = screen.getGlobalNode()
    m.global.AddField("MyField", "int", true) 'Creates (Global) variable MyField
    m.global.MyField = 0
    m.global.AddField("PicSwap", "int", true) 'Creates (Global) variable PicSwap
    m.global.PicSwap = 0

    scene = screen.createScene("QuadrantScreensaver") 'Creates Scene QuadrantScreesaver
    screen.show()
    slideChange = 10

     while(true) 'Message Port that fires every 7 seconds to change value of MyField
        msg = wait(7000, port)
        if (msg <> invalid)
            msgType = type(msg)
            if msgType = "roSGScreenEvent"
                if msg.isScreenClosed() then return
            end if
        else
            slideChange += 10
            m.global.MyField = slideChange
            msg = wait(2100, port2) 'Message port that fires 2.1 seconds after MyField is changed. Has to be different port or it will interfere with other wait function.
            m.global.PicSwap += 10
        end if
    end while
end sub
