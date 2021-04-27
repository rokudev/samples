' ********** Copyright 2018 Roku, Inc.  All Rights Reserved. ********** 
Library "Roku_Ads.brs"

function init()
   '
   '  Following info must be provided
   '
   '   m.top.testConfig.url          :  master URL
   '   m.top.testConfig.params       :  optional object, adsParams of initial request
   '   m.top.testConfig.useStitched  :  true or false
   '
    m.top.adPlaying = False
    m.top.functionName = "runTask"
    m.useStitched = true
end function

function runTask()
    '
    '  1. Load and instanciate Adopter
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
    '  not calling callStitchedAdHandledEvent(). App is responsible to call RAF.fireTrackingEvents()
    if invalid <> m.top.testConfig["useStitched"] and false = m.top.testConfig.useStitched then m.useStitched = false
    m.useStitched = true
    m.useStitched = false
    '
    '  1. Load and instanciate Adopter
    '
    adapter = RAFX_SSAI({name:"awsemt"}) ' Required
    if adapter <> invalid
        adapter.init({logLevel:89}) ' Required
        print "RAFX_SSAI version ";adapter["__version__"]
    end if
    return adapter
end function

function loadStream(adapter as object) as void
    if invalid = adapter then return
    streamInfo = invalid
    if false
        '
        '   2.1  Compose request info and fetch Manifest and Tracking URLs
        '
        request = {
            type: m.top.testConfig.type,    ' Required, live or vod
            url:  m.top.testConfig.url      ' Required, master-URL
        }
        if invalid <> m.top.testConfig["params"]
            ' As providing  body, adapter will make POST request instead of GET
            request["body"] = formatjson(m.top.testConfig.params) ' Optional, {adsParams: {param1,param2,...}}
        end if
        requestResult = adapter.requestStream(request) ' Required, requesting Ad Metadata
        if requestResult["error"] <> invalid
            print "Error requesting stream ";requestResult
        else
            streamInfo = adapter.getStreamInfo() ' Required when vod, optional when live
        end if
    else
        '   2.2  Optional, for Apps manifest_url and tracking_url known already:
        streamInfo = {
            type:  "live",
            tracking_url: "https://prod-ukor.fubo.tv/v1/tracking/6c9193257c0eed8ca3f1eabccc4444f9477500f1/production/65bb4bda-97b1-4c48-a290-70a9aa186c1a",
            manifest_url: "https://prod-ukor.fubo.tv/v1/dash/6c9193257c0eed8ca3f1eabccc4444f9477500f1/production/master.mpd?ads._fw_h_user_agent=Roku%2FDVP-9.40+%28049.40E04190A%29&ads._fw_ip=24.6.241.163&ads._fw_is_lat=0&ads._fw_station=816750002&ads._fw_vcid2=fuboTV%3A5f4e939054bd660001386859&ads.device=roku&ads.fw_device_id=_fw_did%3Db8c209a2-943b-5597-85ac-0600debab1ef&ads.fw_nw_id=393638&ads.fw_playback_type=live&ads.fw_site=fubo_roku_live&ads.fw_site_section=fubo_connected_tv_roku_live&alternate-feed=0&aws.sessionId=65bb4bda-97b1-4c48-a290-70a9aa186c1a&callsign=FXMHD_TEST&device=ALL&hdnts=ip%3D24.6.241.163~st%3D1605984095~exp%3D1606070495~acl%3D%2F%2A~data%3D1606070495~hmac%3Dfef8ada11b031bf04a7aefd3859f100df9affe05ecf6d045f0acb93c913c1c30&watchToken=eyJhbGciOiJIUzI1NiIsInRva2VuVHlwZSI6IlVzYUJhc2VXYXRjaFRva2VuIiwidHlwIjoiSldUIn0.eyJ3YXRjaFRva2VuIjp7ImNhbGxTaWduIjoiRlhNSERfVEVTVCIsImRldmljZSI6IkFMTCIsImJhbmR3aWR0aCI6Ik1BU1RFUiIsImNvdW50cnkiOiJVU0EiLCJ1c2VySWQiOiI1ZjRlOTM5MDU0YmQ2NjAwMDEzODY4NTkiLCJyZXF1ZXN0VHlwZSI6ImxpdmUiLCJyZWdpb24iOiJ3ZXN0In0sImhvbWVaaXAiOiIxMDAxOSIsImdlb1ppcCI6Ijk1MDUxIn0.xhVjpZAj1lY3veeX94C6Nxn4RI5LEqUP5FPAy9JdWtk"
        }
        adapter.setStreamInfo(streamInfo)
    end if
    if invalid <> streamInfo
        '
        '  2.3  Setup video node.  Select here variant
        '
        vidContent = createObject("RoSGNode", "ContentNode")
        vidContent.title = m.top.testConfig.title
        if invalid <> streamInfo.manifest_url
            vidContent.url = streamInfo.manifest_url
            if 0 < vidContent.url.instr("/master/") then
                vidContent.streamformat = "hls"
            else if 0 < vidContent.url.instr("/dash/") then
                vidContent.streamformat = "dash"
            end if
        end if
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
    while true
        msg = wait(1000, port)
        '
        '  3.5  Have adapter handle events
        '
        curAd = adapter.onMessage(msg) ' Required
        if "roSGNodeEvent" = type(msg)
            if "state" = msg.getField() and "finished" = msg.getData() and msg.getNode() = m.top.video.id then
                exit while ' stream ended. quit loop
            end if
            if "state" = msg.getField() and "stopped" = msg.getData() and  msg.getNode() = m.top.video.id then
                exit while  ' video node stopped. quit loop
            end if
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
