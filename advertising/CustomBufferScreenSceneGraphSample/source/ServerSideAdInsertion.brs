' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 

'RAF implementation with Nielsen and ads being server stitched (Server-Side Ad Insertion)
' - Enable Nielsen.
' - Pass all parameters to Nielsen beacons with examples of genre, program id and content.
' - Use fireTrackingEvents() to pass ad structure with Nielsen beacons to RAF.
' - Nilsen APIs are updated for each content stream.
'@param videoContent [AA] object that has valid data for playing video with roVideoScreen.
Sub PlayContentWithServerSideAdInsertion()
    adIface = Roku_Ads() 'RAF initialize
    print "Roku_Ads library version: " + adIface.getLibVersion()

    adIface.setDebugOutput(true) 'for debug pupropse

    'RAF content params
    adIface.setContentId(m.videoContent.contentId)
    adIface.SetContentGenre(m.videoContent.contentGenre)
    
    'Nielsen content params
    adIface.enableNielsenDAR(true)
    adIface.setContentLength(m.videoContent.conntentLength)
    adIface.setNielsenProgramId(m.videoContent.nielsenProgramId)
    adIface.setNielsenGenre(m.videoContent.nielsenGenre)
    adIface.setNielsenAppId(m.videoContent.nielsenAppId)
   
    'Normally, would set publisher's ad URL here.
    'Otherwise uses default Roku ad server (with single preroll placeholder ad)
    adIface.setAdUrl(m.videoContent.adUrl)
    
    'Returns available ad pod(s) scheduled for rendering or invalid, if none are available.
    adPods = adIface.getAds()
    
    'initilaization
    m.loading.visible = false
    m.video.visible = true
    m.video.setFocus(true)
    m.video.control = "play"
    buffering = false
    curPos = 0
    ctx = {type : "Impression"}
    
    'adding fields of duration and render time to each ad 
    'in adPods data structure to ease processing of fireTracking  
    EvaluateRenderTime(adPods)
    
    while (true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msg.GetNode() = "MainVideo" then
             if msg.GetField() = "position" then
                    curPos = m.video.position
                    ctx = {type : "Custom"}
             else if msg.GetField() = "state" then
                curState = m.video.state
                if curState = "finished" then
                    ctx = {type : "Custom"}
                else if curState = "paused" then
                    ctx = {type : "Pause"}
                    buffering = false
                else if curState = "playing" then
                    if buffering then
                        'we don't send any beacons after
                        'resuming after buffering
                        ctx = {type : "None"}
                        buffering = false
                    else 
                        ctx = {type : "Resume"}
                    end if        
                else if curState = "buffering" then
                    ctx = {type : "None" }
                    buffering = true
                end if       
             else if msg.GetField() = "navBack" then
                 ctx = {type : "Close"}
                 m.video.control = "stop"
                 exit while
             end if       
        end if
        
        'parse all AdPods like: PreRolls, MidRolls, PostRolls
        'for handling all firetracking events in it
        for each adPod in AdPods
            if not adPod.viewed and  adPod.rendertime <= curPos then
                'parse all ads in current pod
                for each ad in adPod.ads
                    if not ad.viewed and ad.rendertime <= curPos then
                        
                        
                        if ctx.type = "Custom" then
                            'Custom case is triggered when isStreamStarted or isPlaybackPosition
                            'events occurs on VideoScreen 
                            
                            'evaluate moment of time for aproriate 
                            'fire tracking events    
                            Impression    = ad.rendertime
                            FirstQuartile = ad.rendertime + 0.25 * ad.duration
                            Midpoint      = ad.rendertime + 0.5  * ad.duration
                            ThirdQuartile = ad.rendertime + 0.75 * ad.duration
                            Complete      = ad.rendertime + 1    * ad.duration
                            
                            if curPos >= Impression and curPos < FirstQuartile and not ad.started then
                                ad.started = true
                                ctx = {type: "Impression"}
                            else if curPos >= FirstQuartile and curPos < Midpoint then
                                ctx = {type: "FirstQuartile"} 
                            else if curPos >= Midpoint and curPos < ThirdQuartile then
                                ctx = {type: "Midpoint"}
                            else if curPos >= ThirdQuartile and curPos < Complete then
                                ctx = {type: "ThirdQuartile"}
                            else if curPos >= Complete  then
                                ctx = {type: "Complete"}
                            end if
                            
                            if ctx.type <> "Custom" then
                                'firetrcakingevent call
                                adIface.fireTrackingEvents(ad, ctx)
                            end if
                        else 
                            'handles all other events from videoplayer like
                            'play, pause, stop, error etc excep from case of "Custom"
                            
                            'firetrcakingevent call
                            if ctx.type <> "None" then
                                adIface.fireTrackingEvents(ad, ctx)
                            end if        
                        end if
                        
                        print "   type = "; ctx.type
                        'check and if, then mark ad
                        'as viewed and trecked
                         ad.viewed = IsAdTracked(ad.tracking)
                    end if    
                end for
                'check and if then mark adPod 
                'as viewed and trecked
                adPod.viewed = IsAdPodTracked(adPod.ads) 
            end if
        end for'AdPods Parse loop
        
    end while'VideoScreen event loop
End Sub


'adding fields of duration and render time to each ad 
'in adPods data structure to ease processing of fireTracking
'@param adPods [A] array of adPod objects that has valid data of adPod returned from Raf by GetAds() function
sub EvaluateRenderTime(adPods as Object)
    for each adPod in adPods
        PodRenderTime = adPod.renderTime
        for i = 0 to adPod.ads.Count() - 1
            ad = adPod.ads[i]
            if i = 0 then
                'renderTime of first ad item is the same as in the whole AdPod
                ad.renderTime = PodRenderTime
            else 
                'render time of consequent ads is the total of 
                'duration and render timem of previous ad
                ad.renderTime = adPod.ads[i-1].renderTime + adPod.ads[i-1].duration 
            end if     
            'add flag viewed as in whole AdPod to each ad
            ad.viewed = false
            
            'needed for filtering fire tracking call
            'because fireTrackingEvent call always this track 
            'despite on trigerred flag
            ad.started = false
        end for
    end for
end sub


'checks is pod currently viewed
'by summarize all views of enclos ads
'@param ads [A] array of ads objects
function IsAdPodTracked(ads as object ) as Boolean 
    isAllTriggered = true
    for each ad in ads
        isAllTriggered = isAllTriggered and ad.viewed     
    end for    
    return isAllTriggered
end function

'checks is Ad tracked already
'@param trackingArray [A] array of tracking data structure that is in each ad
function IsAdTracked(trackingArray as Object ) as Boolean
    FinalTrackingEvents = {
        "complete" : true
        "error"    : true
        "close"    : true
        "skip"     : true
    }
    if tracking.triggered AND FinalTrackingEvents.doesExist(tracking.event) then return true
    
    return false
end function