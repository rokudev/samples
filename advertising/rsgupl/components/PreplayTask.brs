' ********** Copyright 2018 Roku, Inc.  All Rights Reserved. ********** 
Library "Roku_Ads.brs"

function init()
    m.top.adPlaying = False
    m.top.functionName = "runPreplay" ' defined in PreplayTask.brs
end function

function runPreplay()
    '
    '  1. Make Preplay request to Uplynk, without adapter
    '
    preplayInfo = loadPreplay()
    '
    '  2. Load and instanciate Adapter
    '
    adapter = loadAdapter()
    '
    '  3. Setup adapter with preplayInfo, read by myself
    '
    setupStream(adapter, preplayInfo)
    '
    '  4. Play content
    '
    runLoop(adapter)
end function


function loadAdapter() as object
    '
    '  1. Load and instanciate Adopter
    '
    adapter = RAFX_SSAI({name:"uplynk"}) ' Required, "uplynk"
    if adapter <> invalid
        adapter.init({loglevel:20}) ' init() call is required. Parameter is optional.
        print "RAFX_SSAI version ";adapter["__version__"]
    end if
    return adapter
end function

function setupStream(adapter as object, preplayInfo as object) as void
    if invalid = adapter or invalid = preplayInfo then return
    '
    '  3.1 Compose request info
    '
    preplayInfo["type"] = adapter.StreamType.VOD ' Required, VOD 
    '
    '  3.2  Provide adapter the preplay info
    '
    adapter.setStreamInfo(preplayInfo)
    '
    '  3.3  Configure video node
    '
    vidContent = createObject("RoSGNode", "ContentNode")
    vidContent.url = preplayInfo.playURL  ' returned from Uplynk server
    vidContent.title = m.top.testConfig.title
    vidContent.streamformat = "hls"
    m.top.video.content = vidContent
    m.top.video.setFocus(true)
    m.top.video.visible = true
    m.top.video.EnableCookies()
    '
    '  3.4  other RAF settings
    '
    adIface = Roku_Ads()
    adIface.enableAdMeasurements(true) ' Required
    ' adIface.setContentLength()    ' Set app/content specific info
    ' adIface.setNielsenProgramId() ' Set app/content specific info
    ' adIface.setNielsenGenre()     ' Set app/content specific info
    ' adIface.setNielsenAppId()     ' Set app/content specific info
    ' adIface.setDebugOutput(true)
end function

function runLoop(adapter as object) as void
    if invalid = adapter then return
    '
    '   4.1  set callbacks
    '
    addCallbacks(adapter) ' Required when not using RAF.stitchedAdHandledEvent()
    ' 
    '   4.1  Enable adapter Ad tracking
    ' 
    port = CreateObject("roMessagePort")
    '
    adapter.enableAds({player:{sgnode:m.top.video, port:port} ' Required
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
        curAd = adapter.onMessage(msg) ' Required
        if invalid = curAd
            m.top.video.setFocus(true)
        end if
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
end function
function adEventCallback(adInfo as Object) as Void
    print "At ";adInfo.position;" from Adopter -- " ; adInfo.event
end function
function podEndCallback(podInfo as Object)
    m.top.adPlaying = False
    m.top.video.enableTrickPlay = true
    m.top.video.setFocus(true)
end function


' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function loadPreplay() as object
    '
    '   Your App may request Preplay info to Uplynk without using adapter.requestStream()
    '   prior to this playback task begin.
    '   However, the preplay response from Uplynk must be provided to
    '   the adapter.setStreamInfo() as is in this playback task.
    '
    preplayInfo = invalid
    xfer = createObject("roUrlTransfer")
    xfer.setUrl(m.top.testConfig.url)   ' Required, mediaURL, .json
    xfer.addHeader("Accept", "application/json")
    jsnstr = xfer.getToString()
    if invalid <> jsnstr and "" <> jsnstr
        preplayInfo = parsejson(jsnstr)
    end if
    return preplayInfo
end function

