sub RunScreenSaver()
    screen = createObject("roSGScreen") 'Creates screen to display screensaver
    port = createObject("roMessagePort") 'Port to listen to events on screen
    screen.setMessagePort(port)

    scene = screen.createScene("AnimatedScreensaver") 'Creates scene to display on screen. Scene name (AnimatedScreensaver) must match ID of XML Scene Component
    screen.show()

    while(true) 'Uses message port to listen if channel is closed
        msg = wait(0, port)
        if (msg <> invalid)
            msgType = type(msg)
            if msgType = "roSGScreenEvent"
                if msg.isScreenClosed() then return
            end if
        end if
    end while
end sub
