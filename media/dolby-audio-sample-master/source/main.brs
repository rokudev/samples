' ********** Copyright 2016 Roku Inc.  All Rights Reserved. **********

Sub Main()
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)

    m.global = screen.getGlobalNode()
    m.global.addField("Options", "int", true)
    m.global.Options = 1

    scene = screen.CreateScene("HomeScene")
    screen.show()

    m.RowList = scene.findNode("RowList")
    m.RowList.observeField("rowItemSelected", m.port)

    m.Video = scene.findNode("Video")

    while(true)
        msg = wait(0, m.port)
	      msgType = type(msg)
        if msgType = "roSGScreenEvent"
            print msg
            if msg.isScreenClosed() then return
        end if
    end while
End Sub
