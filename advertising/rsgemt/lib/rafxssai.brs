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
if invalid <> params.IROLL
m.IROLL = params.IROLL
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
if msgType = m.sdk.msgType.METADATA
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
m.sdk.log("All video is completed - full result. Last pos: "+m.streamManager.crrntPosSec.tostr())
m.streamManager.deinit({curAd:curAd, strmEnd:m.sgnode.duration, strmType:m.prplyInfo.strmType})
m.sdk.eventCallbacks.doCall(m.sdk.AdEvent.STREAM_END, {})
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
impl.setIRollParameters = function(rAd as object) as void
if m.useStitche and invalid <> m.IROLL and invalid <> m.IROLL.getIRollAd
rAd.append(m.IROLL.getIRollAd())
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
mapList = timeToEvtMap[timeKey]
eExist = false
for each e in mapList
eExist =   eExist or (e = evtStr)
end for
if not eExist
mapList.push(evtStr)
if m.sdk.AdEvent.COMPLETE = evtStr and 1 < mapList.count() and m.sdk.AdEvent.POD_END = mapList[0]
mapList.sort()
end if
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
podstartevts = [m.sdk.AdEvent.POD_START]
if 0 < adBreak.ads.count() then podstartevts.push(m.sdk.AdEvent.IMPRESSION)
timeToEvtMap[brkTimeKey] = podstartevts
timeToBreakMap[brkTimeKey] = adBreak
adRenderTime = adBreak.renderTime
brkEnd = int(adBreak.renderTime+adBreak.duration)
for each rAd in adBreak.ads
hasCompleteEvent = m.trackingToMap(rAd.tracking, timeToEvtMap)
adRenderTime = adRenderTime + rAd.duration
if not hasCompleteEvent and 0 < rAd.tracking.count() and 0 < rAd.duration
if brkEnd < adRenderTime then adRenderTime = brkEnd
timeKey = int(adRenderTime - 0.5).tostr()
m.addEventToEvtMap(timeToEvtMap, timeKey, m.sdk.AdEvent.COMPLETE)
end if
end for
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
strmMgr.adBreakEnded = function(params as object) as boolean
return ((invalid <> params.endAt and params.endAt < m.crrntPosSec) or (invalid <> m.adBreakEndedId and invalid <> params.id and m.adBreakEndedId = params.id))
end function
strmMgr.cleanupAdBreakInfo = function(triggered=false as boolean) as void
if m.currentAdBreak <> invalid
m.updateAdBreakEvents(m.currentAdBreak, triggered)
m.adBreakEndedId = m.currentAdBreak.id
end if
m.whenAdBreakStart = -1
m.currentAdBreak = invalid
m.lastEvents = {}
end function
strmMgr.deinit = function(params as object) as void
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
daisdk.setTrackingTime = function(timeOffset as float, rAd as object, capComplete=-1 as integer) as void
duration = rAd.duration
for each evt in rAd.tracking
if evt.event = m.AdEvent.IMPRESSION or evt.event = m.AdEvent.POD_START
evt.time = 0.0 + timeOffset
else if evt.event = m.AdEvent.FIRST_QUARTILE
evt.time = duration * 0.25 + timeOffset
else if evt.event = m.AdEvent.MIDPOINT
evt.time = duration * 0.5 + timeOffset
else if evt.event = m.AdEvent.THIRD_QUARTILE
evt.time = duration * 0.75 + timeOffset
else if evt.event = m.AdEvent.COMPLETE or evt.event = m.AdEvent.POD_END
evt.time = duration + timeOffset
if 0.0 < capComplete and capComplete < evt.time then evt.time = capComplete
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
function RAFX_getEMTAdapter(params as dynamic) as Object
rafssai = RAFX_getSSAIPluginBase(params)
impl = rafssai["impl"]
impl.emtToRAFEvent = {
"start" : rafssai.AdEvent.IMPRESSION
"impression" : rafssai.AdEvent.IMPRESSION
"firstQuartile" : rafssai.AdEvent.FIRST_QUARTILE
"midpoint" : rafssai.AdEvent.MIDPOINT
"thirdQuartile" : rafssai.AdEvent.THIRD_QUARTILE
"complete" : rafssai.AdEvent.COMPLETE
"breakStart" : rafssai.AdEvent.POD_START
"breakEnd" : rafssai.AdEvent.POD_END
}
impl.readUrlFromAA = function(aa as object, aakeys as object) as string
urlstr = ""
for each key in aakeys
if invalid <> aa[key]
urlstr = aa[key]
exit for
end if
end for
if "http" <> urlstr.left(4)
urlstr = m.loader.getBaseURL() + urlstr
end if
return urlstr
end function
impl.getStreamInfo = function() as object
if m.prplyInfo <> invalid
if invalid = m.prplyInfo["manifest_url"]
man_url = m.readUrlFromAA(m.prplyInfo, ["manifest", "manifestUrl"])
if invalid <> man_url
m.prplyInfo["manifest_url"] = man_url
end if
end if
if invalid = m.prplyInfo["tracking_url"]
tracking_url = m.readUrlFromAA(m.prplyInfo, ["tracking", "trackingUrl"])
if invalid <> tracking_url
m.prplyInfo["tracking_url"] = tracking_url
m.loader.composePingURL(m.prplyInfo)
end if
end if
if invalid <> m.prplyInfo["manifest_url"] then return m.prplyInfo
end if
return {error:"No Valid response"}
end function
impl.setStreamInfo = function(streamInfo as object) as void
if invalid = m["prplyInfo"] then m.prplyInfo = {}
for each key in ["tracking_url", "manifest_url"]
if invalid <> streamInfo[key]
m.prplyInfo[key] = streamInfo[key]
end if
end for
if invalid <> streamInfo["type"]
m.prplyInfo["strmType"] = streamInfo["type"]
end if
if invalid = m.loader or "" = m.loader.pingURL
m.loader = m.createLoader(m.prplyInfo.strmType)
end if
m.loader.composePingURL(m.prplyInfo)
end function
impl.parsePrplyInfo = function() as object
preroll = []
midroll = []
if invalid <> m.prplyInfo
if invalid <> m.pingInfo and invalid <> m.pingInfo["avails"]
obj = m.emt2raf(m.pingInfo.avails)
if 0 = obj["adBreaks"].count() then return obj
if m.sdk.StreamType.VOD = m.prplyInfo["strmType"]
preroll = obj["adBreaks"]
else
for each ab in obj.adBreaks
if ab.renderTime < 0.1
preroll.push(ab)
else
midroll.push(ab)
end if
end for
ret = m.streamManager.appendPods(midroll, m.MIN_AD_DUR, m.prplyInfo.strmType)
if ret.appendedToRunningPod
preroll = [m.streamManager.currentAdBreak]
else
m.noMorePingTilPodEnd(m.streamManager.currentAdBreak)
end if
m.streamManager.nukeTimeToEventMap = true
end if
end if
else
end if
return {adOpportunities:0, adBreaks:preroll}
end function
impl.noMorePingTilPodEnd =  function(cab as object)
if invalid <> cab then
adDurSum = 0
for each cad in cab.ads
adDurSum += cad.duration
end for
if (cab.renderTime + cab.duration * 0.75) < m.streamManager.crrntPosSec and abs(adDurSum - cab.duration) < m.MIN_AD_DUR
hasComplete = false
ad = cab.ads.peek()
for each evt in ad.tracking
if m.sdk.AdEvent.COMPLETE = evt.event
hasComplete = true
exit for
end if
end for
if hasComplete
m.last_ping = (cab.renderTime + cab.duration) + m.MIN_AD_DUR
print "<> <> <> impl.noMorePingTilPodEnd() set m.last_ping AFTER Pod End: ";m.last_ping;"  ads.count: ";cab.ads.count();"  DurationSum: ";adDurSum;"  HasCOMPLETE: ";hasComplete.tostr()
end if
end if
end if
end function
impl.BREAK_TOL = 1.002
impl.emt2raf = function(avails as object) as object
adOpportunities = 0
rafBreaks = []
periodStartSec = m.get1stPeriodStart()
for each emtBreak in avails
adBreak = {
viewed: false,
renderTime: 0.0,
renderSequence: "",
duration: 0.0,
tracking: [],
ads: []
}
m.parseEmtAdBreak(adBreak, emtBreak, periodStartSec)
if invalid <> emtBreak["ads"]
m.parseAds(adBreak, emtBreak.ads)
end if
if 0 < rafBreaks.count() and (0 < adBreak.ads.count() or 0 < adBreak.tracking.count())
lb = rafBreaks.peek()
start_end = adBreak.renderTime - (lb.renderTime + lb.duration)
if start_end < m.BREAK_TOL
if 0 < start_end
lb.ads[lb.ads.count()-1].duration += start_end
lb.duration += (start_end + adBreak.duration)
end if
lb.ads.append(adBreak.ads)
if 0 < adBreak.tracking.count() then
lb.tracking.append(adBreak.tracking)
adBreak.tracking = []
end if
adOpportunities += adBreak.ads.count()
adBreak.ads = []
end if
end if
if 0 < adBreak.ads.count() or 0 < adBreak.tracking.count()
rafBreaks.push(adBreak)
adOpportunities += adBreak.ads.count()
end if
end for
return {adOpportunities:adOpportunities, adBreaks:rafBreaks}
end function
impl.parseEmtAdBreak = function(adBreak as object, emtBreak as object, periodStartSec as float) as void
adBreak.segSeq = emtBreak.availId.toInt()
adBreak.id = emtBreak.availId
adBreak.duration = emtBreak.durationInSeconds
renderTime = emtBreak.startTimeInSeconds - periodStartSec
if abs(renderTime) < 0.1
adBreak.renderSequence = "preroll"
else
adBreak.renderSequence = "midroll"
end if
adBreak.renderTime = renderTime
if invalid <> emtBreak.adBreakTrackingEvents
adBreak.tracking = []
for each evt in emtBreak.adBreakTrackingEvents
eventName = m.emtToRAFEvent[evt.eventType]
if invalid <> eventName
for each url in evt.beaconUrls
if invalid <> url and 0 < url.len()
rafEvent = {
event:eventName,
url:url,
triggered:false}
adBreak.tracking.push(rafEvent)
end if
end for
end if
end for
end if
end function
impl.parseAds = function(adBreak as object, srcads as object) as void
timeOffset = adBreak.renderTime
lastAd = invalid
for each ad in srcads
rAd = {
adid: ad.adId,    
duration: 0,
streamFormat: "hls",
adServer: m.strmURL,
streams: [],
tracking: [],
nativeAd: ad      
}
if invalid <> ad["trackingEvents"]
rAd.duration = ad.durationInSeconds
if m.streamManager.crrntPosSec <= (timeOffset + rAd.duration + m.MIN_AD_DUR) then
m.parseEvents(ad.adId, rAd.tracking, ad.trackingEvents)
end if
end if
if invalid <> ad.adSystem and "Innovid Ads" = ad.adSystem
m.parseInteractive(rAd, ad)
end if
m.setRIAParameters(rAd, ad)
if 0 < rAd.duration
adBreak.ads.push(rAd)
timeOffset += rAd.duration
lastAd = rAd
end if
end for
if m.sdk.StreamType.LIVE = m.prplyInfo["strmType"]
if invalid <> lastAd and 0 < m.lastSeq and lastAd.adid.toInt() < m.lastSeq
forget = true
for each evt in lastAd.tracking
if m.sdk.AdEvent.COMPLETE = evt.event
if invalid <> evt.eventId and m.lastSeq < evt.eventId.toInt()
forget = false
exit for
end if
end if
end for
if forget
adBreak.ads = []
lastAd = invalid
end if
end if
end if
end function
impl.assertEventId = function(adId as string, evt as object)
adImpSeg = val(adId, 0)
if val(evt.eventId, 0) < adImpSeg then
STOP
end if
end function
impl.parseEvents = function(adId as string, destObj as object, events as object) as string
strm_end_at = 0
if m.sdk.StreamType.VOD = m.prplyInfo.strmType and 0 < m.sgnode.duration then
strm_end_at = int(m.sgnode.duration)
end if
periodStartSec = m.get1stPeriodStart()
clickthrough = ""
for each evt in events
eventName = m.emtToRAFEvent[evt.eventType]
for each url in evt.beaconUrls
if url <> invalid and 0 < url.len()
if eventName <> invalid
eventTime = evt.startTimeInSeconds - periodStartSec
if 0 < strm_end_at and strm_end_at < eventTime then eventTime = strm_end_at
rafEvent = {
event:eventName,
url:url,
time:eventTime,
eventId:evt.eventId,
triggered:false}
destObj.push(rafEvent)
else
if 0 <= evt.eventType.instr("clickthrough")
clickthrough = url
else
rafEvent = {
event:evt.eventType
url:url,
eventId:evt.eventId,
triggered:false}
end if
end if
end if
end for
end for
return clickthrough
end function
impl.parseMediaFile = function(mf as object) as object
rca = invalid
if "application/json" = mf["mediaType"]
rca = {
mimeType: mf.mediaType,
url: ca["mediaFileUri"],
width: ca["width"],
height: ca["height"],
tracking: []
}
if invalid <> mf["trackingEvents"]
clickthrough = m.parseEvents(m.mediaType, rca.tracking, mf.trackingEvents)
if 0 < clickthrough.len()
rca.clickThrough = clickthrough
end if
end if
end if
return rca
end function
impl.parseInteractive = function(rAd as object, ad as object) as void
apiFramework = invalid
innovidFound = false
if "Innovid Ads" = ad.adSystem and invalid <> ad.companionAds
innoAdUpdate = { width: 16, height: 9
streams:[{mimetype:"application/json",
url: ""}],
streamformat: "iroll"
tracking: []
}
if 0 < ad.companionAds.count() then
for each ca in ad.companionAds
if false and invalid <> ca.attributes
attr = ca.attributes
if invalid <> attr.apiFramework then innoAd.provider = attr.apiFramework
if invalid <> attr.height then innoAd.height = attr.height.toInt()
if invalid <> attr.width then innoAd.width = attr.width.toInt()
end if
if invalid <> ca.trackingEvents
innoAdUpdate.tracking = ca.trackingEvents
end if
if invalid <> ca.staticResource
innoAdUpdate.streams[0].url = ca.staticResource
innovidFound = true
exit for
end if
end for
end if
if innovidFound then
rAd.companionAds = []
rAd.append(innoAdUpdate)
end if
end if
end function
impl.isDASH = function() as boolean
return invalid <> m.sgnode and invalid <> m.sgnode.content and "dash" = m.sgnode.content.streamformat
end function
impl.enableAdsBase = impl.enableAds
impl.dash1stPeriodStart = -1 
impl.enableAds = function(params as object) as void
m.lastSeq = 0
m.enableAdsBase(params)
player = params["player"]
m.sgnode = player.sgnode
if m.isDASH()
m.sgnode.observeField("manifestData",  player.port)
else if m.useStitched then
if m.sdk.StreamType.VOD = m.prplyInfo.strmType or invalid <> params.rollPodBySegment then
m.sgnode.observeField("streamingSegment",  player.port)
end if
end if
end function
impl.onPositionHLS = function() as void
if invalid <> m.sgnode.streamingSegment
ss = m.sgnode.streamingSegment
pendingPod = invalid
if m.lastSeq <> ss.segSequence
m.lastSeq = ss.segSequence
ret = m.streamManager.compareSegmentHLS({sequence:ss.segSequence+1,
startTime:ss.segStartTime, minAdDur:m.MIN_AD_DUR,
strmEnd:m.sgnode.duration,
strmType:m.prplyInfo.strmType})
pendingPod = ret["pendingPod"]
end if
if invalid <> pendingPod
m.rollPendingPod(pendingPod)
end if
end if
end function
impl.rollPendingPod = function(pendingPod as object) as void
if m.useStitched and 0 = pendingPod.ads.count() and 0 < pendingPod.tracking.count() and pendingPod.duration < 1
adIface = m.sdk.getRokuAds()
adIface.fireTrackingEvents(pendingPod, {type: m.sdk.AdEvent.POD_START})
adIface.fireTrackingEvents(pendingPod, {type: m.sdk.AdEvent.POD_END})
end if
if m.useStitched and 0 < pendingPod.ads.count() and 1 < pendingPod.duration
m.setRAFAdPods([pendingPod])
end if
podBeginSec = int(pendingPod.renderTime)
while podBeginSec <= m.streamManager.crrntPosSec
m.streamManager.handlePosition(podBeginSec, {})
podBeginSec += 1
end while
end function
impl.onPositionDASH = function(msg as object) as void
if -1 = m.availabilityStartTimeEpoch then return
if 0 = m.calibratedPeriodStart and invalid <> m.sgnode.positionInfo
videoPosEpoch = m.sgnode.positionInfo.video
nowTime = createObject("roDateTime").asSeconds()
startInEpoch = m.sgnode.positionInfo.video - m.sgnode.position
m.calibratedPeriodStart = startInEpoch - m.availabilityStartTimeEpoch
end if
ret = m.streamManager.onPositionDASH({position: msg.getData()})
if invalid <> ret.pendingPod
pendingPod = ret.pendingPod
m.setRAFAdPods([pendingPod])
end if
end function
impl.onPositionBase = impl.onPosition
impl.onPosition = function (msg as object) as void
if -1 = m.streamManager.crrntPosSec
if invalid <> m.loader
m.loader.ping(invalid)
m.last_ping = msg.getData()
end if
m.pingInfo = invalid
end if
if m.isDASH()
m.onPositionDASH(msg)
else
m.onPositionHLS()
end if
m.onPositionBase(msg)
end function
impl.rgx_startiso8601 = createObject("roRegEx", "PT(\d+H)?(\d+M)?([\d.]+S)?", "")
impl.startStr2StartSec = function(startstr as string) as integer
startSec = 0
mtch = m.rgx_startiso8601.match(startstr)
if invalid <> mtch and 1 < mtch.count()
for i=1 to mtch.count()-1
token = mtch[i]
if "H" = token.right(1)
startSec += val(token.left(len(token)-1)) * 3600
else if "M" = token.right(1)
startSec += val(token.left(len(token)-1)) * 60
else if "S" = token.right(1)
startSec += val(token.left(len(token)-1))
end if
end for
end if
return startSec
end function
impl.rgx_1stperiod  = createObject("roRegEx", "<Period[^>]+start=""([\w.]+)""", "")
impl.rgx_availStart = createObject("roRegEx", "availabilityStartTime=""([\S]+)""", "")
impl.availabilityStartTimeEpoch = -1
impl.firstPeriodStartTimeEpoch  = -1
impl.calibratedPeriodStart = 0
impl.get1stPeriodStart = function() as float
sec = 0
if m.isDASH() then sec = m.calibratedPeriodStart
return sec
end function
impl.parseDASH1stPeriod = function(xml as string) as void
if -1 = m.availabilityStartTimeEpoch then
mtch = m.rgx_availStart.match(xml)
if invalid <> mtch and 1 < mtch.count()
availInSec = createObject("roDateTime")
availInSec.fromISO8601String(mtch[1])
m.availabilityStartTimeEpoch = availInSec.asSeconds()
end if
end if
if -1 = m.dash1stPeriodStart
mtch = m.rgx_1stperiod.match(xml)
if invalid <> mtch and 1 < mtch.count()
m.dash1stPeriodStart = m.startStr2StartSec(mtch[1])
end if
end if
if 0 < m.availabilityStartTimeEpoch then
m.sgnode.unobserveField("manifestData")
end if
end function
impl.segSeqOffset = invalid
impl.onUnknown = function(msg as object) as void
if "roSGNodeEvent" = type(msg)
xg = msg.getField()
if "manifestData" = xg
dataAA = msg.getData()
if invalid <> dataAA.xml then
m.parseDASH1stPeriod(dataAA.xml)
end if
else if "streamingSegment" = xg
ss = msg.getData()
if invalid = m.segSeqOffset
m.segSeqOffset = 0
if (0 = ss.segSequence) then
m.segSeqOffset = 1
end if
end if
newSegSeq = ss.segSequence + m.segSeqOffset
if invalid <> m.streamManager.adTimeToBreakMap and m.sdk.StreamType.VOD = m.prplyInfo.strmType
m.streamManager.onStreamingSegment({sequence:newSegSeq,
startTime:ss.segStartTime, minAdDur:m.MIN_AD_DUR,
strmEnd:m.sgnode.duration,
strmType:m.prplyInfo.strmType})
else if m.sdk.StreamType.LIVE = m.prplyInfo.strmType and invalid = m.streamManager.currentAdBreak
m.lastSeq = ss.segSequence
ret = m.streamManager.compareSegmentHLS({sequence:newSegSeq,
startTime:ss.segStartTime, minAdDur:m.MIN_AD_DUR,
strmEnd:m.sgnode.duration,
strmType:m.prplyInfo.strmType})
pendingPod = ret["pendingPod"]
if invalid <> pendingPod
m.rollPendingPod(pendingPod)
end if
end if
end if
end if
end function
impl.dumpPingInfo = function (pingInfo as object) as void
periodStartSec = m.get1stPeriodStart()
for each avail in pingInfo.avails
strtAt = avail.startTimeInSeconds - periodStartSec
endAt = avail.durationInSeconds + avail.startTimeInSeconds - periodStartSec
if endAt < (m.streamManager.crrntPosSec + 10)
if 1 < pingInfo.avails.count() then print "<> <> <> impl.dumpPingInfo.avails remnant pod start: ";int(strtAt);"  end: ";int(endAt);"  currentPos: ";m.streamManager.crrntPosSec
else
for each ad in avail.ads
if invalid <> ad.startTimeInSeconds
print "  adId: ";ad.adId;"  Title: ";ad.adTitle;"  offsetStartTime: ";int(ad.startTimeInSeconds - periodStartSec);"  duration: ";ad.duration
else
print "  adId: ";ad.adId;"  Title: ";ad.adTitle;"  startTime: ";int(ad.startTimeInSeconds);"  duration: ";ad.duration
end if
end for
end if
end for
end function
impl.MIN_AD_DUR = 4
impl.isCompleteEmtAdBreak = function(pingInfo as object) as boolean
yesComplete = false
if 0 < pingInfo.avails.count() then
emtBreak = pingInfo.avails[pingInfo.avails.count()-1]
sumAdsDuration = 0
for each ad in emtBreak.ads
sumAdsDuration += ad.durationInSeconds
end for
yesComplete = (emtBreak.durationInSeconds < (sumAdsDuration + m.MIN_AD_DUR))
end if
return yesComplete
end function
impl.parsePingHLS = function(pingInfo as object) as void
a = pingInfo.avails.peek()
crrntPosSec = m.streamManager.crrntPosSec
if crrntPosSec <= a.startTimeInSeconds
m.pingInfo = pingInfo
if m.isCompleteEmtAdBreak(pingInfo)
m.last_ping = a.durationInSeconds + a.startTimeInSeconds
end if
else
m.pingInfo = pingInfo
m.last_ping = m.last_ping - (m.PING_INTERVAL * 0.9)
end if
end function
impl.parsePingDASH = function(pingInfo as object) as void
avails = []
periodStartSec = m.get1stPeriodStart()
if 0 = periodStartSec then return
for i=0 to pingInfo.avails.count()-1
a = pingInfo.avails[i]
startPos = a.startTimeInSeconds - periodStartSec
endPos   = startPos + a.durationInSeconds
if m.streamManager.crrntPosSec < startPos
avails.push(a)
else if invalid <> m.streamManager.currentAdBreak and m.streamManager.currentAdBreak.id = a.availId
if m.streamManager.currentAdBreak.duration < a.durationInSeconds then avails.push(a)
else if startPos < m.streamManager.crrntPosSec and m.streamManager.crrntPosSec < endPos
avails.push(a)
end if
end for
if 0 < avails.count()
pingInfo.avails = avails
m.pingInfo = pingInfo
end if
end function
impl.parsePing = function() as void
jsn = m.loader.getPingResponse()
if invalid <> jsn and "" <> jsn
pingInfo = parsejson(jsn)
if pingInfo <> invalid and invalid <> pingInfo.avails and 0 < pingInfo.avails.count()
if 1 = pingInfo.avails.count()
a = pingInfo.avails[0]
if m.streamManager.adBreakEnded({id:a.availId,
endAt: a.startTimeInSeconds + a.durationInSeconds })
m.pingInfo = invalid
return
end if
end if
if m.isDASH()
m.parsePingDASH(pingInfo)
else
m.parsePingHLS(pingInfo)
end if
end if
end if
end function
impl.PING_INTERVAL = 11
impl.last_ping = 0
impl.shouldPing = function(posSec as float) as boolean
if m.loader.hasPinged() then return false
ping_interval = m.PING_INTERVAL
strmMgr = m.streamManager
if m.isDASH() and strmMgr.isPendingPodAboutToRAF()
ping_interval = strmMgr.POD_TO_RAF
end if
return (m.last_ping + ping_interval < strmMgr.crrntPosSec)
end function
impl.onMessageLIVE = function(msg as object, curAd as object) as Void
posSec = msg.getData()
if m.streamManager.pastLastAdBreak(posSec)
m.streamManager.createTimeToEventMap(invalid)
end if
if invalid <> m.pingInfo
m.pingInfo["avails"] = invalid
end if
m.parsePing()
if invalid <> m.pingInfo and invalid <> m.pingInfo["avails"]
m.setRAFAdPods()
end if
if m.shouldPing(posSec)
m.loader.ping({position:posSec})
m.last_ping = m.streamManager.crrntPosSec
end if
end function
impl.createLoader = function(live_or_vod as string) as object
obj = m.sdk.createDAIObject("liveloader")
baseobj = m.sdk["vodloader"]
obj.getJSON = baseobj.getJSON
obj.isValidString = baseobj.isValidString
return obj
end function
liveloader = rafssai["liveloader"]
liveloader.pingURL = ""
liveloader.isPinging = false
liveloader.pingPort = createObject("roMessagePort")
liveloader.ping_json = invalid
liveloader.requestPreplay = function(requestObj as object) as dynamic
m.strmURL = requestObj.url
res = invalid
if invalid = requestObj["body"]
res = m.getJSON({url:m.strmURL, retry:0})
else
res = m.getJSON({url:m.strmURL, body:requestObj.body, retry:0})
end if
return res
end function
liveloader.ping = function(params as dynamic) as void
if "" = m.pingURL then return
m.isPinging = true
url = m.pingURL
m.pingXfer = m.sdk.createUrlXfer(m.sdk.httpsRegex.isMatch(url))
m.pingXfer.setMessagePort(m.pingPort)
m.pingXfer.setUrl(url)
m.pingXfer.addHeader("Accept", "application/json")
m.pingXfer.asyncGetToString()
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
if invalid <> prplyInfo.tracking_url
m.pingURL = prplyInfo.tracking_url
end if
end function
liveloader.domainRegex = createObject("roRegex", "^[^:/?#]+:?//[^/?#]*", "i")
liveloader.getBaseURL = function() as string
m = m.domainRegex.match(m.strmURL)
if 0 < m.count()
return m[0]
end if
return ""
end function
strmMgr = rafssai["streamManager"]
strmMgr.POD_TO_RAF=1.4
strmMgr.pendingPods = []
strmMgr.mergeRunningPod = function(nPod as object, min_ad_dur as integer) as boolean
adAppended = 0
hasInteractive = true
cab = m.currentAdBreak
if cab.duration < nPod.duration
cab.duration = nPod.duration
end if
timeOffset = cab.renderTime
cab_ads_count = cab.ads.count()
cab_end_at = cab.renderTime + cab.duration
for i=0 to cab_ads_count-1
cad = cab.ads[i]
nad = nPod.ads[i]
if cad.adid <> nad.adid
STOP
end if
if 0 = nad.tracking.count() then
cad.tracking = []
else
m.sdk.setTrackingTime(timeOffset, nad, int(cab_end_at))
u2t = {}
for each ce in cad.tracking
u2t[ce.url] = ce.triggered
end for
eventsToAdd = []
while 0 < nad.tracking.count()
ne = nad.tracking.pop()
if not u2t.doesExist(ne.url)
eventsToAdd.push(ne)
end if
end while
if 0 < eventsToAdd.count()
params = {duration:cad.duration, tracking:eventsToAdd}
remaining_dur = cab_end_at - timeOffset
if remaining_dur < params.duration and 0 < remaining_dur then
params.duration = remaining_dur
end if
m.sdk.setTrackingTime(timeOffset, params, int(cab_end_at))
adAppended += eventsToAdd.count()
cad.tracking.append(eventsToAdd)
end if
end if
hasInteractive = (hasInteractive or "iroll"=cad.streamFormat)
timeOffset += nad.duration
end for
for i=cab_ads_count to nPod.ads.count()-1
nad = nPod.ads[i]
m.sdk.setTrackingTime(timeOffset, nad, int(cab_end_at))
cab.ads.push(nad)
adAppended += 1
timeOffset += nad.duration
end for
if 0 < adAppended then
m.createTimeToEventMap([cab])
end if
return hasInteractive
end function
strmMgr.addEventToEvtMapBase = strmMgr.addEventToEvtMap
strmMgr.addEventToEvtMap = function(timeToEvtMap as object, timeKey as string, evtStr as dynamic) as void
if m.crrntPosSec <= val(timeKey)
m.addEventToEvtMapBase(timeToEvtMap, timeKey, evtStr)
end if
end function
strmMgr.appendPods = function (newPods as object, min_ad_dur as integer, strmType as string) as object
ret = {appendedToPendingPod:false, appendedToRunningPod:false}
for each nab in newPods
appendPod = true
if invalid <> m.currentAdBreak and nab.id = m.currentAdBreak.id then
adCount = m.currentAdBreak.ads.count()
hasInteractive = m.mergeRunningPod(nab, min_ad_dur)
ret.appendedToRunningPod = (adCount < m.currentAdBreak.ads.count() and (not hasInteractive))
appendPod = false
else if 0 < m.pendingPods.count()
for i=0 to m.pendingPods.count()-1
ab = m.pendingPods[i]
if ab.id = nab.id
m.pendingPods[i] = nab
appendPod = false
exit for
end if
end for
else if m.sdk.StreamType.LIVE = strmType and 0 = nab.ads.count() and nab.duration < 1 and nab.renderTime < m.crrntPosSec
appendPod = false
else if m.sdk.StreamType.LIVE = strmType and 1 = newPods.count()
m.pendingPods = [nab]
end if
if appendPod then
timeOffset = nab.renderTime
for each ad in nab.ads
if (timeOffset + ad.duration + min_ad_dur) < m.crrntPosSec
ad.tradking = []
end if
timeOffset += ad.duration
end for
m.pendingPods.push(nab)
ret.appendedToPendingPod = true
end if
end for
return ret
end function
strmMgr.onPositionDASH = function(params as object) as object
ret = {}
if 0 < m.pendingPods.count() and m.pendingPods[0].renderTime < params.position + m.POD_TO_RAF then
ab = m.pendingPods.shift()
timeOffset = ab.renderTime
for each ad in ab.ads
m.sdk.setTrackingTime(timeOffset, ad)
timeOffset += ad.duration
end for
ret["pendingPod"] = ab
end if
return ret
end function
strmMgr.isPendingPodAboutToRAF = function() as boolean
return (0 < m.pendingPods.count() and (m.pendingPods[0].renderTime + m.POD_TO_RAF) < m.crrntPosSec)
end function
strmMgr.onStreamingSegment = function(params as object)
abUpdated = false
adBreaks = []
for each kv in m.adTimeToBreakMap.items()
ab = kv.value 
if invalid <> ab.segSeq and params.sequence = ab.segSeq and (ab.renderTime - params.startTime) < params.minAdDur
m.updateRenderTime(ab, params)
ab.delete("segSeq")
abUpdated = true
end if
adBreaks.push(ab)
end for
if abUpdated
m.createTimeToEventMap(adBreaks)
end if
end function
strmMgr.updateRenderTime = function(ab as object, params as object)
ab.renderTime = params.startTime
cab_end_at = int(ab.renderTime + ab.duration)
if m.sdk.StreamType.VOD = params.strmType and params.startTime < params.strmEnd and params.strmEnd < cab_end_at
cab_end_at = params.strmEnd
end if
timeOffset = ab.renderTime
for each ad in ab.ads
remaining_dur = cab_end_at - timeOffset
if remaining_dur < ad.duration and 0 < remaining_dur
ad.duration = remaining_dur
end if
m.sdk.setTrackingTime(timeOffset, ad, cab_end_at)
timeOffset += ad.duration
end for
ab.duration = timeOffset - ab.renderTime
end function
strmMgr.compareSegmentHLS = function(params as object) as object
ret = {}
if invalid = m.currentAdBreak then
ab = m.pendingPods.peek()
if invalid <> ab and m.adBreakEnded({id:ab.id, endAt:ab.renderTime+ab.duration}) then
ab = m.pendingPods.shift()
ab = invalid
end if
if invalid <> ab and (ab.segSeq <= params.sequence or (ab.renderTime < params.startTime+params.minAdDur))
ab = m.pendingPods.shift()
if ab.segSeq = params.sequence or params.startTime < ab.renderTime
m.updateRenderTime(ab, params)
else
end if
ret["pendingPod"] = ab
end if
end if
if invalid = ret["pendingPod"] and invalid <> m.currentAdBreak and m.sdk.StreamType.LIVE = params.strmType
lastAd = m.currentAdBreak.ads[m.currentAdBreak.ads.count()-1]
for each evt in lastAd.tracking
if m.sdk.AdEvent.COMPLETE = evt.event  and  false=evt.triggered
if invalid <> evt.eventId and evt.eventId.toInt()+1 < params.sequence
actualDuration = m.lastPosSec - m.currentAdBreak.renderTime
m.currentAdBreak.duration = actualDuration
end if
exit for
end if
end for
end if
return ret
end function
strmMgr.deinitBase = strmMgr.deinit
strmMgr.deinit = function(params as object) as void
if invalid <> m.currentAdBreak and 0 < params.strmEnd and m.sdk.StreamType.VOD = params.strmType and invalid <> params.curAd
posSec = m.crrntPosSec
if (params.strmEnd - posSec) <= 10
while posSec < params.strmEnd
posSec += 1
m.handlePosition(posSec, params.curAd)
end while
end if
end if
m.deinitBase(params)
end function
return rafssai
end function
function RAFX_SSAI(params as object) as object
    if invalid <> params and invalid <> params["name"]
        p = RAFX_getEMTAdapter(params)
        p["__version__"] = "0b.47.21"
        p["__name__"] = params["name"]
        return p
    end if
end function
