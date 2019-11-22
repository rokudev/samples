' ********** Copyright 2018 Roku, Inc.  All Rights Reserved. ********** 
Library "Roku_Ads.brs"

function init()
   '
   '  Following info must be provided
   '
   '   m.top.testConfig.adURL      :  Ad metadata URL
   '   m.top.testConfig.mediaURL   :  video content URL to playback
   '   m.top.testConfig.masterURL  :  or masterURL to retrieve adURL and mediaURL
   '   m.top.testConfig.useStitched   :  true or false
   '
    m.top.adPlaying = False
    m.top.functionName = "runTask"
    m.useStitched = true
end function

function runTask()
    '
    '  1. Load and instanciate Adopter
    '
    adapter = loadAdopter()
    '
    '  2. Request preplay
    '
    if loadStream(adapter)
        '
        '  3. Play content
        '
        runLoop(adapter)

    end if
end function

function loadAdopter() as object
    '  not calling RAF.stitchedAdHandledEvent(). App is responsible to call RAF.fireTrackingEvents()
    if invalid <> m.top.testConfig["useStitched"] and false = m.top.testConfig.useStitched then m.useStitched = false
    '
    '  1. Load and instanciate Adopter
    '
    adapter = RAFX_SSAI({name:"onceux"}) ' Required
    if adapter <> invalid
        ' adapter.init() ' Required
        adapter.init({logLevel:10})
        print "RAFX_SSAI version ";adapter["__version__"]
    end if
    return adapter
end function

function requestPlaybackAPI()
    '
    '  This function is provided as a reference only. Actual implementation depends on your App policy
    '
    xfer = createObject("roUrlTransfer")
    '
    ' See https://sdkdocs.roku.com/display/sdkdoc/roUrlTransfer how to configure roUrlTransfer on https request
    ' xfer.setCertificatesFile("common:/certs/ca-bundle.crt")
    '
    xfer.addHeader("Accept", "application/json;pk={policy_key}") ' You must replace {policy_key} with your polic_key value
    xfer.setUrl(m.top.testConfig.masterURL)
    port = createObject("roMessagePort")
    xfer.setPort(port)
    '
    '  Make GET request
    '
    xfer.asyncGetToString()
    count = 0
    jsonstr = ""
    while count < 4 ' You must decide how long to wait for the response from masterURL
        msg = port.waitMessage(4000)
        if msg <> invalid and type(msg) = "roUrlEvent"
            jsonstr = msg.getString()
            exit while
        end if
        count = count + 1
    end while
    if 0 < jsonstr.len()
        response = parseJSON(jsonstr)
        if response.sources <> invalid
            '
            '   Parse resonse. You must pick one of sources[] based on your App policy
            '
            m.top.testConfig.mediaURL = response.sources[0].src
            m.top.testConfig.adURL = response.sources[0].vmap
        end if
    end if
end function

function loadStream(adapter as object) as boolean
    if invalid = adapter then return False
    '
    '  2.1  Request masterURL and know AdUrl/mediaUrl
    '
    if m.top.testConfig.masterURL <> invalid
        requestPlaybackAPI()
        if m.top.testConfig.adURL.len() = 0 or m.top.testConfig.mediaURL.len() = 0
            return False
        end if
    end if
    '
    '  2.2 Compose request info
    '
    request = {
        type: adapter.StreamType.VOD, ' Required
        url:  m.top.testConfig.adURL   ' Required, ad-URL
    }
    requestResult = adapter.requestStream(request) ' Required, requesting Ad Metadata
    if requestResult["error"] <> invalid
        print "Error requesting stream ";requestResult
        return False
    else
        '
        '  2.3  Setup video node.
        '
        vidContent = createObject("RoSGNode", "ContentNode")
        vidContent.title = m.top.testConfig.title
        vidContent.url = m.top.testConfig.mediaURL
        vidContent.streamformat = "hls"
        m.top.video.content = vidContent
        m.top.video.setFocus(true)
        m.top.video.visible = true
        m.top.video.enableCookies()
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
    return True
end function

function runLoop(adapter as object) as void
    if invalid = adapter then return
    '
    '   3.1  Set callbacks
    '
    addCallbacks(adapter) ' Required when not using RAF.stitchedAdHandledEvent()
    ' 
    '   3.2  Enable adapter Ad tracking
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
    adapter.enableAds({ player : {sgnode:m.top.video, port:port},              ' Required
                        useStitched : m.useStitched  ' Optional, default is true
                     })
    '
    '   3.3  Observe video node
    '
    m.top.video.observeFieldScoped("position", port) ' Required
    m.top.video.observeFieldScoped("control", port)
    m.top.video.observeFieldScoped("state", port)
    '
    '   3.4  Start playback and fire uo:contentImpression
    '
    m.top.video.control = "play"
    fireOnceUXContentImpression(adapter)
    while true
        msg = wait(1000, port)
        if type(msg) = "roSGNodeEvent" and msg.getField() = "control" and msg.getNode() = m.top.video.id and not m.top.adPlaying and msg.getData() = "stop" or m.top.video = invalid
            exit while  ' video node stopped. quit loop
        end if

        '
        '  3.5  Have adapter handle events
        '
        currentTime = m.top.video.position
        curAd = adapter.onMessage(msg) ' Required
    end while
    m.top.video.unobserveFieldScoped("position")
    m.top.video.unobserveFieldScoped("control")
    m.top.video.unobserveFieldScoped("state")
end function


'
'   OnceUX requires uo:contentImpression upon playback content
'
function fireOnceUXContentImpression(adapter as object) ' Required
    uoInfo = adapter.getStreamInfo()
    if uoInfo <> invalid and uoInfo.tracking <> invalid and 0 < uoInfo.tracking.count()
        adIface = Roku_Ads()
        for each evt in uoInfo.tracking
            if "Impression" = evt.event ' Fire uo:contentImpression
                adIface.util.getNoResponseFromUrl(evt.url)
            end if
        end for
    end if
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
        print "     Ad count: ";adPod.ads.count()
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
            adIface.fireTrackingEvents(m.adPod, {type: podInfo.event})
            m.adIndex = 0
        end if
    end if
end function
function adEventCallback(adInfo as Object) as Void
    print "At ";adInfo.position;" from SDK -- " ; adInfo.event
    if invalid <> m.adPod and m.adIndex < m.adPod.ads.count()
        adIface = Roku_Ads()
        ' fire Ad pixel
        ad = m.adPod.ads[m.adIndex]
        adIface.fireTrackingEvents(ad, {type: adInfo.event})
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
        adIface.fireTrackingEvents(m.adPod, {type: podInfo.event})
        m.adIndex = 0
    end if
    m.adPod = invalid
end function
