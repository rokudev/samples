' ********** Copyright 2020 Roku, Inc.  All Rights Reserved. **********
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
function RAFX_getAdobeSimplePlugin(params as object) as Object
rafssai = RAFX_getSSAIPluginBase(params)
impl = rafssai["impl"]
impl.adobeToRAFEvent = {
"breakStart" : rafssai.AdEvent.POD_START
"Impression" : rafssai.AdEvent.IMPRESSION
"start" : rafssai.AdEvent.START
"creativeView" : rafssai.AdEvent.CREATIVE_VIEW
"firstQuartile" : rafssai.AdEvent.FIRST_QUARTILE
"first" : rafssai.AdEvent.FIRST_QUARTILE
"midpoint" : rafssai.AdEvent.MIDPOINT
"thirdQuartile" : rafssai.AdEvent.THIRD_QUARTILE
"third" : rafssai.AdEvent.THIRD_QUARTILE
"complete" : rafssai.AdEvent.COMPLETE
"breakEnd" : rafssai.AdEvent.POD_END
}
impl.getStreamInfo = function() as object
if m.prplyInfo <> invalid
if invalid <> m.prplyInfo["masterURL"]
return {playURL:m.prplyInfo["masterURL"]}
else
return {
playURL: m.prplyInfo["mediaURL"]
}
end if
end if
return {}
end function
impl.parseTrackingXML = function(xmlstr as string, adpods as object)
for each pod in adpods
if invalid = pod["tracking"] then pod.tracking = []
end for
if 0 < xmlstr.inStr("<vmap:Tracking ")
xparser = createObject("roXMLElement")
xparser.parse(xmlstr)
podIdx = 0
for each abxml in xparser.getNamedElements("vmap:AdBreak")
trackingEvents = abxml.getNamedElements("vmap:TrackingEvents")[0]
if invalid <> trackingEvents and podIdx < adpods.count()
for each tracking in trackingEvents.getNamedElements("vmap:Tracking")
newTracking = {event: m.adobeToRAFEvent[tracking@event],
url: tracking.getText().trim(),
triggered: false}
adpods[podIdx].tracking.push(newTracking)
end for
end if
podIdx += 1
end for
end if
end function
impl.parsePrplyInfo = function() as object
if invalid <> m.prplyInfo and invalid <> m.prplyInfo["pods"]
return m.adb2raf(m.prplyInfo.pods)
else if invalid <> m.prplyInfo["xml"]
adIface = m.sdk.getRokuAds()
obj = adIface.parser.parse(m.prplyInfo["xml"], "")
m.prplyInfo.delete("xml")
m.prplyInfo["pods"] = [] 
if obj["adpods"] <> invalid and 0 < obj.adpods.count()
for each pod in obj.adpods
if invalid = pod.renderTime
if "preroll" = pod.renderSequence
pod.renderTime = 0.0
else if "postroll" = pod.renderSequence
pod.renderTime = 1e9
end if
end if
renderTime = pod.renderTime
for each ad in pod.ads
m.sdk.setTrackingTime(renderTime, ad)
renderTime += ad.duration
end for
end for
return {adOpportunities:obj.adopportunities,adBreaks:obj.adpods}
end if
end if
return {adOpportunities:0, adBreaks:[]}
end function
impl.adb2raf = function(pods as object) as object
idx = 0
adOpportunities = 0
rafBreaks = []
for each adbPod in pods
adBreak = {
viewed: false,
renderTime: 0.0,
renderSequence: "",
duration: 0.0,
tracking: [],
slots: 0,
ads: []
}
if adbPod.startTime = 0.0
adBreak.renderSequence = "preroll"
else
adBreak.renderSequence = "midroll"
end if
adBreak.renderTime = adbPod.startTime
adBreak.duration = adbPod.duration
if adbPod["trackingUrls"] <> invalid
m.parseTrackingUrls(adBreak.tracking, adbPod.trackingUrls)
end if
if adbPod["ads"] <> invalid
m.parseAds(adBreak, adbPod.ads)
end if
if 0 < adBreak.ads.count()
rafBreaks.push(adBreak)
adOpportunities += adBreak.ads.count()
end if
end for
return {adOpportunities:adOpportunities, adBreaks:rafBreaks}
end function
impl.parseAds = function(adBreak as object, srcads as object) as void
for each ad in srcads
rAd = {
duration: ad.duration,
streamFormat: "hls",
adServer: m.strmURL,
streams: [],
tracking: []
}
if invalid <> ad["id"]
rAd["adid"] = ad["id"]
end if
if ad["trackingUrls"] <> invalid
m.parseTrackingUrls(rAd.tracking, ad.trackingUrls)
end if
if ad["companions"] <> invalid
companionAds = []
for each ca in ad.companions
rtype = ca["resourceType"]
if ca["mimeType"] = "application/json" and (rtype = "brightline" or rtype = "innovid")
rca = {
url: ca["url"],
width: ca["width"],
height: ca["height"],
mimetype: ca["mimeType"],
tracking: []
}
if ca["trackingUrls"] <> invalid
m.parseTrackingUrls(rca.tracking, ca.trackingUrls)
end if
companionAds.push(rca)
end if
end for
if 0 < companionAds.count()
rAd.companionAds = companionAds
end if
end if
adBreak.ads.push(rAd)
end for
end function
impl.parseTrackingUrls = function(destObj as object, trackingUrls as object) as void
for each track in trackingUrls
eventName = m.adobeToRAFEvent[track.event]
if eventName <> invalid
rafEvent = {event:eventName, url:track.url, time:track.startTime, triggered:false}
destObj.push(rafEvent)
end if
end for
end function
impl.onMetadata = function(msg as object) as void
mediaURL = msg.getData()
if invalid <> mediaURL
if invalid = m.prplyInfo["mediaURL"]
m.prplyInfo["mediaURL"] = mediaURL
end if
end if
end function
impl.onPosition = function (msg as object) as void
if invalid <> m.prplyInfo["variantURL"] and invalid = m.prplyInfo["pods"]
adjsn = m.loader.requestAdInsertion(m.prplyInfo.variantURL)
if invalid = adjsn
m.prplyInfo["pods"] = []
else
m.prplyInfo.append(adjsn)
m.setRAFAdPods()
end if
end if
m.streamManager.onPosition(msg)
end function
impl.requestPreplayBase = impl.requestPreplay
impl.requestPreplay = function(requestObj as object) as object
requestObj["type"] = "vod" 
return m.requestPreplayBase(requestObj)
end function
vodloader = rafssai["vodloader"]
vodloader.bandwidth = createObject("roRegEx", "BANDWIDTH=(\d+)", "")
vodloader.trckngpos = createObject("roRegEx", "(pttrackingposition=\d+)", "")
vodloader.requestPreplay = function(requestObj as object) as dynamic
prplyInfo = {}
jsnstr = m.getJSON({url:requestObj.url})
if invalid = jsnstr then return ""
masterjson = parsejson(jsnstr)
if invalid = masterjson or not m.isValidString(masterjson["Master-M3U8"]) then return prplyInfo
if false then return {masterURL:masterjson["Master-M3U8"]}
playlistUrl = masterjson["Master-M3U8"]
mediaURL = m.selectMediaUrl(playlistUrl, requestObj)
if mediaURL <> ""
prplyInfo["variantURL"] = mediaURL
end if
prplyInfo["mediaURL"] = playlistUrl
matches = m.trckngpos.match(requestObj.url)
if 1 < matches.count()
m.trackingposition = matches[1]
end if
return prplyInfo
end function
vodloader.requestAdInsertion = function (mediaURL as string) as object
adjsn = invalid
m.strmURL = mediaURL
jsnstr = m.getJSON({url:m.composeAdUrl(mediaURL),retry:0})
if invalid <> jsnstr
if "{" = jsnstr.left(1)
adjsn = parsejson(jsnstr)
else if "<" = jsnstr.left(1)
adjsn = {xml:jsnstr}
end if
end if
return adjsn
end function
vodloader.selectMediaUrl = function(playlistUrl as string, requestObj as object) as string
m3u8str = m.getJSON({url:playlistUrl})
if invalid <> requestObj["callback"]
return requestObj.callback(m3u8str)
end if
kbpscap = 4000
if invalid <> requestObj["kbps"] then kbpscap = requestObj.kbps
lastkbps = 0
url = ""
if "" <> m3u8str then
pickNextLine = false
for each line in m3u8str.split(chr(10))
matches = m.bandwidth.match(line)
if 1 < matches.count()
kbps = matches[1].toint() / 1000
if kbps <= kbpscap and lastkbps < kbps
pickNextLine = true
lastkbps = kbps
else
pickNextLine = false
end if
else if pickNextLine
url = line
pickNextLine = false
end if
end for
end if
return url
end function
vodloader.composeAdUrl = function(mediaURL as string) as string
if invalid <> m.trackingposition
return mediaURL + "&" + m.trackingposition
end if
return mediaURL + "&pttrackingposition=1"
end function
return rafssai
end function
function RAFX_getAdobeHLSPlugin(params as object) as Object
rafssai = RAFX_getSSAIPluginBase(params)
rafssai.HLSDir = {
EXT_X_MARKER : "#EXT-X-MARKER:"
}
impl = rafssai["impl"]
impl.getStreamInfo = function() as object
if m.prplyInfo <> invalid
return {
playURL: m.prplyInfo["mediaURL"]
}
end if
return {}
end function
impl.requestPreplayBase = impl.requestPreplay
impl.requestPreplay = function(requestObj as object) as object
requestObj["type"] = "vod" 
return m.requestPreplayBase(requestObj)
end function
impl.enableAds = function(params as object) as Void
ei = false
player = params["player"]
if type(player) = "roAssociativeArray"
if player.doesexist("port") and player.doesexist("sgnode")
ei = true
end if
m.wrpdPlayer = player
end if
m.useStitched = (invalid = params["useStitched"]  or  params["useStitched"])
if not ei
m.sdk.log("Warning: Invalid object for interactive ads.")
return
end if
player.sgnode.timedMetaDataSelectionKeys = [m.sdk.HLSDir.EXT_X_MARKER]
player.sgnode.observeField("timedMetaData2", player.port)
if invalid = m.streamManager
m.streamManager = m.sdk.createStreamManager()
m.streamManager.mediaURL = m.prplyInfo["mediaURL"]
end if
if invalid <> params.filter_xmkr_by
m.streamManager.xid = params.filter_xmkr_by
end if
end function
impl.onMetadata = function(msg as object) as void
m.streamManager.onMetadata(msg, m.useStitched, m.wrpdPlayer.sgnode)
end function
strmMgr = rafssai["streamManager"]
strmMgr.adBreaks = invalid
strmMgr.adBreakID = invalid
strmMgr.xid = "data" 
strmMgr.getXid = function(xobj as object) as string
if "data" = m.xid then
return xobj.xdata
else
return xobj.id
end if
end function
strmMgr.setXid = function(xobj as object, xdata as string) as void
if "data" = m.xid then
xobj.xdata = xdata 
else
xobj.xdata = xobj.id
end if
end function
strmMgr.isPodBegin = function(podbegin as string) as boolean
return (podbegin <> invalid and podbegin.right(8) = "PodBegin")
end function
strmMgr.isPodEnd = function(podend as string) as boolean
return (podend <> invalid and podend.right(6) = "PodEnd")
end function
strmMgr.onMetadataAdBegin = function(position, xobj as object) as void
if invalid = m.adBreakID 
m.setEmptyAdBreak(position)
end if
if invalid <> xobj.data and invalid <> m.adBreakID
newAd = xobj.data[0]
for each adbreak in m.adBreaks
if m.adBreakID = adbreak.xid
adSeq = -1
for i=0 to adbreak.ads.count()-1
if 0 = adbreak.ads[i].duration
adbreak.ads[i] = newAd
adSeq = i
exit for
end if
end for
if adSeq < 0
adbreak.ads.push(newAd)
end if
adRenderTime = adbreak.renderTime
if 0 < adbreak.duration
adRenderTime += adbreak.duration
end if
m.sdk.setTrackingTime(adRenderTime, newAd)
if 0 < adbreak.duration  and  int(adRenderTime) <=int(m.crrntPosSec) then
adRenderTime = int(m.crrntPosSec + 1)
for each evt in newAd.tracking
if m.sdk.AdEvent.IMPRESSION = evt.event
evt.time = adRenderTime
end if
end for
end if
adbreak.duration += newAd.duration
m.sdk.log(["Ad renderTime: ", adRenderTime.tostr(), "  dur: ", adBreak.duration.tostr()], 20)
exit for
end if
end for
end if
m.createTimeToEventMap(m.adBreaks)
end function
strmMgr.onMetadata = function(msg as object, useStitched as boolean, sgnode as object) as void
if msg.getField() <> "timedMetaData2" then return
if invalid = m.adBreaks
adIface = m.sdk.getRokuAds()
m.adBreaks = [{rendersequence:"midroll",renderTime:0,tracking:[],duration:0,ads:[]}]
if useStitched then adIface.stitchedAdsInit(m.adBreaks)
end if
obj = msg.getData()
position = obj["position"]
ext_x_marker = invalid
if obj["data"] <> invalid and obj.data[m.sdk.HLSDir.EXT_X_MARKER] <> invalid
ext_x_marker = obj.data[m.sdk.HLSDir.EXT_X_MARKER]
if 0 = position and 0 < m.crrntPosSec then
m.sdk.log(["X-Marker ", ext_x_marker.left(60), "... as position 0, ignored. current strm pos: ", m.crrntPosSec.tostr()], 20)
return
end if
end if
if invalid <> ext_x_marker
m.sdk.log(["X-Marker at position: ", position.tostr(), "  current strm pos: ", m.crrntPosSec.tostr()], 20)
xobj = m.parseXMarker(ext_x_marker)
if m.isPodBegin(xobj.xtype)
m.sdk.logToRAF("Request", {retry:0, url:m["mediaURL"]})
if invalid <> xobj.data
adBreak = xobj.data
adBreak.duration = 0
adBreak.BREAKDUR = xobj.podduration
if 15 < abs(position - sgnode.position)
m.sdk.log(["WARNING: PodBegin X-Marker position: ", position.tostr(), " video.position: ", sgnode.position.tostr(), " diff more than 15sec"], 10)
end if
adBreak.renderTime = position
if int(position) <= m.crrntPosSec
adBreak.renderTime = m.crrntPosSec + 1
adBreak.duration -= (adBreak.renderTime - position)
end if
m.adBreaks[0] = adBreak      
m.sdk.log(["Pod renderTime: ", adBreak.renderTime.tostr(), "  dur: ", adBreak.BREAKDUR.tostr()], 20)
m.sdk.eventCallbacks.doCall(m.sdk.AdEvent.PODS, {event:m.sdk.AdEvent.PODS, adPods:m.adBreaks, position:position})
m.adBreakID = adBreak["xid"]
else
m.sdk.logToRAF("ErrorResponse", {error:"invalid xml", time:0,
label:"XMarker", url:m["mediaURL"]})
end if
else if "AdBegin" = xobj.xtype
m.onMetadataAdBegin(position, xobj)
else if m.isPodEnd(xobj.xtype)
eopByMarker = position
if 0 < xobj.offset
if invalid <> sgnode.streamingSegment and sgnode.streamingSegment.doesExist("segStartTime")
eopByMarker = xobj.offset + sgnode.streamingSegment.segStartTime
else
eopByMarker += xobj.offset
end if
end if
eopByMarker = int(eopByMarker)
if eopByMarker <= m.crrntPosSec
eopByMarker = m.crrntPosSec + 1
end if
abEnding = invalid
for each ab in m.adBreaks
if m.adBreakID = ab.xid
abEnding = ab
exit for
end if
end for
if invalid <> abEnding and invalid <> m.adTimeToEventMap
timeToEvtMap = {}
timeKey = eopByMarker.tostr()
if 0 < xobj.offset
eoa = int(abEnding.renderTime + abEnding.duration) + 1
for posint = m.crrntPosSec+1 to eoa
posKey = posint.tostr()
if invalid <> m.adTimeToEventMap[posKey]
if m.sdk.AdEvent.COMPLETE = m.adTimeToEventMap[posKey][0]
exit for
else
timeToEvtMap[posKey] = m.adTimeToEventMap[posKey]
end if
end if
end for
timeToEvtMap[timeKey] = [m.sdk.AdEvent.COMPLETE, m.sdk.AdEvent.POD_END]
else
timeToEvtMap[timeKey] = [m.sdk.AdEvent.POD_END]
end if
m.adTimeToEventMap = timeToEvtMap
end if
if useStitched and abEnding <> invalid
eopByPodBegin = abEnding.renderTime + abEnding.duration
if eopByMarker < eopByPodBegin
abEnding.duration -= (eopByPodBegin - eopByMarker)
end if
end if
m.adBreakID = invalid
end if
end if
end function
strmMgr.appendBreakEnd = function(timeToEvtMap as object, timeKey as string) as void
end function
strmMgr.rgx_id   = createObject("roRegEx", "ID=([\w+]+)", "")
strmMgr.rgx_xtype= createObject("roRegEx", "TYPE=([\w+]+)", "")
strmMgr.rgx_duration = createObject("roRegEx", "DURATION=([\d+[\.\d+]*)", "")
strmMgr.rgx_offset = createObject("roRegEx", "OFFSET=([\d+[\.\d+]*)", "")
strmMgr.rgx_podduration = createObject("roRegEx", "BREAKDUR=([\d+[\.\d+]*)", "")
strmMgr.rgx_adcount = createObject("roRegEx", "COUNT=(\d+)", "")
strmMgr.rgx_data = createObject("roRegEx", "DATA=" + chr(34) + "([\w+/=\+]+)", "")
strmMgr.rgx_outer = createObject("roRegEx", "</?AdTrackingFragments?></?AdTrackingFragments?>", "")
strmMgr.rgx_adseq = createObject("roRegEx", "<Ad[^>]+(sequence=""(\d+)"")", "")
strmMgr.VASTToRAFEvent = {
"start"             : "Impression"
"defaultimpression" : "Impression"
"impression"        : "Impression"
"creativeview"      : "Impression"
"firstquartile"     : "FirstQuartile"
"midpoint"          : "Midpoint"
"thirdquartile"     : "ThirdQuartile"
"complete"          : "Complete"
"_mute"             : "Mute"
"mute"              : "Mute"
"_un-mute"          : "Unmute"
"unmute"            : "Unmute"
"_pause"            : "Pause"
"pause"             : "Pause"
"_resume"           : "Resume"
"resume"            : "Resume"
"_rewind"           : "Rewind"
"_close"            : "Close"
"close"             : "Close"
"closelinear"       : "Close"
"skip"              : "Skip"
"error"             : "Error"
"acceptinvitation"  : "AcceptInvitation"
"acceptinvitationlinear"    : "AcceptInvitation"
"breakstart"        : "PodStart"
"slotimpression"    : "PodStart"
"slotend"           : "PodComplete"
"breakend"          : "PodComplete"
}
strmMgr.extract = function(s as string, rgx as object, defaultval as dynamic) as dynamic
matches = rgx.match(s)
if invalid <> matches and  1 < matches.count()
return matches[1]
end if
return defaultval
end function
strmMgr.parseXMarker = function(ext_x_marker as string) as object
xobj = {
id: m.extract(ext_x_marker, m.rgx_id, "")
xtype: m.extract(ext_x_marker, m.rgx_xtype, "")
data: invalid
}
m.sdk.log(["X-Marker ", ext_x_marker.left(80), "..."], 50)
xdata = m.extract(ext_x_marker, m.rgx_data, "")
if xdata.left(1) = chr(34)
xdata = xdata.right(len(xdata)-1)
end if
m.setXid(xobj, xdata)
ba = createObject("roByteArray")
ba.fromBase64String(xdata)
xmlstr = ba.toAsciiString()
if invalid = xmlstr then return xobj
xmlstr = m.rgx_outer.replaceAll(xmlstr, "")
if m.isPodBegin(xobj.xtype)
xobj.adcount = m.extract(ext_x_marker, m.rgx_adcount, 0)
xobj.podduration = val(m.extract(ext_x_marker, m.rgx_podduration, "0"))
for each ab in m.adBreaks
if ab.xid = m.getXid(xobj) then
m.sdk.log(["Duplicate PodBegin. ID: ", xobj.id], 30)
xobj.xtype = "dupPodBegin"
return xobj
end if
end for
m.parsePodBegin(xmlstr, xobj)
else if "AdBegin" = xobj.xtype
if invalid <> m.adBreaks
adBreak = m.adBreaks[0]
for each ad in adBreak.ads
if ad.xid = m.getXid(xobj)
m.sdk.log(["Duplicate AdBegin. ID: ", xobj.id, "   LastID: ", ad.idid], 30)
xobj.xtype = "dupAdBegin"
return xobj
end if
end for
end if
xobj.duration = val(m.extract(ext_x_marker, m.rgx_duration, "0"))
m.parseAdBegin(xmlstr, xobj)
else if m.isPodEnd(xobj.xtype)
xobj.offset = val(m.extract(ext_x_marker, m.rgx_offset, "0"))
m.parsePodEnd(xmlstr, xobj)
end if
return xobj
end function
strmMgr.PLACEHOLDERPOD = "placeholder"
strmMgr.setEmptyAdBreak = function(position)
xobj = {id:m.PLACEHOLDERPOD, adcount:"3", data:invalid, xdata:m.PLACEHOLDERPOD}
m.parsePodBegin("", xobj)
if invalid <> xobj.data
adBreak = xobj.data
adBreak.renderTime = position
if int(position) <= m.crrntPosSec
adBreak.renderTime = position + 1
end if
m.adBreaks[0] = adBreak      
m.sdk.eventCallbacks.doCall(m.sdk.AdEvent.PODS, {event:m.sdk.AdEvent.PODS, adPods:m.adBreaks, position:position})
m.adBreakID = adBreak["xid"]
end if
end function
strmMgr.parsePodBegin = function(xmlstr as string, xobj as object) as void
adBreak = {rendersequence:"midroll", renderTime:0, tracking:[], viewed:false, ads:[]}
if "" <> xmlstr then
adBreak = m.parseMultiVMAP(xmlstr)
end if
adBreak["duration"] = 0
adBreak["xid"] = m.getXid(xobj)
if "" <> xobj.adcount
adCount = xobj.adcount.toInt()
adBreak.ads = createObject("roArray", adCount, true)
i = 0
while i < adCount
adBreak.ads[i] = {duration:0,tracking:[]}
i += 1
end while
else
adBreak.ads = []
end if
xobj.data = adBreak
end function
strmMgr.parseAdBegin = function(data as string, xobj as object) as void
vasts = data.split("</VAST>")
vast = vasts[0]
mtch = m.rgx_adseq.match(vast)
if invalid <> mtch and 1 < mtch.count()
sequence = mtch[1]
vast = vast.replace(sequence, "sequence=""1""")
xobj["sequenceNum"] = mtch[2].toInt()
end if
vastxml = vast + "</VAST>"
m.parseAdBeginRAF(vastxml, xobj)
events = []
for i=1 to vasts.count()-1
vast = vasts[i] + "</VAST>"
xml = createObject("roXMLElement")
xml.parse(vast)
wrapper = invalid
ads = xml.getNamedElements("Ad")
if 0 < ads.count() and invalid <> ads[0].Wrapper
wrapper = ads[0].Wrapper
end if
if invalid <> wrapper
for each impression in wrapper.getNamedElements("Impression")
url = impression.getText()
events.push({event:"Impression",url:url,triggered:false})
end for
if wrapper.Creatives <> invalid and wrapper.Creatives.Creative <> invalid and wrapper.Creatives.Creative.Linear <> invalid and wrapper.Creatives.Creative.Linear.TrackingEvents <> invalid
trackingEvents = wrapper.Creatives.Creative.Linear.TrackingEvents
for each tracking in trackingEvents.getNamedElements("Tracking")
url = m.sdk.getValidStr(tracking.getText())
evt = m.VASTToRAFEvent[m.sdk.getValidStr(tracking@event)]
if invalid <> evt and "" <> url
events.push({event:evt, url:url, triggered:false})
end if
end for
end if
end if
end for
if invalid <> xobj.data and 0 < events.count()
ad = xobj.data[0]
ad["xid"] = m.getXid(xobj)
if invalid <> ad["tracking"] then
ad.tracking.append(events)
else
ad.tracking = events
end if
end if
end function
strmMgr.parseAdBeginRAF = function(xmlstr as string, xobj as object) as void
adIface = m.sdk.getRokuAds()
validvast = xmlstr.split("</VAST>")[0] + "</VAST>"
obj = adIface.parser.parse(validvast, "")
if invalid = obj then return
obj_type = type(obj)
if obj_type = "roAssociativeArray" and invalid <> obj["adpods"] and  0 < obj.adpods.count()
ads = []
for each adpod in obj.adpods
if invalid <> adpod["ads"] and 0 < adpod.ads.count()
ads.append(adpod.ads)
end if
end for
xobj.data = ads
else if obj_type = "roArray" and 1 <= obj.count() and invalid <> obj[0]["ads"]
xobj.data = obj[0].ads
end if
xobj.data[0].xid = m.getXid(xobj)
xobj.data[0].idid = xobj.id
end function
strmMgr.parsePodEnd = function(xmlstr as string, xobj as object) as void
ab = invalid
if invalid <> m.adBreakID and invalid <> m.adBreaks
ab = m.adBreaks[0]
if m.adBreakID <> ab.xid or 0 < ab.tracking.count() 
ab = invalid                                    
end if                                              
end if
if invalid <> ab and m.PLACEHOLDERPOD = ab.xid
m.sdk.log("parsePodEnd() stream must have begun in the middle of AdPod", 17)
podend = m.parseMultiVMAP(xmlstr)
if 0 < podend.tracking.count()
for each trck in podend.tracking
if "PodComplete" = trck.event
ab.tracking.push(trck)
end if
end for
ab.xid = m.getXid(xobj)
m.adBreakID = ab.xid  
end if
end if
end function
strmMgr.parseMultiVMAP = function(xmlstr) as object
adBreak = {rendersequence:"midroll", renderTime:0, tracking:[], viewed:false, ads:[]}
token = "</vmap:VMAP>"
vmaps = xmlstr.split(token)
m.sdk.log(["parseMultiVMAP() XML: ", xmlstr], 19)
m.sdk.log(["parseMultiVMAP() token spilt: ", vmaps.count().tostr()], 80)
if 0 < vmaps.count()
adIface = m.sdk.getRokuAds()
for each vmap in vmaps
if 11 <= len(vmap)
obj = adIface.parser.parse(vmap + token, "")
if invalid <> obj and invalid <> obj["adpods"] and 0 < obj.adpods.count()
ab = obj.adpods[0]
if invalid <> ab["tracking"] and 0 < ab.tracking.count()
for each trck in ab.tracking
if "Pod" = trck.event.left(3)
adBreak.tracking.push(trck)
end if
end for
end if
end if
end if
end for
end if
m.sdk.log(["parseMultiVMAP() adBreak tracking count: ", adBreak.tracking.count().tostr()], 11)
return adBreak
end function
vodloader = rafssai["vodloader"]
vodloader.requestPreplay = function(requestObj as object) as dynamic
m.strmURL = requestObj.url           
prplyInfo = {mediaURL:requestObj.url}
return prplyInfo
end function
return rafssai
end function
function RAFX_SSAI(params as object) as object
    if invalid <> params and invalid <> params["name"]
        p = {__version__:"0.0.0"}
        if "xmkr" = params["trackingmode"] or "hls" = params["trackingmode"]
            p = RAFX_getAdobeHLSPlugin(params)'
        else if "simple" = params["trackingmode"]'
            p = RAFX_getAdobeSimplePlugin(params)'
        end if
        p["__version__"] = "0b.42.36.15"
        p["__name__"] = params["name"]
        return p
    end if
end function
