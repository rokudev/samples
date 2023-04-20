' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub RunUserInterface(args)
    m.args = args
    if Type(GetSceneName) <> "<uninitialized>" AND GetSceneName <> invalid AND GetInterface(GetSceneName, "ifFunction") <> invalid then
        StartSGDEXChannel(GetSceneName(), args)
    else
        ? "Error: SGDEX, please implement 'GetSceneName() as String' function and return name of your scene that is extended from BaseScene"
    end if
end sub

sub StartSGDEXChannel(componentName, args)
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.SetMessagePort(m.port)
    scene = screen.CreateScene(componentName)
    screen.Show()
    scene.ObserveField("exitChannel", m.port)
    scene.launch_args = args
    while (true)
        msg = Wait(0, m.port)
        msgType = Type(msg)
        if msgType = "roSGScreenEvent"
            if msg.IsScreenClosed() then return
        else if msgType = "roSGNodeEvent"
            field = msg.getField()
            data = msg.getData()
            if field = "exitChannel" and data = true
                END
            end if
        end if
    end while
end sub
