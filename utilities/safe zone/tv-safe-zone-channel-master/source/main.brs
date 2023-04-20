sub main()  
    screen = createObject("roSGScreen") 
    port = createObject("roMessagePort")
    screen.setMessagePort(port)
    
    m.global = screen.getGlobalNode()
    m.global.addField("Height", "int", true)
    m.global.Height = 0
    m.global.addField("Width", "int", true)
    m.global.Width = 0
    
    di = createObject("roDeviceInfo")
    AA = di.getDisplaySize()
    
    m.global.Height = AA.h
    m.global.Width = AA.w
    
    scene = screen.createScene("HomeScene")
    screen.show()
    SafeZone(scene) 'Add safe zone transparent overlay
    
    
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

