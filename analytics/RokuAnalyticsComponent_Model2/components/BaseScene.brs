' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********  
sub init()
    ?"------------------------------------------"
    ?
    ?"              Start new playback of video"
    ?
    ?"------------------------------------------"
    
    SetupAnalytics()
    
    SetupVideoPlayer()
End Sub

Sub SetupAnalytics()
    m.global.addField("RSG_analytics","node",false)
    m.global.RSG_analytics = CreateObject("roSGNode","Roku_Analytics:AnalyticsNode")
    'disables all debug prints, enable it in order to see which events are fired
    m.global.RSG_analytics.debug = true
    
    ' Analytics Initialization
    m.global.RSG_analytics.init = {
         
        'set data to IQ analytics
        Google : {
            trackingID : "UA-107042774-1"
            defaultParams : {
                an : "RokuAnalyticsClient"
            }
        }
        'set proper init values for Omniture analytics
        Omniture : {
            baseUrl : "http://test.com/"
            defaultParams : {
                sv         : "AnalyticNodeSample"
                v11        : "D=c11"
                c11        : "<TIME_PARTING_HOUR>"
                v12        : "D=c12"
                c12        : "<TIME_PARTING_DAY>"
                v14        : "D=c14"
                c14        : "D=User-Agent:Roku/3100X"'CreateObject("roDeviceInfo").GetModel()
                v55        : "D=c55"
                c55        : "no sponsor"
                v66        : "D=c66"
                c66        : "analytic_node_sample"
                ch         : "roku:analytic_node_sample"
            }
        }
        
    }

End Sub

Sub SetupVideoPlayer()
    m.Video = m.top.findNode("VideoPlayer")
    m.Video.observeField("state","onStateChange")
    m.Video.observeField("position","onPositionChange")
    m.Video.observeField("visible","onVisibleChange")
    m.Video.observeField("content","onContentChange")
    m.Video.observeField("streamInfo","onStreamInfoChange")
    m.Video.notificationInterval = 1

    'map of events that should be handled on state change
    m.statestToHandle = {
        "stopped" :""
        "playing":""
        "paused":""
        "error":""
        "finished":""
    }
    m.position = 0
End Sub

'This is triggered when we receive content from feed
Sub OnMainContent()
    
    if m.top.content <> invalid AND m.top.content.getChildCount() > 0
        m.Video.content = m.top.content.getChild(0)
        m.Video.setFocus(true)
        m.video.control = "play"
    end if
End Sub

sub onStateChange()
    ?"state:"m.Video.state
    if m.Video.content <> invalid AND m.statestToHandle[m.Video.state] <> invalid
        'we have a state that should be fired
        'store these states in map so you won't receive unhandled states or have string case sensitive issues
        state = m.Video.state
        
        'Convert video node state to proper GA event name
        GoogleEventAction = invalid
        if state = "playing" AND m.peviousestate = "paused"
            GoogleEventAction = "resume"
        else if state = "playing"
            GoogleEventAction = "progress"
        else if state = "finished"
            GoogleEventAction = "complete"
        else if state = "paused"
            GoogleEventAction = "pause"
        else if state = "stopped"
            GoogleEventAction = "complete"
        end if
        
        'Convert video node state to proper Omniture event name
        'you can have more than one parameter here
        OmnitureEvent = invalid
        if state = "playing" AND m.peviousestate = "paused"
            OmnitureEvent = "event94"
        else if state = "playing"
            OmnitureEvent = "event4,event71"
        else if state = "pause"
            OmnitureEvent = "event72"
        else if state = "finished" or state = "stopped"
            OmnitureEvent = "event5,event72"
        end if
        
        OmnitureParams = invalid
        if OmnitureEvent <> invalid
            OmnitureParams = {
                ev  : OmnitureEvent
                v3  : "D=c3"
                c3  : "VIDEO_TITLE+VIDEO_TYPE"
                v30 : "D=c30"
                c30 : "short-form"
                v31 : "D=c31"
                c31 : "VIDEO_Rating"
                v41 : "D=c41"
                c41 : "VIDEO_TITLE|TOTAL_DURATION"
                v44 : "D=c44"
                c44 : "VIDEO_ID"
                v47 : "D=c47"
                c47 : "VIDEO_SEONAME"
                v62 : "D=c62"
                c62 : "VIDEO_TYPE"
                v34 : "D=c34"
                c34 : "3100X"
                v33 : "D=c33"
                c33 : "US"
                v32 : "D=c32"
                c32 : "US"
                v48 : "D=c48"
                c48 : "SEASON"
                v49 : "D=c49"
                c49 : "EPISODE_NUMBER"
                v50 : "D=c50"
                c50 : "baseHost.com"
            }
        end if
        
        GoogleParams = invalid
        if GoogleEventAction <> invalid
            ni = invalid
            if GoogleEventAction = "complete" or GoogleEventAction = "progress"
                ni = "1"
            end if
            GoogleParams = {
                t : "event"
                ec : "video"
                ea : GoogleEventAction
                el : m.video.content.title
                ev : int(m.video.position).tostr()
                ni : ni
            }
        end if

        m.global.RSG_analytics.trackEvent = {
            Google      : GoogleParams
            Omniture    : OmnitureParams
        }
        
        m.peviousestate = state 
    
        if state = "error" or state = "finished"
            m.timer = CreateObject("roSgnode", "Timer")
            m.timer.observeField("fire","CloseVideoPlayer")
            m.timer.duration = 0.3
            m.timer.control = "start"
        end if
    end if
