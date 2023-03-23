Function RunScreenSaver( params As Object ) As Object
    showChannelSGScreen()
End Function

sub Main()
    print "in showChannelSGScreen"
    screen = CreateObject("roSGScreen")
    print "Created SGScreen ";screen

    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)

    newID = "global"+Stri( Rnd(10000) )
    print "New ID should be ";newID

    glb = screen.getGlobalNode()
    glb.id = newID
    
    glb.AddField("TestField", "int", true)
    glb.TestField = 100

    glb.observeField("TestField", m.port)

    print "Global in Screen ";glb
    print "Local global ";m.global

    scene = screen.CreateScene("BlueRectangleScene")
    screen.show()

    scene.animControl = "start"

    color = 10

    while(true)
        msg = wait(2000, m.port)
        if (msg <> invalid)
            msgType = type(msg)
            if msgType = "roSGScreenEvent"
                if msg.isScreenClosed() then return
            else if msgType = "roSGNodeEvent"
                print glb.id;": message ";msg.GetData()
	        end if
        else
            color += 60
            print "Set color to ";glb.id
            glb.TestField = color
        end if
    end while
end sub
