'*********************************************************************
'** (c) 2016-2017 Roku, Inc.  All content herein is protected by U.S.
'** copyright and other applicable intellectual property laws and may
'** not be copied without the express permission of Roku, Inc., which
'** reserves all rights.  Reuse of any of this content for any purpose
'** without the permission of Roku, Inc. is strictly prohibited.
'********************************************************************* 

Library "Roku_Ads.brs"

sub init()
    m.top.functionName = "playContentWithAds" 
    m.top.id = "PlayerTask"
end sub

sub playContentWithAds()
   
    video = m.top.video
    ' `view` is the node under which RAF should display its UI (passed as 3rd argument of showAds())
    view = video.getParent() 

    RAF = Roku_Ads()
    'RAF.clearAdBufferScreenLayers()        ' in case it was set earlier
    'RAF.enableAdBufferMessaging(true, true) ' could have been cleared by custom screen
    'RAF.setAdBufferScreenContent({})

    content = video.content
    RAF.setAdUrl(content.ad_url)
    ' for generic measurements api
    RAF.enableAdMeasurements(true)
    RAF.setContentGenre(content.categories)  'if unset, ContentNode has it as []
    RAF.setContentLength(content.length)

    ' log tracking events
'     logObj = {
'         log : Function(evtType = invalid as Dynamic, ctx = invalid as Dynamic)
'                   if GetInterface(evtType, "ifString") <> invalid
'                       print "*** tracking event " + evtType + " fired."
'                       if ctx.companion = true then
'                           print "***** companion = true"
'                       end if
'                       if ctx.errMsg <> invalid then print "*****   Error message: " + ctx.errMsg
'                       if ctx.adIndex <> invalid then print "*****  Ad Index: " + ctx.adIndex.ToStr()
'                       if ctx.ad <> invalid and ctx.ad.adTitle <> invalid then print "*****  Ad Title: " + ctx.ad.adTitle
'                   else if ctx <> invalid and ctx.time <> invalid
'                       print "*** checking tracking events for ad progress: " + ctx.time.ToStr()
'                   end if
'               End Function
'     }
'     logFunc = Function(obj = Invalid as Dynamic, evtType = invalid as Dynamic, ctx = invalid as Dynamic)
'                   obj.log(evtType, ctx)
'               End Function
'     RAF.setTrackingCallback(logFunc, logObj)

    adPods = RAF.getAds() 'array of ad pods
    keepPlaying = true 'gets set to `false` when showAds() was exited via Back button

    ' show the pre-roll ads, if any
    if adPods <> invalid and adPods.count() > 0
       keepPlaying = RAF.showAds(adPods, invalid, view)
    end if

    port = CreateObject("roMessagePort")
    if keepPlaying then
        video.observeField("position", port)
        video.observeField("state", port)
        video.visible = true
        video.control = "play"
        video.setFocus(true) 'so we can handle a Back key interruption
    end if

    curPos = 0
    adPods = invalid
    isPlayingPostroll = false
    while keepPlaying
        msg = wait(0, port)
        if type(msg) = "roSGNodeEvent"
            if msg.GetField() = "position" then
                ' keep track of where we reached in content
                curPos = msg.GetData() 
                ' check for mid-roll ads
                adPods = RAF.getAds(msg)
                if adPods <> invalid and adPods.count() > 0
                    print "PlayerTask: mid-roll ads, stopping video"
                    'ask the video to stop - the rest is handled in the state=stopped event below
                    video.control = "stop"  
                end if
            else if msg.GetField() = "state" then
                curState = msg.GetData()
                print "PlayerTask: state = "; curState
                if curState = "stopped" then
                    if adPods = invalid or adPods.count() = 0 then 
                        exit while
                    end if

                    print "PlayerTask: playing midroll/postroll ads"
                    keepPlaying = RAF.showAds(adPods, invalid, view)
                    adPods = invalid
                    if isPlayingPostroll then 
                        exit while
                    end if
                    if keepPlaying then
                        print "PlayerTask: mid-roll finished, seek to "; stri(curPos)
                        video.visible = true
                        video.seek = curPos
                        video.control = "play"
                        video.setFocus(true) 'important: take the focus back (RAF took it above)
                    end if
                        
                else if curState = "finished" then
                    print "PlayerTask: main content finished"
                    ' render post-roll ads
                    adPods = RAF.getAds(msg)
                    if adPods = invalid or adPods.count() = 0 then 
                        exit while
                    end if
                    print "PlayerTask: has postroll ads"
                    isPlayingPostroll = true
                    ' stop the video, the post-roll would show when the state changes to  "stopped" (above)
                    video.control = "stop"
                end if
            end if
        end if
    end while

    print "PlayerTask: exiting playContentWithAds()"
end sub
