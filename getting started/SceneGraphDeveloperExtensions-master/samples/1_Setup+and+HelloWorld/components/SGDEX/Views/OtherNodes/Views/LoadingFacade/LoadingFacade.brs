' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub Init()
    deviceInfo = CreateObject("roDeviceInfo")
    displaySize = deviceInfo.GetDisplaySize()

    busySpinner = m.top.CreateChild("BusySpinner")
    busySpinner.poster.uri = "pkg:/components/SGDEX/Images/loader.png"
    busySpinner.translation = [587, 308]

    m.top.busySpinner = busySpinner
end sub


function onKeyEvent(key as String, press as Boolean) as boolean
    return m.top.bEatKeyEvents
end function
