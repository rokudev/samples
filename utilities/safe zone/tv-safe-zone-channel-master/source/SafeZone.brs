' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

Function SafeZone(scene as object)
        dev = createObject("roDeviceInfo")
        AA = dev.getDisplaySize()
        poster = createObject("roSGNode", "Poster")
        poster.height = AA.h
        poster.width = AA.w
        if poster.height = 1080 'if FHD
            poster.uri = "https://raw.githubusercontent.com/rokudev/safe-zone-channel/master/images/Outline-Safe-Zones-FHD.png"
        else
            poster.uri = "https://raw.githubusercontent.com/rokudev/safe-zone-channel/master/images/Outline-Roku-Safe-Zones-HD.png"
        end if
        scene.appendChild(poster)
End Function