end sub

sub onPositionChange()
    if m.video.duration > 0 Then
        EventAction = "progress"
        
        'this is logic for seek events, this should be done here not in onkeyevent as it should only be send once per seek
        if m.video.content <> invalid AND  m.userHasSeeked = true
             m.userHasSeeked = false
            ?"send fast seek event"
            if int(m.video.position) < m.position 
                 EventAction = "rewind"
                 ev = "event28,event72"
            else
                 EventAction = "fast forward"
                 ev = "event28,event73"
            end if
            m.global.RSG_analytics.trackEvent = {
                Google : {
                    t : "event"
                    ec : "video"
                    ea : EventAction
                    el : m.video.content.title
                    ev : int(m.video.position).tostr()
                }
                Omniture : {
                    v3  : "D=c3"
                    c3  : "VIDEO_TITLE+VIDEO_TYPE"
                    v30 : "D=c30"
                    c30 : "short-form"
                    v31 : "D=c31"
                    c31 : "VIDEO_Rating"
                    v41 : "D=c41"
                    c41 : "VIDEO_TITLE|TOTAL_DURATION"
                    v44 : "D=c44"
                    c44 : "VIDEO_ID"
                    v47 : "D=c47"
                    c47 : "VIDEO_SEONAME"
                    v62 : "D=c62"
                    c62 : "VIDEO_TYPE"
                    v34 : "D=c34"
                    c34 : "3100X"
                    v33 : "D=c33"
                    c33 : "US"
                    v32 : "D=c32"
                    c32 : "US"
                    v48 : "D=c48"
                    c48 : "SEASON"
                    v49 : "D=c49"
                    c49 : "EPISODE_NUMBER"
                    v50 : "D=c50"
                    c50 : "baseHost.com"
                    ev : ev
                }
            }
        end if
        
        'calculate if it's quartal event
        quarts = m.video.duration / 4
        event = invalid
        If int(m.video.Position) = Int(quarts) Then
            event = "event26,event72"
        Else If int(m.video.Position) = Int(quarts * 2) Then
            event = "event27,event72"
        Else If int(m.video.Position) = Int(quarts * 3) Then
            event = "event28,event72"
        End If
        if event <> invalid
            ?"CustomVideo: quarts ["quarts"] event="event
            m.global.RSG_analytics.trackEvent = {
                Google : {
                    t : "event"
                    ec : "video"
                    ea : EventAction
                    el : m.video.content.title
                    ev : int(m.video.position).tostr()
                    ni : "1"
                }
                Omniture : {
                    v3  : "D=c3"
                    c3  : "VIDEO_TITLE+VIDEO_TYPE"
                    v30 : "D=c30"
                    c30 : "short-form"
                    v31 : "D=c31"
                    c31 : "VIDEO_Rating"
                    v41 : "D=c41"
                    c41 : "VIDEO_TITLE|TOTAL_DURATION"
                    v44 : "D=c44"
                    c44 : "VIDEO_ID"
                    v47 : "D=c47"
                    c47 : "VIDEO_SEONAME"
                    v62 : "D=c62"
                    c62 : "VIDEO_TYPE"
                    v34 : "D=c34"
                    c34 : "3100X"
                    v33 : "D=c33"
                    c33 : "US"
                    v32 : "D=c32"
                    c32 : "US"
                    v48 : "D=c48"
                    c48 : "SEASON"
                    v49 : "D=c49"
                    c49 : "EPISODE_NUMBER"
                    v50 : "D=c50"
                    c50 : "baseHost.com"
                    ev : event
                }
            }
        end if
    End If
    'store previous position so you can now if user really skipped video
    m.position = int(m.video.position)
end sub

sub onStreamInfoChange()
    if m.video.streamInfo.isResume 
       m.userHasSeeked = true
    end if
end sub

Sub CloseVideoPlayer()
    m.Video.visible = false
End Sub
