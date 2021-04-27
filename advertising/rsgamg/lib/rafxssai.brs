' ********** Copyright 2021 Roku, Inc.  All Rights Reserved. **********
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
if invalid <> params.RIA
m.RIA = params.RIA
end if
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
impl.onUnknown = function(msg as object) as void
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
else if invalid <> msg and msgType = m.sdk.msgType.UNKNOWN 
m.onUnknown(msg)
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
impl.isnonemptystr = function(obj) as boolean
return ((obj <> invalid) and (GetInterface(obj, "ifString") <> invalid) and (len(obj) > 0))
end function
impl.setRIAParameters = function(rAd as object, srcAd as object) as void
if m.useStitched
if m.isnonemptystr(srcAd.adParameters) then
rAd.adParameters = srcAd.adParameters
return
else if invalid <> m.RIA and invalid <> m.RIA.getAdParameters
rAd.adParameters = m.RIA.getAdParameters()
end if
end if
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
obj.nukeTimeToEventMap = false
return obj
end function
strmMgr = {}
strmMgr.addEventToEvtMap = function(timeToEvtMap as object, timeKey as string, evtStr as dynamic) as void
evtType = type(evtStr)
if "String" = evtType or "roString" = evtType
m.addEventToEvtMapString(timeToEvtMap, timeKey, evtStr)
else
for each x in evtStr
m.addEventToEvtMapString(timeToEvtMap, timeKey, x)
end for
end if
end function
strmMgr.addEventToEvtMapString = function(timeToEvtMap as object, timeKey as string, evtStr as string) as void
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
strmMgr.trackingToMap = function(tracking as object, timeToEvtMapGiven=invalid as object) as boolean
timeToEvtMap = timeToEvtMapGiven
if invalid = timeToEvtMap
timeToEvtMap = m.adTimeToEventMap
end if
hasCompleteEvent = false
for each evt in tracking
if invalid <> evt["time"]
timeKey = int(evt.time).tostr()
m.addEventToEvtMap(timeToEvtMap, timeKey, evt.event)
if m.sdk.AdEvent.COMPLETE = evt.event
hasCompleteEvent = true
end if
end if
end for
return hasCompleteEvent
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
hasCompleteEvent = m.trackingToMap(rAd.tracking, timeToEvtMap)
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
if m.nukeTimeToEventMap
m.adTimeToEventMap.delete(timeKey)
end if
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
ddttm = createObject("roDateTime")
dtm = ["SDK (", ddttm.toISOString().split("T")[1], " ", ddttm.getMilliseconds().tostr(), "): "].join("")
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
function RAFX_getAmagiHLSAdapter(params as object) as Object
rafssai = RAFX_getSSAIPluginBase(params)
rafssai.HLSDir = {
EXT_X_AD_START : "#EXT-X-AD-START:",
EXT_X_AD_END : "#EXT-X-AD-END"
}
impl = rafssai["impl"]
impl.amagiToRAFEventPod = {
"Impression" : rafssai.AdEvent.POD_START,
"Complete"   : rafssai.AdEvent.POD_END
}
impl.amagiToRAFEvent = {
"start" : rafssai.AdEvent.IMPRESSION
"creativeView" : rafssai.AdEvent.IMPRESSION
"firstQuartile" : rafssai.AdEvent.FIRST_QUARTILE
"midpoint" : rafssai.AdEvent.MIDPOINT
"thirdQuartile" : rafssai.AdEvent.THIRD_QUARTILE
"complete" : rafssai.AdEvent.COMPLETE
}
impl.runningPods = []
impl.setStreamInfo = function(streamInfo as object) as void
if invalid = m["prplyInfo"] then m.prplyInfo = {}
m.prplyInfo["strmType"] = m.sdk.StreamType.LIVE  
url = streamInfo.url
devInfo = createObject("roDeviceInfo")
url = url.replace("ROKU_ADS_TRACKING_ID", devInfo.getRIDA())
lat = "0"
if devInfo.isRIDADisabled() then lat = "1"
url = url.replace("ROKU_ADS_LIMIT_TRACKING", lat)
m.prplyInfo["mediaURL"] = url
streamInfo.url = url
m.loader = m.createLoader(m.prplyInfo.strmType)
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
m.useStitched = (true = params.useStitched)
if not ei
return
end if
player.sgnode.timedMetaDataSelectionKeys = [m.sdk.HLSDir.EXT_X_AD_START, m.sdk.HLSDir.EXT_X_AD_END]
player.sgnode.observeField("timedMetaData2", player.port)
player.sgnode.observeField("streamingSegment", player.port)
if invalid = m.streamManager
m.streamManager = m.sdk.createStreamManager()
m.streamManager.mediaURL = m.prplyInfo["mediaURL"]
m.streamManager.nukeTimeToEventMap = true
end if
if invalid <> params.RIA
m.RIA = params.RIA
end if
end function
impl.onMetadata = function(msg as object) as void
xobj = m.streamManager.onMetadata(msg, m.useStitched, m.wrpdPlayer.sgnode)
if invalid <> xobj then
if invalid <> xobj.url and 4 < len(xobj.url) then
m.loader.setPingUrl(xobj.url)
m.xobj = xobj
m.pendingPods = invalid
end if
end if
end function
impl.parsePods = function(adPods as object) as object
pods = []
lacmsn = -2
for each amgPod in adPods
adBreak = {}
toAppendPod = (invalid = amgPod.tracking) and (amgPod.renderMediaSequenceNo = (lacmsn + 1))
if toAppendPod and 0 < pods.count() then
adBreak = pods.peek()
else
adBreak = m.parseNewPod(amgPod)
pods.push(adBreak)
end if
ret = m.parseAds(adBreak, amgPod.ads)
if toAppendPod then
adBreak.duration += amgPod.duration
end if
lacmsn = ret.lastAdCompleteMediaSequenceNumber
end for
return pods
end function
impl.parseNewPod = function(amgPod as object) as object
adBreak = {
viewed: false,
renderTime: -1.0,
renderSequence: "midroll",
duration: 0.0,
tracking: [],
ads: []
}
adBreak.id = amgPod.renderMediaSequenceNo.toStr()
adBreak.duration = amgPod.duration
adBreak.renderSequence = amgPod.renderSequence
adBreak.renderMediaSequenceNo = amgPod.renderMediaSequenceNo
if invalid <> amgPod.tracking
for each ev in amgPod.tracking
eventKey = m.amagiToRAFEventPod[ev.event]
if invalid = eventKey then eventKey = ev.event
adBreak.tracking.push({
event: eventKey,
url: ev.url,
triggered: false
})
end for
end if
return adBreak
end function
impl.parseAds = function(adBreak as object, amgAds as object) as object
lacmsn = -2
for each ad in amgAds
rAd = {
adid: ad.adId.tostr(),
duration: ad.duration,
streamFormat: "",
adServer: m.loader.pingURL,
streams: [],
tracking: []
}
if invalid <> ad.tracking
for each ev in ad.tracking
eventKey = m.amagiToRAFEvent[ev.event]
if invalid = eventKey then eventKey = ev.event
rAd.tracking.push({
event: eventKey,
url: ev.url,
triggered: false,
mediaSequenceNumber : ev.mediaSequenceNumber
})
if "complete" = ev.event then
lacmsn = ev.mediaSequenceNumber
end if
end for
end if
m.setRIAParameters(rAd, ad)
adBreak.ads.push(rAd)
end for
return {lastAdCompleteMediaSequenceNumber:lacmsn}
end function
impl.amagi2raf = function(adPods as object, signature as String) as boolean
ret = False
pods = m.parsePods(adPods)
if pods.count() = 0 then return ret
if invalid = m.pendingPods
m.pendingPods = pods
else
m.pendingPods.append(pods)
end if
if m.pendingPods[0].renderTime < 0
pod = m.pendingPods[0]
seg = m.wrpdPlayer.sgnode.streamingSegment
if pod.renderMediaSequenceNo <= seg.segSequence+1
m.streamManager.setPodRenderTime(pod, {startTime:seg.segStartTime, delta:0})
ret = True
end if
end if
return ret
end function
impl.parsePing = function() as boolean
ret = False
jsn = m.loader.getPingResponse()
if invalid <> jsn and "" <> jsn
resObj = parsejson(jsn)
if resObj <> invalid
if invalid <> resObj.RetryAfter
if -1 = resObj.RetryAfter
m.loader.setPingUrl("")
else
m.loader.retryAfter = resObj.RetryAfter
end if
end if
if invalid <> resObj.adPods and 0 < resObj.adPods.count()
ret = m.amagi2raf(resObj.adPods, resObj.signature)
end if
end if
end if
return ret
end function
impl.rollPod = function(readyPod as object) as void
if m.useStitched then
m.runningPods.push(readyPod)
if 1 = m.runningPods.count()
m.setRAFAdPods(m.runningPods)
else
m.streamManager.createTimeToEventMap([readyPod])
end if
else
m.streamManager.createTimeToEventMap([readyPod])
end if
end function
impl.onUnknown = function(msg as object) as void
if "streamingSegment" = msg.getField()
if invalid <> m.pendingPods and 0 < m.pendingPods.count()
if m.streamManager.onSegment(msg.getData(), m.pendingPods, m.runningPods)
readyPod = m.pendingPods.shift()
m.rollPod(readyPod)
end if
end if
if invalid = m.pendingPods or m.pendingPods.count() < 1
m.pendingPods = invalid
end if
end if
end function
impl.onMessageLIVE = function(msg as object, curAd as object) as void
if m.sdk.StreamType.LIVE <> m.prplyInfo.strmType then return
if invalid = m.pendingPods
posSec = msg.getData()
if m.streamManager.pastLastAdBreak(posSec)
m.streamManager.createTimeToEventMap(invalid)
if 0 < m.runningPods.count() then
m.runningPods = []
end if
end if
end if
if m.parsePing() then
if invalid <> m.pendingPods and 0 < m.pendingPods.count() and 0 < m.pendingPods[0].renderTime then
readyPod = m.pendingPods.shift()
m.rollPod(readyPod)
end if
end if
if m.loader.shouldPing()
m.loader.ping()
end if
end function
strmMgr = rafssai["streamManager"]
strmMgr.onMetadata = function(msg as object, useStitched as boolean, sgnode as object) as object
xobj = invalid
obj = msg.getData()
msgfld = msg.getField()
data = invalid
if "timedMetaData2" = msgfld then
position = obj["position"]
if invalid <> obj.data then
if invalid <> obj.data[m.sdk.HLSDir.EXT_X_AD_START]
data = obj.data[m.sdk.HLSDir.EXT_X_AD_START]
else if invalid <> obj.data[m.sdk.HLSDir.EXT_X_AD_END]
if invalid <> m.currentAdBreak
endAt = m.currentAdBreak.renderTime + m.currentAdBreak.duration
if position + 4 < endAt then
m.currentAdBreak.duration -= (endAt - position)
endAt = m.currentAdBreak.renderTime + m.currentAdBreak.duration
timeKey = int(endAt+1).tostr()
m.adTimeToEventMap = {}
m.adTimeToEventMap[timeKey] = [m.sdk.AdEvent.POD_END]
end if
end if
end if
end if
end if
if invalid <> data then
xobj = m.parseXAdStart(obj.data[m.sdk.HLSDir.EXT_X_AD_START])
end if
return xobj
end function
strmMgr.adjustPodRenderTime = function(segStartTime as double, runningPods) as double
startTimeDelta = 0.0
if invalid = m.currentAdBreak or 0 = runningPods.count() then return startTimeDelta
curPod = m.currentAdBreak
podEnd = curPod.renderTime + curPod.duration
if podEnd < m.crrntPosSec then return startTimeDelta
adjustedStartTime = podEnd + 0.5
if adjustedStartTime < segStartTime then return startTimeDelta
startTimeDelta = adjustedStartTime - segStartTime
return startTimeDelta
end function
strmMgr.lastSegStartTime = -1
strmMgr.assertSegStartTime = function(data) as Boolean
if invalid <> data.segStartTime
if data.segStartTime < m.lastSegStartTime
print "WARNING: strmMgr.assertSegStartTime() segStartTime goes backward."
end if
m.lastSegStartTime = data.segStartTime
end if
return true
end function
strmMgr.setPodRenderTime = function(pendingPod as object, params as object)
pendingPod.renderTime = params.startTime
delta = params.delta
if 0 < delta then
pendingPod.duration = pendingPod.duration - delta
pendingPod.ads[0].duration = pendingPod.ads[0].duration - delta
end if
timeOffset = pendingPod.renderTime
m.sdk.setTrackingTime(timeOffset, pendingPod)
timeOffset = pendingPod.renderTime
for each ad in pendingPod.ads
m.sdk.setTrackingTime(timeOffset, ad)
timeOffset += ad.duration
end for
end function
strmMgr.onSegment = function(data as object, pendingPods as object, runningPods as object) as boolean
if invalid = pendingPods then return false
if 0 <> data.segType and 2 <> data.segType then return false
m.assertSegStartTime(data)
pendingPod = pendingPods[0]
if pendingPod.renderTime < 0 and data.segSequence+1 = pendingPod.renderMediaSequenceNo
delta = m.adjustPodRenderTime(data.segStartTime, runningPods)
startTime = data.segStartTime + delta
m.setPodRenderTime(pendingPod, {startTime:startTime, delta:delta})
if false
nextEventPosition = int(m.crrntPosSec + 1)
if int(pendingPod.renderTime) < nextEventPosition
pendingPod.renderTime = nextEventPosition
end if
m.createTimeToEventMap([pendingPod])
pendingPod.renderTime = startTime
end if
return true
end if
return false
end function
strmMgr.getSortedKeys = function(objin as object) as object
tmKeys = objin
if "roAssociativeArray" = type(objin)
tmKeys = objin.keys()
end if
if 1 = tmKeys.count() then return [tmKeys[0].toInt()]
tmKeysInt = []
for each k in tmKeys
tmKeysInt.push(k.toInt())
end for
tmKeysInt.sort()
return tmKeysInt
end function
strmMgr.createTimeToEventMapBase = strmMgr.createTimeToEventMap
strmMgr.createTimeToEventMap = function(adBreaks as object) as Void
if invalid = adBreaks or invalid = m.adTimeToEventMap or 0 = m.adTimeToEventMap.count()
m.createTimeToEventMapBase(adBreaks)
if invalid <> adBreaks
end if
else
timeToEventMap = m.adTimeToEventMap
timeKeys = timeToEventMap.keys()
m.createTimeToEventMapBase(adBreaks)
if 0 < timeKeys.count()
tmKeysIncoming = m.getSortedKeys(m.adTimeToEventMap)
earliestAt = tmKeysIncoming[0]
tmKeysRunning = m.getSortedKeys(timeKeys)
if 1 < tmKeysRunning.count() then tmKeysRunning.reverse()
for each k in tmKeysRunning
kstr = k.tostr()
mapVal = timeToEventMap[kstr]
if earliestAt < k  
k = earliestAt 
kstr = k.tostr()
end if
if m.adTimeToEventMap.doesExist(kstr)
mapVal.append(m.adTimeToEventMap[kstr])
else
earliestAt = k
end if
m.adTimeToEventMap[kstr] = mapVal
end for
end if
end if
end function
strmMgr.rgx_breakdur = createObject("roRegEx", "BREAKDUR=([\d+[\.\d+]*)", "")
strmMgr.rgx_uri = createObject("roRegEx", "URI=" + chr(34) + "(https?://[^\s]+)", "")
strmMgr.extract = function(s as string, rgx as object, defaultval as dynamic) as dynamic
matches = rgx.match(s)
if invalid <> matches and  1 < matches.count()
return matches[1]
end if
return defaultval
end function
strmMgr.parseXAdStart = function(ext_x_ad as string) as object
xobj = {
breakdur: m.extract(ext_x_ad, m.rgx_breakdur, "0").toInt(),
url: ""
}
url = m.extract(ext_x_ad, m.rgx_uri, "")
if url.right(1) = chr(34)
url = url.left(len(url)-1)
end if
xobj.url = url
return xobj
end function
strmMgr.appendEvtMap = function(rAd as Object)
end function
liveloader = rafssai["liveloader"]
liveloader.pingURL = ""
liveloader.isPinging = false
liveloader.pingPort = createObject("roMessagePort")
liveloader.last_ping = 0
liveloader.retryAfter = 30
liveloader.setPingUrl = function(url as string) as void
m.last_ping = 0
m.isPinging = false
m.pingURL = url
end function
liveloader.ping = function() as void
if "" = m.pingURL then return
url = m.pingURL
m.pingXfer = m.sdk.createUrlXfer(m.sdk.httpsRegex.isMatch(url))
m.pingXfer.setMessagePort(m.pingPort)
m.pingXfer.setUrl(url)
m.pingXfer.addHeader("Accept", "application/json")
m.pingXfer.asyncGetToString()
m.isPinging = true
m.last_ping = createObject("roDateTime").asSeconds()
end function
liveloader.shouldPing = function() as boolean
if "" = m.pingUrl then return false
if m.isPinging then return false
return (m.last_ping + m.retryAfter) < createObject("roDateTime").asSeconds()
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
return rafssai
end function
function RAFX_SSAI(params as object) as object
    if invalid <> params and invalid <> params["name"]
        p = RAFX_getAmagiHLSAdapter(params)
        p["__version__"] = "0b.44.5"
        p["__name__"] = params["name"]
        return p
    end if
end function
