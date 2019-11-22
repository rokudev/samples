'********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

sub main()
    screen = CreateObject("roSGScreen") 'Create SceneGraph screen
    m.port = CreateObject("roMessagePort") 'Create message port to listen for screen events
    screen.setMessagePort(m.port)
    m.scene = screen.CreateScene("Mainscene") 'Sets main scene to be SimpleCaptionsScene
    screen.show() 'Show screen

    while(true) 'This loop constantly listens for a screen close message so that it will stop the app.
      msg = wait(0, m.port)
	    msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
end sub
