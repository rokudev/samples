'********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

sub Main()
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)

    m.global = screen.getGlobalNode()
    m.global.addField("version", "string", false)
    m.global.version = getOSVersion()    ' format OS major + minor + build, e.g 11.5.4312
    print "version: " m.global.version

    scene = screen.CreateScene("MainScene")
    screen.show()
    scene.observeField("exitApp", m.port)

    while(true)
        msg = wait(0, m.port)
	    msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        else if msgType = "roSGNodeEvent" then
          print "got roSGNodeEvent"
          field = msg.getField()
          if field = "exitApp" then
            return
          end if
        end if
    end while
end sub

Function getOsVersion() as string
  version = createObject("roDeviceInfo").GetOSVersion()

  major = version.major
  minor = version.minor
  build = version.build

  return major + "." + minor + "." + build
end Function
