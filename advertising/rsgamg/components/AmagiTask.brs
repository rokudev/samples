' ********** Copyright 2020 Roku, Inc.  All Rights Reserved. **********
Library "Roku_Ads.brs"

function init()
   '
   '  Following info must be provided
   '
   '   m.top.testConfig.url          :  bootstrap manifest server URL
   '
    m.top.adPlaying = false
    m.top.functionName = "runTask"
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
    '  Amagi adapter does not support RAF.stitchedAdHandledEvent()
    '  App is responsible to call RAF.fireTrackingEvents()

    '
    '   1. Load and instanciate Adapter
    '
    adapter = RAFX_SSAI({name:"amagi"})     ' Required, "amagi"
    if adapter <> invalid
        adapter.init()
        print "RAFX_SSAI version ";adapter["__version__"]
    end if
    return adapter
end function

function replaceURLParams(url) as String
    devInfo = CreateObject("roDeviceInfo")
    displaySize = devInfo.GetDisplaySize()
    url = url.replace("DEVICE_ID", devInfo.GetChannelClientId())
    url = url.replace("UI_WIDTH", displaySize.w.ToStr())
    url = url.replace("UI_HEIGHT", displaySize.h.ToStr())
    url = url.replace("USER_IP", devInfo.GetExternalIp())
    url = url.replace("ROKU_ADS_TRACKING_ID", devInfo.getRIDA())
    url = url.replace("ROKU_ADS_DEVICE_MODEL", devInfo.GetModel())
    url = url.replace("ROKU_ADS_APP_ID", devInfo.GetChannelClientId())
    url = url.replace("ROKU_ADS_LIMIT_TRACKING", devInfo.IsRIDADisabled().ToStr())
    return url
end function

function loadStream(adapter as object) as void
    if invalid = adapter then return
    '
    '  2.1 Compose stream info and set to adapter
    '
    strmInfo = {
        url:  replaceURLParams(m.top.testConfig.url),  ' Required, masterURL
    }
    adapter.setStreamInfo(strmInfo) ' Required

    '
    '  2.3  Configure video node
    '
    vidContent = createObject("RoSGNode", "ContentNode")
    vidContent.url = strmInfo.url
    vidContent.title = m.top.testConfig.title
    vidContent.streamformat = "hls"
    video = m.top.video
    video.content = vidContent
    video.setFocus(true)
    video.visible = true
    video.EnableCookies()

    '
    '   2.4  other RAF settings
    '
    adIface = Roku_Ads()
    adIface.enableAdMeasurements(true) ' Required
    ' adIface.setContentLength()    ' Set app/content specific info
    ' adIface.setContentGenre()     ' Set app/content specific info
    ' adIface.setNielsenProgramId() ' Set app/content specific info
    ' adIface.setNielsenGenre()     ' Set app/content specific info
    ' adIface.setNielsenAppId()     ' Set app/content specific info
    ' adIface.setDebugOutput(true)
end function

function runLoop(adapter as object) as void
    if invalid = adapter then return
    video = m.top.video
    ' 
    '   3.1  Enable adapter Ad tracking
    ' 
    port = CreateObject("roMessagePort")
    adapter.enableAds({player:{sgnode:video, port:port}, useStitched:true}) ' Required
    '
    '   3.2  set callbacks, required
    '
    addCallbacks(adapter)
    '
    '   3.3  Observe video node
    '
    video.observeFieldScoped("position", port)
    video.observeFieldScoped("control", port)
    video.observeFieldScoped("state", port)
    '
    '   3.4  Start playback
    '
    video.control = "play"
    while true
        msg = wait(1000, port)
        if type(msg) = "roSGNodeEvent" and msg.getField() = "control" and msg.getNode() = video.id and not m.top.adPlaying and (msg.getData() = "stop" or msg.getData() = "done") or video = invalid
            exit while ' video node stopped. quit loop
        end if
        '
        '  3.5  Have adapter handle events messages
        '
        curAd = adapter.onMessage(msg) ' Required
        if "roSGNodeEvent" = type(msg) and "state" = msg.getField() and "finished" = msg.getData() and msg.getNode() = video.id then
            exit while ' stream ended. quit loop
        end if
    end while
    video.unobserveFieldScoped("position")
    video.unobserveFieldScoped("control")
    video.unobserveFieldScoped("state")
end function

function addCallbacks(adapter) as Void
    '
    '  Setting callbacks required
    '
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

function podStartCallback(podInfo as Object)
    print "At ";podInfo.position;" from Adapter -- " ; podInfo.event
    if not m.top.adPlaying
        m.top.adPlaying = True
    end if
    m.adPod = podInfo["adPod"]
    if invalid <> m.adPod
        adIface = Roku_Ads()
        ' fire Pod pixel
        adIface.fireTrackingEvents(m.adPod, {type: podInfo.event}) ' Required
        m.adIndex = 0
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
    if invalid <> m.adPod
        adIface = Roku_Ads()
        ' fire Pod pixel
        adIface.fireTrackingEvents(m.adPod, {type: podInfo.event}) ' Required
        m.adIndex = 0
    end if
    m.adPod = invalid
end function
