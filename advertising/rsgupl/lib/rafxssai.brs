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
function RAFX_getUplynkPlugin(params as dynamic) as Object
rafssai = RAFX_getSSAIPluginBase(params)
impl = rafssai["impl"]
impl.uplynkToRAFEvent = {
"impressions" : rafssai.AdEvent.IMPRESSION
"firstquartiles" : rafssai.AdEvent.FIRST_QUARTILE
"midpoints" : rafssai.AdEvent.MIDPOINT
"thirdquartiles" : rafssai.AdEvent.THIRD_QUARTILE
"completes" : rafssai.AdEvent.COMPLETE
}
impl.uplynkToRAFEventPod = {
"impressions" : rafssai.AdEvent.POD_START
"completes" : rafssai.AdEvent.POD_END
}
impl.getStreamInfo = function() as object
if m.prplyInfo <> invalid
return {
prefix: m.prplyInfo["prefix"],
sid: m.prplyInfo["sid"],
playURL: m.prplyInfo["playURL"]
}
end if
return {}
end function
impl.setStreamInfo = function(streamInfo as object) as void
if invalid = m["prplyInfo"] then m.prplyInfo = {}
for each key in ["prefix","sid","pingURL","ads"]
if invalid <> streamInfo[key]
m.prplyInfo[key] = streamInfo[key]
end if
end for
m.prplyInfo["strmType"] = m.sdk.StreamType.LIVE
if invalid <> streamInfo["type"]
m.prplyInfo["strmType"] = streamInfo["type"]
end if
m.loader = m.createLoader(m.prplyInfo.strmType)
m.loader.composePingURL(m.prplyInfo)
end function
impl.enableAdsBase = impl.enableAds
impl.enableAds = function(params as object) as void
m.enableAdsBase(params)
if m.useStitched and m.prplyInfo.strmType = m.sdk.StreamType.LIVE
player = params["player"]
selected = false
skeys = []
for each key in player.sgnode.timedMetaDataSelectionKeys
if key = m.streamManager.TXXX or key = "*"
selected = true
exit for
else
skeys.push(key)
end if
end for
if not selected
skeys.push(m.streamManager.TXXX)
player.sgnode.timedMetaDataSelectionKeys = skeys
end if
player.sgnode.observeField("timedMetaData", player.port)
end if
end function
impl.onMetadata = function(msg as object) as void
if not m.useStitched then return
ret = m.streamManager.onMetadata(msg)
if ret["shortDuration"]
if invalid <> m.pingInfo and invalid <> m.pingInfo["next_time"] and m.streamManager.crrntPosSec < m.pingInfo.next_time
next_time = m.streamManager.crrntPosSec + m.streamManager.SLICE_SIZE
if next_time < m.pingInfo.next_time then m.pingInfo.next_time = next_time
end if
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
if invalid <> m.pingInfo and invalid <> m.pingInfo["ads"]
obj = m.upl2raf(m.pingInfo.ads)
if 0 = obj["adBreaks"].count() then return obj
pod = obj["adBreaks"][0]
if m.streamManager.crrntPosSec < pod.renderTime
return obj
else
m.streamManager.appendPod(pod)
end if
else if invalid <> m.prplyInfo["ads"]
obj = m.upl2raf(m.prplyInfo.ads)
m.prplyInfo.delete("ads")
return obj
end if
else if m.prplyInfo.strmType = m.sdk.StreamType.VOD and invalid <> m.prplyInfo["ads"]
return m.upl2raf(m.prplyInfo.ads)
end if
else
end if
return {adOpportunities:0, adBreaks:[]}
end function
impl.upl2raf = function(ads as object) as object
adOpportunities = 0
rafBreaks = []
if ads["breaks"] <> invalid
for each upBreak in ads.breaks
adBreak = {
viewed: false,
renderTime: 0.0,
renderSequence: "",
duration: 0.0,
tracking: [],
ads: []
}
adBreak.duration = upBreak.duration
adBreak.renderSequence = upBreak.position
adBreak.renderTime = upBreak.timeOffset
if upBreak["events"] <> invalid
m.parseEvents(adBreak.tracking, upBreak.events, m.uplynkToRAFEventPod)
end if
if upBreak["ads"] <> invalid
m.parseAds(adBreak, upBreak.ads)
end if
if 0 < adBreak.ads.count()
rafBreaks.push(adBreak)
adOpportunities += adBreak.ads.count()
end if
end for
end if
return {adOpportunities:adOpportunities, adBreaks:rafBreaks}
end function
impl.parseAds = function(adBreak as object, srcads as object) as void
timeOffset = adBreak.renderTime
for each ad in srcads
rAd = {
adid: ad.creative,    
duration: ad.duration,
streamFormat: "",
adServer: m.strmURL,
streams: [],
tracking: []
}
if ad["events"] <> invalid
m.parseEvents(rAd.tracking, ad.events, m.uplynkToRAFEvent)
m.sdk.setTrackingTime(timeOffset, rAd)
end if
apiFramework = ad["apiFramework"]
if invalid <> apiFramework
m.parseInteractive(apiFramework, rAd, ad)
rAd.tracking.sortby("time")
else if ad["mimeType"] <> invalid and right(ad["mimeType"], 5) = "/m3u8"
rAd.streamFormat = "hls"
end if
adBreak.ads.push(rAd)
timeOffset += rAd.duration
end for
end function
impl.parseCompanions = function(apiFramework as string, companions as object) as object
companionAds = []
for each ca in companions
if ca["mimeType"] = "application/json"
rca = {
mimetype: ca.mimeType,
provider: ca["apiFramework"],
url: ca["creative"],
width: ca["width"],
height: ca["height"],
tracking: []
}
if invalid = rca.provider
rca.provider = apiFramework
end if
if invalid <> ca["events"]
m.parseEvents(rca.tracking, ca.events, m.uplynkToRAFEvent)
end if
companionAds.push(rca)
end if
end for
return companionAds
end function
impl.parseInteractive = function(apiFramework as string, rAd as object, ad as object) as void
apiFramework = LCase(apiFramework)
if apiFramework = "innovid" or apiFramework = "iroll"
if invalid <> ad["companions"] and 0 < ad.companions.count()
streams = m.parseCompanions(apiFramework, ad.companions)
if 0 < streams.count()
rAd["streamFormat"] = "iroll"
rAd["streams"] = streams
if 1 = streams.count()
rAd["adserver"] = streams[0].url
end if
rAd["companionAds"] = []
end if
else if invalid <> ad["creative"]
rAd["streamFormat"] = "iroll"
rAd["streams"] = [{url: ad.creative}]
end if
else if left(apiFramework,10) = "brightline"
if invalid <> ad["companions"] and 0 < ad.companions.count()
companionAds = m.parseCompanions(apiFramework, ad.companions)
if 0 < companionAds.count()
rAd.streamFormat = apiFramework
rAd.companionAds = companionAds
rAd.streams = [{url:""}]
end if
end if
end if
end function
impl.parseEvents = function(destObj as object, events as object, eventMap as object) as void
if type(events) = "roAssociativeArray"
for each key in events
eventName = eventMap[key]
if invalid = eventName
eventName = key  
end if
if "roArray" = type(events[key])
for each url in events[key]
rafEvent = {event:eventName, url:url, triggered:false}
destObj.push(rafEvent)
end for
end if
end for
else if type(events) = "roArray"
for each adobj in events
if adobj["events"] <> invalid
m.parseEventObj(destObj, adobj.events)
end if
end for
end if
end function
impl.onPositionBase = impl.onPosition
impl.onPosition = function (msg as object) as void
if m.streamManager.crrntPosSec = -1
if invalid <> m.loader then m.loader.ping(invalid)
m.pingInfo = invalid
end if
m.onPositionBase(msg)
end function
impl.parsePing = function() as void
jsn = m.loader.getPingResponse()
if invalid <> jsn and "" <> jsn
pingInfo = parsejson(jsn)
if pingInfo <> invalid
m.pingInfo = pingInfo
end if
end if
end function
impl.onMessageLIVE = function(msg as object, curAd as object) as void
if m.sdk.StreamType.LIVE <> m.prplyInfo.strmType then return
posSec = msg.getData()
if m.streamManager.pastLastAdBreak(posSec)
m.streamManager.createTimeToEventMap(invalid)
end if
if invalid <> m.pingInfo
m.pingInfo["ads"] = invalid
end if
m.parsePing()
if invalid <> m.pingInfo and invalid <> m.pingInfo["ads"]
m.setRAFAdPods()
end if
if m.shouldPing(posSec)
m.loader.ping({position:posSec})
end if
end function
impl.shouldPing = function(posSec as float) as boolean
if m.loader.hasPinged() then return false
pingThreshold = 1
itis = createObject("roDateTime").asSeconds()
if invalid = m.pingInfo or invalid = m.pingInfo["ads"] and invalid = m.pingInfo["next_time"]
if invalid <> m.prplyInfo["ads"] and invalid <> m.prplyInfo.ads["breaks"]
for each brk in m.prplyInfo.ads.breaks
if invalid <> brk["ts"] and itis < brk.ts and brk.ts - itis < pingThreshold
return true
end if
end for
end if
else if invalid <> m.pingInfo["next_time"] and m.pingInfo.next_time < posSec
return -1 <> m.pingInfo.next_time
end if
return false
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
strmMgr.TXXX = "TXXX"     
strmMgr.PTS = "_decodeInfo_pts"
strmMgr.ADS_COUNT = 16    
strmMgr.SLICE_SIZE = 4.096
strmMgr.last_pts = 0
strmMgr.onMetadata = function(msg as object) as object
ret = {shortDuration:false, pendingPod:invalid}
if "timedMetaData" <> msg.getField() then return ret
obj = msg.getData()
if invalid = obj[m.TXXX] or "" = obj[m.TXXX] then return ret
asset_ray_slice = obj[m.TXXX].split("_")
assetId = asset_ray_slice[0]
m.last_pts = obj[m.PTS]
if invalid = m.lastAssetId
if invalid <> m.currentAdBreak
end if
m.lastAssetId = assetId
end if
if invalid <> m.currentAdBreak
ret["shortDuration"] = m.compareAssetId(asset_ray_slice, obj)
else if invalid <> m.pendingPod
idx = -1
for i=0 to m.pendingPod.ads.count()-1
if assetId = m.pendingPod.ads[i]["adid"]
idx = i
exit for
end if
end for
if 0 <= idx
if 0 < idx
i = 0
while i < idx
m.pendingPod.ads.shift()
m.pendingPod.ads.push( m.emptyAd() )
i += 1
end while
end if
m.pendingPod.renderTime = obj[m.PTS]
timeOffset = m.pendingPod.renderTime
for each ad in m.pendingPod.ads
m.sdk.setTrackingTime(timeOffset, ad)
timeOffset += ad.duration
end for
m.pendingPod.duration = timeOffset - m.pendingPod.renderTime
ret["pendingPod"] = m.pendingPod
m.pendingPod = invalid
end if
end if
return ret
end function
strmMgr.compareAssetId = function(asset_ray_slice as object, msgobj as object) as boolean
ret = false
pts = msgobj[m.PTS]
if pts - m.currentAdBreak.renderTime < m.SLICE_SIZE then return ret
assetId = asset_ray_slice[0]
sliceId = val("0x"+asset_ray_slice[2])
if m.lastAssetId <> assetId  or  0 = sliceId
m.lastAssetId = assetId
adIdx = -1
for each ad in m.currentAdBreak.ads
adIdx += 1
if assetId = ad["adid"]
if 0 = adIdx and invalid <> pts and m.currentAdBreak.renderTime < pts and 1 < m.currentAdBreak.ads.count()
timeOffset = 0.2 + pts - m.SLICE_SIZE * sliceId
if timeOffset < 0 then timeOffset = 0
m.currentAdBreak.renderTime = timeOffset
for i=1 to m.currentAdBreak.ads.count()-1
a = m.currentAdBreak.ads[i]
m.sdk.setTrackingTime(timeOffset, a)
timeOffset += a.duration
end for
end if
return ret
end if
end for
actualDuration = m.lastPosSec - m.currentAdBreak.renderTime
if 0 < actualDuration
m.currentAdBreak.duration = actualDuration
else
m.currentAdBreak.duration = 1
end if
ret = true
m.adTimeToBeginEnd = invalid
m.adTimeToEventMap = m.appendBreakEnd({}, int(m.crrntPosSec+1).tostr())
end if
return ret
end function
strmMgr.appendAdToBreak = function(newPod as object, destPod as object) as void
adsNotAppended = []
for each rAd in newPod.ads
timeOffset = destPod.renderTime
appended = false
for i=0 to destPod.ads.count()-1
currentAd = destPod.ads[i]
if invalid = currentAd["adid"]
m.sdk.setTrackingTime(timeOffset, rAd)
destPod.ads[i] = rAd            
destPod.duration += rAd.duration
appended = true
exit for
else if rAd["adid"] = currentAd["adid"]
appended = true     
exit for
end if
timeOffset += currentAd.duration
end for
if not appended then adsNotAppended.push(rAd)
end for
newPod.ads = adsNotAppended
end function
strmMgr.appendPod = function (newPod as object) as object
if invalid <> m.currentAdBreak
m.appendAdToBreak(newPod, m.currentAdBreak)
end if
if invalid <> m.pendingPod
m.appendAdToBreak(newPod, m.pendingPod)
end if
if 0 < newPod.ads.count()
while newPod.ads.count() < m.ADS_COUNT
newPod.ads.push( m.emptyAd() )
end while
m.pendingPod = newPod
end if
end function
strmMgr.emptyAd = function () as object
return {
adid: invalid,    
duration: 0,
streamFormat: "",
adServer: ""
streams: [],
tracking: []
}
end function
liveloader = rafssai["liveloader"]
liveloader.requestPreplay = function(requestObj as object) as string
if not m.isValidString(m.strmURL)
m.strmURL = requestObj.url
end if
itis = m.dateTime.asSeconds()
if 0 < m.strmURL.instr("cping=1")
url = m.strmURL
else if 0 < m.strmURL.instr("ts=")
url = substitute("{0}&ad.cping=1&ad.pingf=5", m.strmURL)
else
m.lastEndTs = itis + m.tsDuration
url = substitute("{0}&ad.cping=1&ad.pingf=5&ts={1}&endts={2}", m.strmURL, itis.tostr(), (m.lastEndTs).tostr())
end if
s = m.getJSON({url:url})
return s
end function
liveloader.ping = function(params as dynamic) as void
if "" = m.pingURL then return
url = m.pingURL
if invalid = params or invalid = params["position"]
url = substitute("{0}&ev=start&pt=0", url)
else if invalid <> params["position"]
url = substitute("{0}&pt={1}", url, params["position"].tostr())
end if
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
print "<> <> <> liveloader.getPingResponse() hstat: ";hstat.tostr()
end if
m.isPinging = false
end if
return res
end function
liveloader.PINGV2 = "{0}/session/ping/{1}.json?v=2"
liveloader.PINGV3 = "{0}/api/v3/ping/ad/{1}.json?v=3"
liveloader.composePingURL = function(prplyInfo as object) as void
if invalid <> prplyInfo["pingURL"]
m.pingURL = prplyInfo.pingURL
else if invalid <> prplyInfo.sid and invalid <> prplyInfo.prefix
pingfmt = m.PINGV2
if invalid <> m.strmURL and 0 < m.strmURL.inStr("/api/v3")
pingfmt = m.PINGV3
end if
m.pingURL = substitute(pingfmt, prplyInfo.prefix, prplyInfo.sid)
end if
end function
return rafssai
end function
function RAFX_SSAI(params as object) as object
    if invalid <> params and invalid <> params["name"]
        p = RAFX_getUplynkPlugin(params)
        p["__version__"] = "0b.42.30"
        p["__name__"] = params["name"]
        return p
    end if
end function
