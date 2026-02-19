' ********** Copyright 2018 Roku, Inc.  All Rights Reserved. ********** 
Library "Roku_Ads.brs"

function init()
   '
   '  Following info must be provided
   '
   '   m.top.testConfig.url      :  request URL (Live streaming using Ping method)  or  Preplay URL (on-demand)
   '   m.top.testConfig.type     :  "live" (Live streaming using Ping method)  or "vod" (on-demand)
   '   m.top.testConfig.useStitched   :  true or false
   '
    m.top.adPlaying = False
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
    '  not calling RAF.stitchedAdHandledEvent(). App is responsible to call RAF.fireTrackingEvents()
    if invalid <> m.top.testConfig["useStitched"] and false = m.top.testConfig.useStitched then m.useStitched = false
    '
    '  1. Load and instanciate Adapter
    '
    adapter = RAFX_SSAI({name:"uplynk"}) ' Required, "uplynk"
    if adapter <> invalid
        adapter.init() ' Required
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
        url:  m.top.testConfig.url,   ' Required, mediaURL, .json
        type: adapter.StreamType.VOD, ' Required, VOD or LIVE
        timeoutsec: 15  ' Optional, Uplynk may take long time to respond. Wait for up to this seconds
    }
    if m.top.testConfig.type = "live" then request["type"] = adapter.StreamType.LIVE
    requestResult = adapter.requestStream(request) ' Required, requesting Ad Metadata
    if requestResult["error"] <> invalid
        print "Error requesting stream ";requestResult
    else
        '
        '  2.2  Get stream info returned from Uplynk server
        '
        streamInfo = adapter.getStreamInfo() ' Required
        if streamInfo = invalid or streamInfo["error"] <> invalid
            print "error "; streamInfo
        else
            '
            '  2.3  Configure video node
            '
            vidContent = createObject("RoSGNode", "ContentNode")
            vidContent.url = streamInfo.playURL  ' returned from Uplynk server
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
    '   3.1  set callbacks
    '
    addCallbacks(adapter) ' Required when not using RAF.stitchedAdHandledEvent()
    ' 
    '   3.1  Enable adapter Ad tracking
    ' 
    port = CreateObject("roMessagePort")
    '
    '  Option:  RAFX_SSAI() adapter provides options to use RAF
    '    A. use RAF (default)
    '       When AdPod found, calls stitchedAdsInit()
    '       When msg, calls stitchedAdHandledEvent()
    '       this option allows both video and interactive ads rendered by RAF
    '    B. no RAF.stitchedAd call
    '       App is responsible to fire pixel via RAF.fireTrackingEvents()
    '       See callback functions in this sample
    '
    adapter.enableAds({player:{sgnode:m.top.video, port:port}, ' Required
                       useStitched : m.useStitched  ' Optional, default is true
                     })
    '
    '   3.3  Observe video node
    '
    m.top.video.observeFieldScoped("position", port) ' Required
    m.top.video.observeFieldScoped("control", port)
    m.top.video.observeFieldScoped("state", port)
    '
    '   3.4  Start playback
    '
    m.top.video.control = "play"
    while true
        msg = wait(1000, port)
        if type(msg) = "roSGNodeEvent" and msg.getField() = "control" and msg.getNode() = m.top.video.id and not m.top.adPlaying and msg.getData() = "stop" or m.top.video = invalid
            exit while ' video node stopped. quit loop
        end if
        '
        '  3.5  Have adapter handle events
        '
        currentTime = m.top.video.position
        curAd = adapter.onMessage(msg) ' Required
        if "roSGNodeEvent" = type(msg) and "state" = msg.getField() and "finished" = msg.getData() and msg.getNode() = m.top.video.id then
            exit while ' stream ended. quit loop
        end if
    end while
    m.top.video.unobserveFieldScoped("position")
    m.top.video.unobserveFieldScoped("control")
    m.top.video.unobserveFieldScoped("state")
end function

'
'   Required, Configure callback functions when NOT using RAF.stitchedAdHandledEvent()
'
function addCallbacks(adapter) as void
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
        print "     Ad count: ";adPod.ads.count(); "  renderTime: ";adPod.renderTime; "  endTime: ";adPod.renderTime+adPod.duration
    end for
end function
function podStartCallback(podInfo as Object)
    if not m.top.adPlaying
        m.top.adPlaying = True
        m.top.video.enableTrickPlay = false
    end if
    if not m.useStitched
        m.adPod = podInfo["adPod"]
        if invalid <> m.adPod
            print "  Pod adCount: ";podInfo["adPod"].ads.count()
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
