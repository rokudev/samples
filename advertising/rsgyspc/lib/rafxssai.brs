' ********** Copyright 2019 Roku, Inc.  All Rights Reserved. **********
function RAFX_getSSAIPluginBase(params as object) as Object
daisdk = {}
daisdk.init = function(params=invalid as object) as Void
m.createImpl()
m.createEventCallbacks()
m.updateLocale()
m.logLevel = 0
if invalid <> params
if invalid <> params["logLevel"] then m.logLevel = params.logLevel
end if
end function
daisdk.requestStream = function(requestObj as object) as object
status = {}
ret = m.impl.requestPreplay(requestObj)
if ret <> invalid and ret["error"] <> invalid
status["error"] = ret["error"]
end if
return status
end function
daisdk.getStreamInfo = function() as object
return m.impl.getStreamInfo()
end function
daisdk.setStreamInfo = function(streamInfo as object) as object
return m.impl.setStreamInfo(streamInfo)
end function
daisdk.enableAds = function(params as object) as void
m.impl.enableAds(params)
end function
daisdk.addEventListener = function(event as string, callback as function) as Void
m.eventCallbacks.addEventListener(event, callback)
end function
daisdk.onMessage = function(msg as object) as object
return m.impl.onMessage(msg)
end function
daisdk.onSeekSnap = function(seekRequest as object) as double
return m.impl.onSeekSnap(seekRequest)
end function
daisdk.isInteractive = function(curAd as object) as boolean
return m.impl.isInteractive(curAd)
end function
daisdk.command = function(params as object) as object
return m.impl.command(params)
end function
daisdk.createEventCallbacks = function() as object
obj = m.createDAIObject("eventCallbacks")
obj.callbacks = {}
return obj
end function
evtcll = {}
evtcll.addEventListener = function(event as string, callback as function) as Void
m.callbacks[event] = callback
end function
evtcll.doCall = function(event as string, adInfo as object) as Void
if invalid <> m.callbacks[event]
func = getglobalaa()["callFunctionInGlobalNamespace"]
func(m.callbacks[event], adInfo)
end if
end function
evtcll.errCall = function(errid as integer, errInfo as string) as Void
ERROR = m.sdk.CreateError()
ERROR.id = errid
ERROR.info = errInfo
dd = getglobalaa()["callFunctionInGlobalNamespace"]
dd(m.sdk.AdEvent.ERROR, ERROR)
end function
daisdk["eventCallbacks"] = evtcll
daisdk.createImpl = function() as object
obj = m.createDAIObject("impl")
obj.strmURL = ""
obj.prplyInfo = invalid
obj.wrpdPlayer = invalid
obj.loader = invalid
obj.streamManager = invalid
obj.useStitched = true  
adIface = m.getRokuAds()
return obj
end function
impl = {}
impl.setStreamInfo = function(streamInfo as object) as void
end function
impl.parsePrplyInfo = function() as object
m.sdk.log("parsePrplyInfo() To be overridden")
return {adOpportunities:0, adBreaks:[]}
end function
impl.enableAds = function(params as object) as Void
ei = false
if type(params["player"]) = "roAssociativeArray"
player = params["player"]
if player.doesexist("port") and player.doesexist("sgnode")
ei = true
end if
m.wrpdPlayer = player
end if
m.useStitched = (invalid = params["useStitched"]  or  params["useStitched"])
if m.useStitched
adIface = m.sdk.getRokuAds()
adIface.stitchedAdsInit([])
end if
if not ei
m.sdk.log("Warning: Invalid object for interactive ads.")
return
end if
m.setRAFAdPods(params["ads"])
end function
impl.setRAFAdPods = function(adbreaksGiven = invalid as object) as Void
adBreaks = adbreaksGiven
if invalid = adbreaksGiven
pTimer = createObject("roTimespan")
parseResults = m.parsePrplyInfo()
adBreaks = parseResults.adBreaks
if m.loader["xResponseTime"] <> invalid
m.sdk.logToRAF("ValidResponse", {ads:adBreaks,slots:parseResults.adOpportunities,responseTime:m.loader.xResponseTime, parseTime:pTimer.totalMilliseconds(), url:m.loader.strmURL, adServers:invalid})
m.loader.xResponseTime = invalid
end if
end if
if 0 < adBreaks.count()
if m.useStitched
adIface = m.sdk.getRokuAds()
adIface.stitchedAdsInit(adBreaks)
m.sdk.log(["impl.setRAFAdPods() adBreaks set to RAF. renderTime: ",adBreaks[0].renderTime.tostr()], 5)
end if
m.sdk.eventCallbacks.doCall(m.sdk.AdEvent.PODS, {event:m.sdk.AdEvent.PODS, adPods:adBreaks})
end if
if invalid = m.streamManager then m.streamManager = m.sdk.createStreamManager()
m.streamManager.createTimeToEventMap(adBreaks)
end function
impl.onMetadata = function(msg as object) as void
end function
impl.onPosition = function (msg as object) as void
m.streamManager.onPosition(msg)
end function
impl.onMessage = function(msg as object) as object
msgType = m.sdk.getMsgType(msg, m.wrpdPlayer)
if msgType = m.sdk.msgType.FINISHED     
m.sdk.log("All video is completed - full result")
m.sdk.eventCallbacks.doCall(m.sdk.AdEvent.STREAM_END, {})
else if msgType = m.sdk.msgType.METADATA
m.onMetadata(msg)
else if msgType = m.sdk.msgType.POSITION
m.onPosition(msg)
end if
curAd = m.msgToRAF(msg)
if invalid <> m.prplyInfo and msgType = m.sdk.msgType.POSITION
m.streamManager.onMessageVOD(msg, curAd)
m.onMessageLIVE(msg, curAd)
else if msgType = m.sdk.msgType.FINISHED     
m.streamManager.deinit()
end if
return curAd
end function
impl.onSeekSnap = function(seekRequest as object) as double
if invalid = m.prplyInfo or m.prplyInfo.strmType <> m.sdk.StreamType.VOD or invalid = m.streamManager then return seekRequest.time
return m.streamManager.onSeekSnap(seekRequest)
end function
impl.onMessageLIVE = function(msg as object, curAd as object) as void
if m.sdk.StreamType.LIVE <> m.prplyInfo.strmType then return
end function
impl.msgToRAF = function(msg as object) as object
if m.useStitched
adIface = m.sdk.getRokuAds()
return adIface.stitchedAdHandledEvent(msg, m.wrpdPlayer)
end if
return invalid
end function
impl.requestPreplay = function(requestObj as object) as object
ret = {}
if invalid = m.loader
m.loader = m.createLoader(requestObj.type)
end if
jsn = m.loader.requestPreplay(requestObj)
if type(jsn) = "roAssociativeArray"
m.prplyInfo = jsn
else if jsn <> ""
m.prplyInfo = parsejson(jsn)
end if
if m.prplyInfo <> invalid
if requestObj["testAds"] <> invalid
ads = ReadAsciiFile(requestObj.testAds)
if ads <> invalid
m.prplyInfo.ads = parsejson(ads)
else
m.sdk.log(requestObj.testAds + " may not be valid JSON")
end if
end if
m.prplyInfo["strmType"] = requestObj.type
m.loader.composePingURL(m.prplyInfo)
else
m.prplyInfo = {strmType:requestObj.type}
ret["error"] = "No valid response from "+requestObj.url
end if
return ret
end function
impl.createLoader = function(live_or_vod as string) as object
m.loader = m.sdk.createLoader(live_or_vod)
return m.loader
end function
impl.isInteractive = function(curAd as object) as boolean
return m.streamManager.isInteractive(curAd)
end function
impl.command = function(params as object) as object
ret = invalid
if m.useStitched and "exitPod" = params.cmd
ret = m.exitPod(params)
end if
return ret
end function
impl.exitPod = function(params as object) as object
curAd = invalid
strmMgr = m.streamManager
if invalid <> params.curAd and invalid <> strmMgr.currentAdBreak and not strmMgr.isInteractive(params.curAd)
msg = {
getData : function()
return 0
end function
getField : function() as string
return "keypressed"
end function
isRemoteKeyPressed : function() As Boolean
return true
end function
GetIndex : function() As Integer
return 0
end function
IsScreenClosed : function() As Boolean
return false
end function
}
curAd = m.msgToRAF(msg)
adIface = m.sdk.getRokuAds()
adIface.stitchedAdsInit([])
end if
return curAd
end function
daisdk["impl"] = impl
daisdk.createLoader = function(live_or_vod as string) as object
obj = m.createDAIObject(live_or_vod+"loader")
obj.strmURL = ""
return obj
end function
liveloader = {}
liveloader.ping = function(param as dynamic) as void
m.sdk.log("liveloader.ping() To be overridden")
end function
daisdk["liveloader"] = liveloader
vodloader = {}
vodloader.ping = function(param as dynamic) as void
end function
vodloader.composePingURL = function(prplyInfo as object) as void
end function
vodloader.requestPreplay = function(requestObj as object) as dynamic
if not m.isValidString(m.strmURL)
m.strmURL = requestObj.url
end if
return m.getJSON(requestObj)
end function
vodloader.isValidString = function(ue as dynamic) as boolean
ve = type(ue)
if ve = "roString" or ve = "String"
return len(ue) > 0
end if
return false
end function
vodloader.getJSON = function(params as object) as string
xfer = m.sdk.createUrlXfer(m.sdk.httpsRegex.isMatch(params.url))
xfer.setUrl(params.url)
port = createObject("roMessagePort")
xfer.setPort(port)
xfer.addHeader("Accept", "application/json, application/xml")
if invalid <> params["headers"]
for each item in params["headers"].items()
xfer.addHeader(item.key, item.value)
end for
end if
xTimer = createObject("roTimespan")
if params["retry"] <> invalid then m.sdk.logToRAF("Request", params)
xTimer.mark()
if invalid <> params["body"]
xfer.asyncPostFromString(params.body)
else
xfer.asyncGetToString()
end if
timeoutsec = 4
if invalid <> params["timeoutsec"]
timeoutsec = params["timeoutsec"]
end if
msg = port.waitMessage(timeoutsec*1000)
xTime = xTimer.totalMilliseconds()
if msg = invalid
m.sdk.logToRAF("ErrorResponse", {error: "no response",
time: xTime, label: "Primary", url:params.url})
m.sdk.log("Msg is invalid. Possible timeout on loading URL")
return ""
else if type(msg) = "roUrlEvent"
wi = msg.getResponseCode()
if 200 <> wi and 201 <> wi
m.sdk.logToRAF("EmptyResponse", {error: msg.getfailurereason(),
time: xTime, label: "Primary", url:params.url})
m.sdk.log(["Transfer url: ", params.url, " failed, got code: ", wi.tostr(), " reason: ", msg.getfailurereason()])
return ""
end if
if params["retry"] <> invalid then m.xResponseTime = xTime
return msg.getString()
else
m.sdk.log("Unknown Ad Request Event: " + type(msg))
end if
return ""
end function
daisdk["vodloader"] = vodloader
daisdk.createStreamManager = function() as object
obj = m.createDAIObject("streamManager")
obj.adTimeToEventMap = invalid
obj.adTimeToBreakMap = invalid
obj.adTimeToBeginEnd = invalid
obj.crrntPosSec = -1
obj.lastPosSec = -1
obj.whenAdBreakStart = -1 
obj.currentAdBreak = invalid
return obj
end function
strmMgr = {}
strmMgr.addEventToEvtMap = function(timeToEvtMap as object, timeKey as string, evtStr as string) as void
if timeToEvtMap[timeKey] = invalid
timeToEvtMap[timeKey] = [evtStr]
else
eExist = false
for each e in timeToEvtMap[timeKey]
eExist =   eExist or (e = evtStr)
end for
if not eExist
timeToEvtMap[timeKey].push(evtStr)
end if
end if
end function
strmMgr.createTimeToEventMap = function(adBreaks as object) as Void
if adBreaks = invalid
m.adTimeToEventMap = invalid
m.adTimeToBreakMap = invalid
m.adTimeToBeginEnd = invalid
return
end if
timeToEvtMap = {}
timeToBreakMap = {}
timeToBeginEnd = []
for each adBreak in adBreaks
brkBegin = int(adBreak.renderTime)
brkTimeKey = brkBegin.tostr()
timeToEvtMap[brkTimeKey] = [m.sdk.AdEvent.POD_START]
timeToBreakMap[brkTimeKey] = adBreak
adRenderTime = adBreak.renderTime
for each rAd in adBreak.ads
hasCompleteEvent = false
for each evt in rAd.tracking
if invalid <> evt["time"]
timeKey = int(evt.time).tostr()
m.addEventToEvtMap(timeToEvtMap, timeKey, evt.event)
if m.sdk.AdEvent.COMPLETE = evt.event
hasCompleteEvent = true
end if
end if
end for
adRenderTime = adRenderTime + rAd.duration
if not hasCompleteEvent and 0 < rAd.tracking.count() and 0 < rAd.duration
timeKey = int(adRenderTime - 0.5).tostr()
m.addEventToEvtMap(timeToEvtMap, timeKey, m.sdk.AdEvent.COMPLETE)
end if
end for
brkEnd = int(adBreak.renderTime+adBreak.duration)
timeKey = brkEnd.tostr()
m.appendBreakEnd(timeToEvtMap, timeKey)
timeToBeginEnd.push({"begin":brkBegin, "end":brkEnd, "renderSequence":adBreak.renderSequence})
end for
if not timeToEvtMap.isEmpty()
m.adTimeToEventMap = timeToEvtMap
m.lastEvents = {}
end if
if not timeToBreakMap.isEmpty() then m.adTimeToBreakMap = timeToBreakMap
if 0 < timeToBeginEnd.count() then
timeToBeginEnd.sortby("begin")
m.adTimeToBeginEnd = timeToBeginEnd
end if
end function
strmMgr.appendBreakEnd = function(timeToEvtMap as object, timeKey as string) as object
if timeToEvtMap[timeKey] = invalid
timeToEvtMap[timeKey] = [m.sdk.AdEvent.POD_END]
else
timeToEvtMap[timeKey].push(m.sdk.AdEvent.POD_END)
end if
return timeToEvtMap
end function
strmMgr.findBreak = function(possec as float) as object
snapbrk = invalid
if invalid = m.adTimeToBeginEnd then return snapbrk
for each brk in m.adTimeToBeginEnd
if  brk.begin <= possec  and  possec <= brk.end
snapbrk = brk
exit for
end if
if possec < brk.end then exit for
end for
return snapbrk
end function
strmMgr.onSeekSnap = function(seekRequest as object) as double
if invalid = m.adTimeToBeginEnd then return seekRequest.time
if m.sdk.SnapTo.NEXTPOD = seekRequest.snapto
for each brk in m.adTimeToBeginEnd
if seekRequest.time < brk.begin then
exit for
else if m.crrntPosSec <= brk.begin and brk.begin <= seekRequest.time
snap2begin = brk.begin - 1
if snap2begin < 0 then snap2begin = 0
return snap2begin
end if
end for
else
snapbrk = m.findBreak(seekRequest.time)
if snapbrk = invalid then return seekRequest.time
snap2begin = snapbrk.begin - 1
if snap2begin < 0 then snap2begin = 0
if "postroll" = snapbrk.renderSequence then return snap2begin
if m.sdk.SnapTo.BEGIN = seekRequest.snapto
return snap2begin
else if m.sdk.SnapTo.END = seekRequest.snapto
return snapbrk.end + 1
end if
end if
return seekRequest.time
end function
strmMgr.onPosition = function(msg as object) as Void
m.sdk.log(["onPosition() msg position: ",msg.getData().tostr()], 89)
if m.currentAdBreak = invalid or m.currentAdBreak.duration = invalid
return
end if
posSec = msg.getData()
if 0 <= m.whenAdBreakStart and m.whenAdBreakStart + m.currentAdBreak.duration + 2 < posSec
m.cleanupAdBreakInfo(false)
end if
end function
strmMgr.onMessageVOD = function(msg as object, curAd as object) as Void
posSec = msg.getData()
if posSec = m.crrntPosSec or posSec = m.lastPosSec
return
end if
m.lastPosSec = m.crrntPosSec
m.crrntPosSec = posSec
if m.crrntPosSec <> m.lastPosSec + 1
m.handlePosition(posSec - 1, curAd)
end if
m.handlePosition(posSec, curAd)
end function
strmMgr.handlePosition = function(sec as integer, curAd as object) as Void
if m.adTimeToEventMap <> invalid
timeKey = sec.tostr()
if m.adTimeToEventMap[timeKey] <> invalid
for each adEvent in m.adTimeToEventMap[timeKey]
if adEvent <> invalid
m.handleAdEvent(adEvent, sec, curAd)
end if
end for
end if
end if
end function
strmMgr.fillAdBreakInfo = function(sec as integer, curAd as object) as Void
m.whenAdBreakStart = sec
if invalid <> m.adTimeToBreakMap
adBreak = m.adTimeToBreakMap[sec.tostr()]
if invalid <> adBreak
m.currentAdBreak = adBreak
end if
end if
end function
strmMgr.updateAdBreakEvents = function(adBreak as object, triggered as boolean) as void
adBreak.viewed = triggered
for each ad in adBreak.ads
for each evnt in ad.tracking
evnt.triggered = triggered
end for
end for
for each evnt in adBreak.tracking
evnt.triggered = triggered
end for
end function
strmMgr.cleanupAdBreakInfo = function(triggered=false as boolean) as void
if m.currentAdBreak <> invalid
m.updateAdBreakEvents(m.currentAdBreak, triggered)
end if
m.whenAdBreakStart = -1
m.currentAdBreak = invalid
m.lastEvents = {}
end function
strmMgr.deinit = function() as void
m.adTimeToEventMap = invalid
m.adTimeToBreakMap = invalid
m.adTimeToBeginEnd = invalid
m.currentAdBreak = invalid
m.crrntPosSec = -1
m.lastPosSec = -1
m.whenAdBreakStart = -1
end function
strmMgr.handleAdEvent = function(adEvent as string, sec as integer, curAd as object) as Void
if adEvent = m.sdk.AdEvent.POD_START
m.fillAdBreakInfo(sec, curAd)
if m.lastEvents[adEvent] <> sec
m.lastEvents = {}
end if
else 
if invalid = m.currentAdBreak 
ab = m.findBreak(sec)
if invalid <> ab 
pastSec = ab.begin
while pastsec < sec
m.handlePosition(pastSec, curAd)
pastSec += 1
end while
end if
end if
end if
if m.lastEvents[adEvent] <> sec 
adInfo = {position:sec, event:adEvent}
if adEvent = m.sdk.AdEvent.POD_START then adInfo["adPod"] = m.currentAdBreak
m.sdk.eventCallbacks.doCall(adEvent, adInfo)
m.lastEvents[adEvent] = sec
end if
end function
strmMgr.pastLastAdBreak = function(posSec as integer) as boolean
return invalid = m.adTimeToBeginEnd  or  m.adTimeToBeginEnd.peek()["end"] < posSec
end function
strmMgr.cancelPod = function (curAd as object) as object
ret = {canceled: false}
if invalid <> m.currentAdBreak  and  0 < m.crrntPosSec
ab = m.currentAdBreak
if not m.isInteractive(curAd)
shortdur = (m.crrntPosSec-1) - ab.renderTime
if 0 < shortdur
ab.duration = shortdur
m.cleanupAdBreakInfo(true)
ret["canceled"] = true 
end if
end if
end if
return ret
end function
strmMgr.isInteractive = function(curAd as object) as boolean
if invalid <> curAd and invalid <> curAd["adindex"] and invalid <> m.currentAdBreak
ad = m.currentAdBreak.ads[curAd["adindex"] - 1]
strmFmt = ad["streamFormat"]
return "iroll" = strmFmt  or  "brightline" = left(strmFmt,10)
end if
return false
end function
daisdk["streamManager"] = strmMgr
daisdk.setCertificate = function(certificateRef as string) as Void
m.certificate = certificateRef
end function
daisdk.getCertificate = function() as string
if m.certificate = invalid
return "common:/certs/ca-bundle.crt"
end if
return m.certificate
end function
daisdk.getMsgType = function(msg as object, player as object) as integer
nodeId = player.sgnode.id
if "roSGNodeEvent" = type(msg)
xg = msg.getField()
if nodeId = msg.getNode()
if xg = "position"
return m.msgType.POSITION
else if xg.left(13) = "timedMetaData"
return m.msgType.METADATA
else if xg = "state"
if msg.getData() = "finished"
return m.msgType.FINISHED
end if
end if
else
if xg = "keypressed"
return m.msgType.KEYEVENT
end if
end if
end if
return m.msgType.UNKNOWN
end function
daisdk.createUrlXfer = function(ishttps as boolean) as object
xfer = createObject("roUrlTransfer")
if ishttps
xfer.setCertificatesfile(m.getCertificate())
xfer.initClientCertificates()
end if
xfer.addHeader("Accept-Language", m.locale.Accept_Language)
xfer.addHeader("Content-Language", m.locale.Content_Language)
return xfer
end function
daisdk.setTrackingTime = function(timeOffset as float, rAd as object) as void
duration = rAd.duration
for each evt in rAd.tracking
if evt.event = m.AdEvent.IMPRESSION
evt.time = 0.0 + timeOffset
else if evt.event = m.AdEvent.FIRST_QUARTILE
evt.time = duration * 0.25 + timeOffset
else if evt.event = m.AdEvent.MIDPOINT
evt.time = duration * 0.5 + timeOffset
else if evt.event = m.AdEvent.THIRD_QUARTILE
evt.time = duration * 0.75 + timeOffset
else if evt.event = m.AdEvent.COMPLETE
evt.time = duration + timeOffset
end if
end for
end function
daisdk.getValidStr = function(obj as object) as string
if invalid <> obj and invalid <> getInterface(obj, "ifString")
return obj.trim()
else
return ""
end if
end function
daisdk.httpsRegex = createObject("roRegEx", "^https", "")
daisdk.getRokuAds = function() as object
return roku_ads()
end function
daisdk.logToRAF = function(btype as string, obj as object) as object
m.getRokuAds().util.fireBeacon(btype, obj)
end function
daisdk.createDAIObject = function(objName as string) as object
if type(m[objName]) = "roAssociativeArray"
m[objName]["sdk"] = m
end if
return m[objName]
end function
daisdk.updateLocale = function()
m.locale.Content_Language = createObject("roDeviceInfo").getCurrentLocale().replace("_","-")
end function
daisdk.ErrorEvent = {
ERROR : "0",
COULD_NOT_LOAD_STREAM: "1000",
STREAM_API_KEY_NOT_VALID: "1002",
BAD_STREAM_REQUEST: "1003"
INVALID_RESPONSE: "1004"
}
daisdk.AdEvent = {
PODS: "PodsFound"
POD_START: "PodStart"
START: "Start",
IMPRESSION: "Impression",
CREATIVE_VIEW: "creativeView",
FIRST_QUARTILE: "FirstQuartile",
MIDPOINT: "Midpoint",
THIRD_QUARTILE: "ThirdQuartile",
COMPLETE: "Complete",
POD_END: "PodComplete",
STREAM_END: "StreamEnd",
ACCEPT_INVITATION: "AcceptInvitation",
ERROR: "Error"
}
daisdk.msgType = {
UNKNOWN: 0,
POSITION: 1,
METADATA: 2,
FINISHED: 3,
KEYEVENT: 4,
}
daisdk.version = {
ver: "0.1.0"
}
daisdk.locale = {
Accept_Language: "en-US,en-GB,es-ES,fr-CA,de-DE", 
Content_Language: "en-US" 
}
daisdk.StreamType = {
LIVE: "live",
VOD: "vod"
}
daisdk.SnapTo = {
NEXTPOD:  "nextpod", 
BEGIN: "begin",
END:   "end"
}
daisdk.CreateError = function() as object
ERROR = createObject("roAssociativeArray")
ERROR.id = ""
ERROR.info = ""
ERROR.type = "error"
return ERROR
end function
daisdk.log = function(x, logLevel=-1 as integer) as void
if logLevel < m.logLevel
dtm = ["SDK (", createObject("roDateTime").toISOString().split("T")[1], "): "].join("")
if "roArray" = type(x)
print dtm; x.join("")
else
print dtm; x
end if
end if
end function
getglobalaa()["callFunctionInGlobalNamespace"] = function(dd as function, ue as object) as Void
dd(ue)
end function
return daisdk
end function
function RAFX_getYospaceAdapter(params as dynamic) as Object
rafssai = RAFX_getSSAIPluginBase(params)
impl = rafssai["impl"]
impl.getStreamInfo = function() as object
return m.prplyInfo
end function
impl.enableAdsBase = impl.enableAds
impl.enableAds = function(params as object) as void
m.enableAdsBase(params)
if m.useStitched and m.prplyInfo.strmType = m.sdk.StreamType.LIVE
player = params["player"]
selected = false
skeys = []
for each key in player.sgnode.timedMetaDataSelectionKeys
if key = m.streamManager.YMID or key = "*"
selected = true
exit for
else
skeys.push(key)
end if
end for
if not selected
skeys.push("*")
player.sgnode.timedMetaDataSelectionKeys = skeys
end if
player.sgnode.observeField("timedMetaData",  player.port)
player.sgnode.observeField("timedMetaData2", player.port)
end if
end function
impl.onMetadata = function(msg as object) as void
if not m.useStitched then return
ret = m.streamManager.onMetadata(msg)
if invalid <> ret["shortDuration"]
else if invalid <> ret["pendingPod"]
pendingPod = ret["pendingPod"]
m.setRAFAdPods([pendingPod])
podBeginSec = int(pendingPod.renderTime)
while podBeginSec <= m.streamManager.crrntPosSec
m.streamManager.handlePosition(podBeginSec, {})
podBeginSec += 1
end while
end if
end function
impl.parsePrplyInfo = function() as object
if invalid <> m.prplyInfo
if m.prplyInfo.strmType = m.sdk.StreamType.LIVE
if invalid <> m.pingInfo and invalid <> m.pingInfo["xmlstr"]
obj = m.yspc2raf(m.pingInfo.xmlstr)
m.pingInfo["xmlstr"] = invalid
if 0 = obj["adBreaks"].count()
return obj
else
for each adBreak in obj["adBreaks"]
adBreak["rendersequence"] = "midroll"
end for
end if
m.streamManager.appendPod(obj["adBreaks"])
end if
else if m.prplyInfo.strmType = m.sdk.StreamType.VOD and invalid <> m.prplyInfo["xmlstr"]
return m.yspc2raf(m.prplyInfo.xmlstr)
end if
else
end if
return {adOpportunities:0, adBreaks:[]}
end function
impl.MIMETYPE = createObject("roRegEx", "(type=""video/)[\-\.\w]+""", "")
impl.yspc2raf = function(xmlstr as string) as object
if 170 < xmlstr.len() then print "<> <> <> impl.yspc2raf() xmlstr: ";xmlstr
adIface = m.sdk.getRokuAds()
xmlstr = m.MIMETYPE.replaceall(xmlstr, "\1mp4""")
xmlstr = xmlstr.replace("sequence=""0""", "sequence=""1""")
obj = adIface.parser.parse(xmlstr, "")
for each ab in obj["adPods"]
timeOffset = ab.renderTime
for each ad in ab.ads
m.sdk.setTrackingTime(timeOffset, ad)
timeOffset += ad.duration
end for
end for
if invalid <> obj["adpods"] and 0 < obj["adpods"].count()
adids = []
for each ad in obj["adPods"][0]["ads"]
adids.push(ad["adid"])
end for
end if
return {adOpportunities:obj["adOpportunities"], adBreaks:obj["adPods"]}
end function
impl.pingInfo = invalid
impl.parsePing = function() as void
xmlstr = m.loader.getPingResponse()
if invalid <> xmlstr and "" <> xmlstr
m.pingInfo = {xmlstr:xmlstr}
end if
end function
impl.onMessageLIVE = function(msg as object, curAd as object) as void
if m.sdk.StreamType.LIVE <> m.prplyInfo.strmType then return
posSec = msg.getData()
if m.streamManager.pastLastAdBreak(posSec)
m.streamManager.createTimeToEventMap(invalid)
end if
m.parsePing()
if invalid <> m.pingInfo and invalid <> m.pingInfo["xmlstr"]
m.setRAFAdPods()
end if
if m.shouldPing(posSec)
m.loader.ping({position:posSec})
m.last_ping = createObject("roDateTime").asSeconds()
end if
end function
impl.PING_INTERVAL = 10
impl.last_ping = 0
impl.shouldPing = function(posSec as float) as boolean
if m.loader.hasPinged() then return false
itis = createObject("roDateTime").asSeconds()
return (m.last_ping + m.PING_INTERVAL < itis)
end function
impl.createLoader = function(live_or_vod as string) as object
obj = m.sdk.createLoader(live_or_vod)
if live_or_vod = m.sdk.StreamType.VOD
return obj
end if
obj.pingURL = ""
obj.isPinging = false
obj.pingPort = createObject("roMessagePort")
obj.ping_json = invalid
obj.lastEndTs = 0
obj.tsDuration = 3600
obj.dateTime = createObject("roDateTime")
baseobj = m.sdk["vodloader"]
obj.getJSON = baseobj.getJSON
obj.isValidString = baseobj.isValidString
return obj
end function
strmMgr = rafssai["streamManager"]
strmMgr.lastAssetId = invalid
strmMgr.PTS = "_decodeInfo_pts"
strmMgr.YMID = "YMID"
strmMgr.MESSAGEDATA = "MessageData"
strmMgr.AD_MID = createObject("roRegex", "[^_]*_YO_([\s\S]*)", "i")
strmMgr.pendingPod = invalid
strmMgr.appendPod = function(newPodList as object) as void
newPod = newPodList[0]
if invalid <> m.pendingPod
m.appendAdToBreak(newPod, m.pendingPod)
end if
if 0 < newPod.ads.count()
m.pendingPod = newPod
end if
end function
strmMgr.appendAdToBreak = function(newPod as object, destPod as object) as void
adsNotAppended = []
for each rAd in newPod.ads
timeOffset = destPod.renderTime
appended = false
for i=0 to destPod.ads.count()-1
currentAd = destPod.ads[i]
if invalid = currentAd["id"]
m.sdk.setTrackingTime(timeOffset, rAd)
destPod.ads[i] = rAd            
destPod.duration += rAd.duration
appended = true
exit for
else if rAd.id = currentAd.id
appended = true     
exit for
end if
timeOffset += currentAd.duration
end for
if not appended then adsNotAppended.push(rAd)
end for
newPod.ads = adsNotAppended
end function
strmMgr.getMediaID = function(obj as object) as string
ymid = ""
if invalid <> obj[m.MESSAGEDATA]
ymidobj = {}
msgdt = obj[m.MESSAGEDATA]
tags = msgdt.split(",")
for each kv in tags
tag = kv.split("=")
if (tag.count() = 2) then
ymidobj[tag[0]] = tag[1]
end if
end for
if invalid <> ymidobj[m.YMID] then ymid = ymidobj[m.YMID]
else
ymidobj = obj
ymidhex = ymidobj[m.YMID]
if invalid = ymidhex or "" = ymidhex or ymidhex.len() < 2 or "03" <> ymidhex.left(2) then return ymid
ymidhex = ymidhex.mid(2)
ymidlen = ymidhex.len()
ymid = invalid
arr = createObject("roArray", ymidlen/2, false)
for i=0 to ymidlen-1 step 2
arr[i/2] = chr(val(ymidhex.mid(i, 2), 16))
end for
ymid = arr.join("")
end if
return ymid
end function
strmMgr.onMetadata = function(msg as object) as object
ret = {pendingPod:invalid}
if invalid = m.currentAdBreak and invalid = m.pendingPod then return ret
if "timedMetaData" <> msg.getField() then return ret
obj = msg.getData()
ymid = m.getMediaID(obj)
if invalid = ymid or "" = ymid then return ret
if invalid <> m.currentAdBreak
else if invalid <> m.pendingPod
for each ad in m.pendingPod.ads
if invalid <> ad["adid"]
matched = m.AD_MID.match(ad["adid"])
if invalid <> matched and 1 < matched.count() and matched[1] = ymid
m.pendingPod.renderTime = obj[m.PTS]
timeOffset = m.pendingPod.renderTime
for each ad in m.pendingPod.ads
m.sdk.setTrackingTime(timeOffset, ad)
timeOffset += ad.duration
end for
m.pendingPod.duration = timeOffset - m.pendingPod.renderTime
ret["pendingPod"] = m.pendingPod
m.pendingPod = invalid
exit for
end if
end if
end for
end if
return ret
end function
vodloader = rafssai["vodloader"]
vodloader.urlDomain = createObject("roRegEx", "urlDomain=""([^""]+)""", "")
vodloader.urlSuffix = createObject("roRegEx", "urlSuffix=""([^""]+)""", "")
vodloader.requestPreplay = function(requestObj as object) as object
preplayInfo = {playURL:"", xmlstr:""}
if not m.isValidString(m.strmURL)
m.strmURL = requestObj.url
end if
vmapstr = m.getJSON({url:m.strmURL, retry:0})
if invalid <> vmapstr
preplayInfo["xmlstr"] = vmapstr
fields = vmapstr.split("<yospace:Stream")
if 1 < fields.count()
schm = m.strmURL.split(":")[0]
md = m.urlDomain.match(fields[1])
if invalid <> md and 1 < md.count()
domain = md[1]
ms = m.urlSuffix.match(fields[1])
if invalid <> ms and 1 < ms.count()
preplayInfo["Stream"] = {urlDomain:domain, urlSuffix:ms[1]}
end if
end if
end if
end if
return preplayInfo
end function
liveloader = rafssai["liveloader"]
liveloader.regex = {
ANALYTICS_URL : createObject("roRegEx", "^#EXT-X-YOSPACE-ANALYTICS-URL:", "")
STREAM_INF : createObject("roRegEx", "^#EXT-X-STREAM-INF:", "")
URL : createObject("roRegEx", "^http", "")
BANDWIDTH : createObject("roRegEx", "BANDWIDTH=(\d+)", "")
RESOLUTION : createObject("roRegEx", "RESOLUTION=(\d+x\d+)", "")
BASE_PATH : createObject("roRegEx", "^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)([\?]([^#]*))?(#(.*))?", "ig")
}
liveloader.sessionInfo = {}
liveloader.parseDASH = function(dash as string) as object
preplayInfo = {STREAM_INF:[]}
xmldoc = createObject("roXMLElement")
success = xmldoc.parse(dash)
key = "ANALYTICS_URL"
if success then
print "<> <> <> parseDash() Now analysing XML playlist"
mpd = xmldoc
if (mpd <> invalid) and (mpd.GetName() = "MPD") then
print "<> <> <> parseDash() Looking for location"
loc = mpd.GetNamedElements("Location")
if (loc.count() > 0) then
locurl = m.regex["BASE_PATH"].match(loc[0].GetText())
if invalid <> locurl  and  5 < locurl.count()
paths = locurl[5].split(";")
paths[0] = "/csm/analytics" 
preplayInfo[key] = [locurl[1],locurl[3],paths.join(";")].join("")
end if
end if
end if
end if
if invalid = preplayInfo[key] then m.sdk.log("liveloader.parseDASH() AnalyticsURL not found", 2)
return preplayInfo
end function
liveloader.parseM3u8 = function(m3u8 as string) as object
preplayInfo = {STREAM_INF:[]}
if invalid <> m3u8
streamInf = {}
for each ln in m3u8.split(chr(10))
key = "ANALYTICS_URL"
matches = m.regex[key].match(ln)
if 0 < matches.count()
preplayInfo[key] = ln.mid(matches[0].len()).replace("""","")
else
key = "STREAM_INF"
matches = m.regex[key].match(ln)
if 0 < matches.count()
key = "BANDWIDTH"
matches = m.regex[key].match(ln)
if 1 < matches.count() then streamInf[key] = matches[1].toint()
key = "RESOLUTION"
matches = m.regex[key].match(ln)
if 1 < matches.count() then streamInf[key] = matches[1]
else
key = "URL"
matches = m.regex[key].match(ln)
if 0 < matches.count() and invalid <> streamInf["BANDWIDTH"]
streamInf[key] = ln.trim()
preplayInfo["STREAM_INF"].push(streamInf)
streamInf = {}
end if
end if
end if
end for
end if
return preplayInfo
end function
liveloader.requestSession = function(masterURL as string) as string
playlistURL = masterURL
yourl = m.regex["BASE_PATH"].match(masterURL)
if invalid <> yourl  and  7 < yourl.count()
if invalid <> yourl[3]
authority = yourl[4]
host = ""
userdet = ""
if (authority.instr("@") > -1) then
host = authority.split("@")[1]
else
host = authority
end if
host = host.split(":")[0]
end if
sessionURL = yourl[2] + "://" + host + "/csm/session"
sessionstr = m.getJSON({url:sessionURL, retry:0})
if invalid <> sessionstr
fields = sessionstr.split(" ")
m.sessionInfo["host"] = fields[0].trim()
m.sessionInfo["id"] = fields[1].trim()
m.sessionInfo["path"] = yourl[5] + ";jsessionid=" + m.sessionInfo["id"]
playlistURL = [yourl[2], "://", m.sessionInfo["host"], m.sessionInfo["path"], "?", yourl[7]].join("")
end if
end if
return playlistURL
end function
liveloader.requestPreplay = function(requestObj as object) as dynamic
if not m.isValidString(m.strmURL)
m.strmURL = requestObj.url
end if
playlistURL = m.requestSession(m.strmURL)
res = m.getJSON({url:playlistURL, retry:0})
print "<> <> <> liveloader.requestPreplay() res: ";res
if "#EXTM" = res.left(5)
preplayInfo = m.parseM3u8(res)
else
preplayInfo = m.parseDASH(res)
end if
preplayInfo["playURL"] = playlistURL
return preplayInfo
end function
liveloader.ping = function(params as dynamic) as void
if "" = m.pingURL then return
url = m.pingURL
m.pingXfer = m.sdk.createUrlXfer(m.sdk.httpsRegex.isMatch(url))
m.pingXfer.setMessagePort(m.pingPort)
m.pingXfer.setUrl(url)
m.pingXfer.addHeader("Accept", "application/json")
m.pingXfer.asyncGetToString()
m.isPinging = true
end function
liveloader.hasPinged = function() as boolean
return m.isPinging
end function
liveloader.getPingResponse = function() as string
res = ""
if not m.isPinging then return res
msg = m.pingPort.getMessage()
if invalid <> msg and type(msg) = "roUrlEvent"
hstat = msg.getResponseCode()
if hstat = 200
res = msg.getString()
else
end if
m.isPinging = false
end if
return res
end function
liveloader.composePingURL = function(prplyInfo as object) as void
if invalid <> prplyInfo["ANALYTICS_URL"]
m.pingURL = prplyInfo.ANALYTICS_URL
end if
end function
return rafssai
end function
function RAFX_SSAI(params as object) as object
    if invalid <> params and invalid <> params["name"]
        p = RAFX_getYospaceAdapter(params)
        p["__version__"] = "0b.42.11"
        p["__name__"] = params["name"]
        return p
    end if
end function
