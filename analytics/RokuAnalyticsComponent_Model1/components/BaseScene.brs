' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********  

sub init()
    ? "------------------------------------------"
    ? " Start new playback of video"
    ? "------------------------------------------"
    
    SetupAnalytics()
    
    SetupVideoPlayer()
    
    m.global.RSG_analytics.InitVideoPlayer = {
        video: m.Video ' video is only one supported key here
    }
end sub

sub SetupAnalytics()
    m.global.addField("RSG_analytics", "node", false)
    m.global.RSG_analytics = CreateObject("roSGNode", "Roku_Analytics:AnalyticsNode")
    ' disables all debug prints, enable it in order to see which events are fired
    m.global.RSG_analytics.debug = true
    
    ' Analytics Initialization
    m.global.RSG_analytics.init = {
        ' set data to IQ analytics
        IQ: {
            ' this is mandatory parameter
            PCODE : "BmeGYyOpSplhQQLevgeb76wbvwXz"
            
            ' These params could be skipped, see Ooyula documentation for more info
            userInfo : {
                emailHashMD5: "dc250da0315f62bbb94ea5a2dff76755"
                userId:       "Alex"
                gender:       "M"
                ageGroup:     { min: 25, max: 30 }
            }

            geoInfo: {
                countryCode: "US"
                region:      "CA"
                city:        "SANTACLARA"
                latitude:    37.399092
                longitude:   -121.985771
                geoVendor:   "akamai"
            }
        }
    }
end sub

sub SetupVideoPlayer()
    m.Video = m.top.findNode("VideoPlayer")
    m.Video.observeField("state", "onStateChange")
    m.Video.observeField("position", "onPositionChange")
    m.Video.observeField("visible", "onVisibleChange")
    m.Video.observeField("content", "onContentChange")
    m.Video.notificationInterval = 1

    ' map of events that should be handled on state change
    m.statestToHandle = {
        finished: ""
        error:    ""
    }
end Sub

' This is triggered when we receive content from feed
sub OnMainContent()
    if m.top.content <> invalid and m.top.content.getChildCount() > 0
        m.Video.content = m.top.content.getChild(0)
        m.Video.setFocus(true)
        m.video.control = "play"
    end if
end sub

sub onStateChange()
    ? "state: " + m.Video.state
    if m.Video.content <> invalid AND m.statestToHandle[m.Video.state] <> invalid
        'This is 
        
        m.timer = CreateObject("roSgnode", "Timer")
        m.timer.observeField("fire", "CloseVideoPlayer")
        m.timer.duration = 0.3
        m.timer.control = "start"
    end if
end sub

sub CloseVideoPlayer()
    m.Video.visible = false
end sub

' This fucntion call setcontent for proper analytics
' if you are using analytics like Conviva, Comscore etc you have to implement this
sub onContentChange()
    if m.Video.content <> invalid
        metadata = {
            duration: m.Video.content.length
            assetId: m.Video.content.id
            assetType: "external"
        }
        m.global.RSG_analytics.SetContentMetadata = {
            content: m.Video.content ' set meta-data that can be used by all analytics
            IQ: metadata ' you can also use analytic specific fields here
        }
    end if
end sub

' handles closing of video node, clearing states and firing proper close events
sub onVisibleChange()
     if not m.Video.visible
        m.global.RSG_analytics.FinishedVideoPlayback = {
            video : m.Video  'video is only one supported key here
        }
    end if
end sub