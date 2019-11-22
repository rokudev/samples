' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 

' A RAF implementation for non-standard ad responses (neither VMAP, VAST or SMartXML)
' - Custom Parsing of ad response to create the ad structure.
' - importAds().
' - showAds() for rendering.
Sub PlayContentWithNonStandardRAFIntegration()
    ' configure RAF
    raf = Roku_Ads()            'init RAF library instance
    raf.setAdPrefs(false)       'disable back-filled ads
    raf.setDebugOutput(true)    'debug console (port 8085) extra output ON
     
    ' import custom parsed ad pods array
    if m.videoContent <> invalid AND m.videoContent.nonStandardAdsFilePath <> invalid
        raf.importAds(GetNonStandardAds(m.videoContent.nonStandardAdsFilePath))
    end if
    
    ' clear "Loading" text
    m.loading.visible = false
    
    ' process preroll ads
    adPods = raf.getAds(createPlayPosMsg(0, false, true))
    if adPods <> invalid AND adPods.Count() > 0
        ' got preroll ads, render with RAF and get result if to continue playback
        bContinue = raf.showAds(adPods)
        if not bContinue
            return
        end if
    end if
    
    ' start playback for video
    m.video.visible = true
    m.video.setFocus(true)
    m.video.control = "play"
        
    ' event-loop
    while true
        msg = Wait(500, m.port)
        msgType = type(msg)
        
        if msgType = "roSGScreenEvent" AND msg.isScreenClosed()
            exit while
        else if msgType = "roSGNodeEvent" AND msg.GetNode() = "MainVideo"
            field = msg.GetField()
            
            if field = "position"
                ' check for midroll ads
                curPos = m.video.position
                adPods = raf.getAds(createPlayPosMsg(curPos))
                if adPods <> invalid AND adPods.Count() > 0
                    ' got some ads, stop video playback
                    m.video.control = "stop"
                    ' render ads with RAF and get result if to continue playback
                    bContinue = raf.showAds(adPods)
                    if bContinue
                        ' restore playback for video
                        m.video.seek = curPos
                        m.video.control = "play"
                    else
                        exit while
                    end if
                end if
            else if field = "state"
                curState = m.video.state
                if curState = "finished"
                    ' render postroll ads
                    adPods = raf.getAds(createPlayPosMsg(curPos, true))
                    m.video.control = "stop"
                    if adPods <> invalid AND adPods.Count() > 0
                        raf.showAds(adPods)
                    end if
                    exit while
                end if
            else if field = "navBack" AND msg.GetData() = true  'back button handling
                m.video.control = "stop"
                exit while
            end if
        end if
    end while
End Sub


' Gets and parses ad pods array from non-standard JSON feed stored in file
' @param filePath [String] path to the file containing JSON ads feed
' @return [Object] ad pods as roArray to import into RAF
function GetNonStandardAds(filePath as String) as Object
    feed = ReadAsciiFile(filePath)

    result = ParseJson(feed)
    if type(result) <> "roArray"
        return []
    end if
    
    ' parse ad pods in array according to the format accepted by RAF adding missing fields/values
    for each adPod in result
        if adPod <> invalid AND adPod.ads <> invalid
            adPod.duration = 0
            adPod.viewed = false
            
            for each ad in adPod.ads
                if ad <> invalid
                    if ad.adServer = invalid
                        ad.adServer = ""
                    end if
                    
                    if ad.duration = invalid
                        ad.duration = 0
                    end if
                    
                    if ad.duration > 0
                        adPod.duration = adPod.duration + ad.duration
                    end if
                    
                    if type(ad.tracking) = "roArray"
                        for each adBeacon in ad.tracking
                            if adBeacon <> invalid
                                adBeacon.triggered = false
                            end if 
                        end for
                    end if
                end if
            end for
        end if
    end for
    
    return result
end function
