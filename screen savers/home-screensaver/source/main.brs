Sub RunScreenSaver()
    screen = createObject("roSGScreen")
    m.port = createObject("roMessagePort")
    ipaddr = GetIPAddress()
    screen.setMessagePort(m.port)

    m.global = screen.getGlobalNode()
    m.global.AddField("MyField", "int", true) '(Global) Sets off message to change picture in XML
    m.global.MyField = 0
    m.global.AddField("channels","stringarray",true) '(Global) array of channel paths to artwork
    m.global.channels = GetChannels(screen, ipaddr)

    scene = screen.createScene("HomeScreensaver") 'Create Scene called HomeScreensaver
    screen.Show()

    while(true) 'While loop that fires every 8 seconds to change (Global) MyField value. It also checks to see if app is closed
        msg = wait(8000, m.port)
        if (msg <> invalid)
            msgType = type(msg)
            if msgType = "roSGScreenEvent"
                if msg.isScreenClosed() then return
            end if
        else
            m.global.MyField = m.global.MyField + 1
        end if
    end while

end sub

Function GetIPAddress() as String    'Retrieves IP Address of Roku Device
    di = CreateObject("roDeviceInfo")
    ipAddrs = di.GetIPAddrs()
    for each eth in ipAddrs
        if (ipAddrs[eth] <> invalid)
            ipAddr = ipAddrs[eth]
            exit for
        end if
    end for
    return ipaddr
End Function

Function GetChannels(screen as object, ipaddr as String) as object 'Retrives artwork of home screen channels and returns an array with all artwork
    channels = []

    http = CreateObject("roUrlTransfer")
    port = CreateObject("roMessagePort")
    http.SetMessagePort(port)

    url = "http://" + ipaddr + ":8060/query/apps" 'This URL will query home screen channel artwork based off IP of the Roku
    http.SetUrl(url)

    if (http.AsyncGetToString())
        while (true) 'Parse through XMl to grab correct URI paths
            msg = port.GetMessage()
            if (msg <> invalid) and (type(msg) = "roUrlEvent")
                code = msg.GetResponseCode()
                if (code = 200)
                    xml = CreateObject("roXMLElement")
                    xml.Parse(msg.GetString())
                    exit while
                endif
                print stri(code)
                print msg.GetFailureReason()
            endif
        end while
        index = 0
        for each app in xml.app
            name = app.GetText()
            attributes = app.GetAttributes()
            id = attributes["id"]
            channeltype = attributes["type"]
            if channeltype = "appl" 'Only adds artwork of installed applications
                channels.push("http://" + ipaddr + ":8060/query/icon/" + id)
            end if
        end for
    endif
    return channels
End Function
