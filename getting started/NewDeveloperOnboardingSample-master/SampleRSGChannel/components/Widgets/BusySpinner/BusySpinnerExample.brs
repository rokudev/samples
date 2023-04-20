' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
'
' We will initialize the BusySpinner object by setting the image that will
' act as the loading indicator and having a callback function when the
' image is ready/loaded.
sub init()
    m.busyspinner = m.top.findNode("exampleBusySpinner")
    m.busyspinner.poster.observeField("loadStatus", "showspinner")
    m.busyspinner.poster.uri = "pkg:/images/busyspinner_hd.png"
end sub

' This callback function checks if the BusySpinner's poster is ready/loaded.
' If it is loaded, this function translates the BusySpinner object until it is
' centered and sets the BusySpinner object to be visible on-screen.
sub showspinner()
    if(m.busyspinner.poster.loadStatus = "ready")
        centerx = (1280 - m.busyspinner.poster.bitmapWidth) / 2
        centery = (720 - m.busyspinner.poster.bitmapHeight) / 2
        m.busyspinner.translation = [ centerx, centery ]

        m.busyspinner.visible = true
    end if
end sub