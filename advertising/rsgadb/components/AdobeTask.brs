' ********** Copyright 2018 Roku, Inc.  All Rights Reserved. **********
Library "Roku_Ads.brs"

function init()
   '
   '  Following info must be provided
   '
   '   m.top.testConfig.url          :  bootstrap manifest server URL
   '   m.top.testConfig.trackingmode :  "xmkr" (using EXT-X-MARKER directive)  or "simple" (URL must include pttrackingmode=simple&pttrackingversion=v2 or vmap)
   '   m.top.testConfig.useStitched  :  true or false
   '
    m.top.adPlaying = false
    m.top.functionName = "runTask"
    m.useStitched = true
end function

function runTask()
    '
    '  1. Load and instanciate Adapter
    '
    adapter = loadAdapter()
    '
    '  2. Request preplay
    '
    loadStream(adapter)
    '
    '  3. Play content
    '
    runLoop(adapter)
end function

function loadAdapter() as object
    '   When not using RAF.stitchedAdHandledEvent(). App is responsible to call RAF.fireTrackingEvents()
    if invalid <> m.top.testConfig["useStitched"] and false = m.top.testConfig.useStitched then m.useStitched = false
    '
    '   1. Load and instanciate Adapter
    '
    adapter = RAFX_SSAI({name:"adobe",                             ' Required, "adobe"
                     trackingmode:m.top.testConfig.trackingmode}) ' Required, "xmkr" or "simple"
    if adapter <> invalid
        adapter.init()
        print "RAFX_SSAI version ";adapter["__version__"]
    end if
    return adapter
end function

function loadStream(adapter as object) as void
    if invalid = adapter then return
    '
    '  2.1 Compose request info
    '
    request = {
        url:  m.top.testConfig.url,  ' Required, masterURL
        kbps: 3000                   ' Required  when trackingmode:simple,  max kbps to select URL from multiple bit rate streams.
    }
    requestResult = adapter.requestStream(request) ' Required
    if requestResult["error"] <> invalid
        print "Error requesting stream ";requestResult
    else
        '
        '  2.2  Get stream info returned from manifest server
        '
        streamInfo = adapter.getStreamInfo()
        if streamInfo = invalid or streamInfo["error"] <> invalid
            print "error "; streamInfo
        else
            '
            '  2.3  Configure video node
            '
            vidContent = createObject("RoSGNode", "ContentNode")
            vidContent.url = streamInfo.playURL
            '   When trackingmode:simple,  playURL is selected bitrate stream
            '   When trackingmode:xmkr,    playURL is equal to masterURL
            vidContent.title = m.top.testConfig.title
            vidContent.streamformat = "hls"
            m.top.video.content = vidContent
            m.top.video.setFocus(true)
            m.top.video.visible = true
            m.top.video.EnableCookies()
        end if
        '
        '   2.4  other RAF settings
        '
        adIface = Roku_Ads()
        adIface.enableAdMeasurements(true) ' Required
        ' adIface.setContentLength()    ' Set app/content specific info
        ' adIface.setNielsenProgramId() ' Set app/content specific info
        ' adIface.setNielsenGenre()     ' Set app/content specific info
        ' adIface.setNielsenAppId()     ' Set app/content specific info
        ' adIface.setDebugOutput(true)
    end if
end function

function runLoop(adapter as object) as void
    if invalid = adapter then return
    ' 
    '   3.1  Enable adapter Ad tracking
    ' 
    port = CreateObject("roMessagePort")
    adapter.enableAds({player:{sgnode:m.top.video, port:port}, ' Required
                       useStitched : m.useStitched   ' Optional, default is true
                     })
    '
    '   3.2  set callbacks (optional)
    '
    addCallbacks(adapter) ' optional
    '
    '   3.3  Observe video node
    '
    m.top.video.observeFieldScoped("position", port)
    m.top.video.observeFieldScoped("control", port)
    m.top.video.observeFieldScoped("state", port)
    '
    '   3.4  Start playback
    '
    m.top.video.control = "play"
    while true
        msg = wait(1000, port)
        if type(msg) = "roSGNodeEvent" and msg.getField() = "control" and msg.getNode() = m.top.video.id and not m.top.adPlaying and (msg.getData() = "stop" or msg.getData() = "done") or m.top.video = invalid
            exit while ' video node stopped. quit loop
        end if
        '
        '  3.5  Have adapter handle events
        '
        curAd = adapter.onMessage(msg) ' Required
        if "roSGNodeEvent" = type(msg) and "state" = msg.getField() and "finished" = msg.getData() and msg.getNode() = m.top.video.id then
            exit while ' stream ended. quit loop
        end if
    end while
    m.top.video.unobserveFieldScoped("position")
    m.top.video.unobserveFieldScoped("control")
    m.top.video.unobserveFieldScoped("state")
end function

function addCallbacks(adapter) as Void
    adapter.addEventListener(adapter.AdEvent.PODS, podsCallback)
    adapter.addEventListener(adapter.AdEvent.POD_START, podStartCallback)
    adapter.addEventListener(adapter.AdEvent.IMPRESSION, adEventCallback)
    adapter.addEventListener(adapter.AdEvent.FIRST_QUARTILE, adEventCallback)
    adapter.addEventListener(adapter.AdEvent.MIDPOINT, adEventCallback)
    adapter.addEventListener(adapter.AdEvent.THIRD_QUARTILE, adEventCallback)
    adapter.addEventListener(adapter.AdEvent.COMPLETE, adEventCallback)
    adapter.addEventListener(adapter.AdEvent.POD_END, podEndCallback)
    '
    m.adPod = invalid
    m.adIndex = 0
    m.COMPLETE = adapter.AdEvent.COMPLETE
end function

function podsCallback(podsInfo as Object)
    adPods = podsInfo["adPods"] ' New list of adPods found
    print " Pod count: ";adPods.count()
    for each adPod in adPods
        print "   RenderTime: ";adPod.renderTime;"   Ad count: ";adPod.ads.count()
    end for
end function
function podStartCallback(podInfo as Object)
    print "At ";podInfo.position;" from Adapter -- " ; podInfo.event
    if not m.top.adPlaying
        m.top.adPlaying = True
        m.top.video.enableTrickPlay = false
    end if
    if not m.useStitched
        m.adPod = podInfo["adPod"]
        if invalid <> m.adPod
            adIface = Roku_Ads()
            ' fire Pod pixel
            adIface.fireTrackingEvents(m.adPod, {type: podInfo.event}) ' Required
            m.adIndex = 0
        end if
    end if
end function
function adEventCallback(adInfo as Object) as Void
    print "At ";adInfo.position;" from Adapter -- " ; adInfo.event
    if invalid <> m.adPod and m.adIndex < m.adPod.ads.count()
        adIface = Roku_Ads()
        ' fire Ad pixel
        ad = m.adPod.ads[m.adIndex]
        adIface.fireTrackingEvents(ad, {type: adInfo.event}) ' Required
        if m.COMPLETE = adInfo.event
            m.adIndex += 1
        end if
    end if
end function
function podEndCallback(podInfo as Object)
    print "At ";podInfo.position;" from Adapter -- " ; podInfo.event
    m.top.adPlaying = False
    m.top.video.enableTrickPlay = true
    m.top.video.setFocus(true)
    if invalid <> m.adPod
        adIface = Roku_Ads()
        ' fire Pod pixel
        adIface.fireTrackingEvents(m.adPod, {type: podInfo.event}) ' Required
        m.adIndex = 0
    end if
    m.adPod = invalid
end function
