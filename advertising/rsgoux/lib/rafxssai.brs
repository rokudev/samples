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
function RAFX_getOnceUXPlugin(params as dynamic) as Object
rafxssai = RAFX_getSSAIPluginBase(params)
impl = rafxssai["impl"]
impl.onceuxToRAFEvent = {
"impressions" : rafxssai.AdEvent.IMPRESSION
"firstquartiles" : rafxssai.AdEvent.FIRST_QUARTILE
"midpoints" : rafxssai.AdEvent.MIDPOINT
"thirdquartiles" : rafxssai.AdEvent.THIRD_QUARTILE
"completes" : rafxssai.AdEvent.COMPLETE
}
impl.requestPreplay = function(requestObj as object) as object
if invalid = m.loader
m.loader = m.createLoader(requestObj.type)
end if
xmlstr = m.loader.requestPreplay(requestObj)
if invalid <> xmlstr and "" <> xmlstr
m.sdk.log(["requestPreplay() xml:",xmlstr], 9)
parser = m.sdk.createOUXParser()
vmapxml = parser.strToXml(xmlstr)
if invalid = vmapxml
print "requestPreplay() invalid xml:";xmlstr
return {error:"invalid xml"}
end if
m.prplyInfo = {vmapxml:vmapxml, parser:parser, strmType: requestObj.type}
else
print "requestPreplay() empty xml response"
m.prplyInfo = {}
return {error:"empty response"}
end if
return invalid
end function
impl.getStreamInfo = function() as object
if invalid <> m.prplyInfo["uoInfo"]
return m.prplyInfo.uoInfo
else if invalid <> m.prplyInfo and invalid <> m.prplyInfo["vmapxml"] and invalid <> m.prplyInfo["parser"]
m.prplyInfo["uoInfo"] = m.prplyInfo.parser.parseExtensions(m.prplyInfo.vmapxml)
return m.prplyInfo.uoInfo
end if
return {}
end function
impl.parsePrplyInfo = function() as object
adBreaks = []
adOpportunities = 0
if invalid <> m.prplyInfo and invalid <> m.prplyInfo["vmapxml"] and invalid <> m.prplyInfo["parser"]
adBreaks = m.prplyInfo.parser.parseAdBreaks(m.prplyInfo.vmapxml)
else
m.sdk.log("parsePrplyInfo() NO valid prplyInfo")
end if
for each ab in adBreaks
adOpportunities += ab.ads.count()
duration = 0
for each ad in ab.ads
m.sdk.setTrackingTime(ab.renderTime+duration, ad)
duration += ad.duration
end for
if 0 = ab.duration
ab.duration = duration
end if
end for
return {adOpportunities:adOpportunities, adBreaks:adBreaks}
end function
rafxssai.createOUXParser = function() as object
obj = m.createDAIObject("OUXParser")
obj.getValidStr = m.getValidStr
return obj
end function
ouxparser = {}
ouxparser.strToXml = function(vmapstr as string) as object
vmapxml = createObject("roXmlElement")
if vmapstr = invalid or not vmapxml.parse(vmapstr) then
return invalid
end if
m.sdk.log("vmapstr: "+vmapstr, 10)
return vmapxml
end function
ouxparser.parseAdBreaks = function(vmapxml as object) as object
adBreaks = []
if vmapxml = invalid
return adBreaks
end if
for each abxml in vmapxml.getNamedElementsCi("vmap:AdBreak")
adBreak = {
viewed: false,
renderTime: 0.0,
renderSequcne: "",
duration: 0.0,
tracking: [],
slots: 0,
ads: []
}
m.parseAdBreak(abxml, adBreak)
if 0 < adBreak.ads.count() then
if 0 < adBreaks.count()  and  adBreak["renderTime"] = adBreaks.peek()["renderTime"]
lastBreak = adBreaks.peek()
lastBreak.tracking.append(adBreak.tracking)
lastBreak.ads.append(adBreak.ads)
else
adBreaks.push(adBreak)
end if
end if
end for
return adBreaks
end function
ouxparser.parseExtensions = function(vmapxml as object) as object
uoInfo = {
content: {
contenturi: ""
contenttype: ""
contentlength: 0
payloadlength: 0
ttl: 0
}
tracking: []
parameters: {}
}
extensions = vmapxml.getNamedElementsCi("vmap:Extensions")[0]
if invalid = extensions
return uoInfo
end if
for each elm in extensions.getChildElements()
elmName = elm.getName()
if "uo:contentImpressions" = elmName
for each impelm in elm.getNamedElements("uo:Impression")
url = m.getValidStr(impelm@url)
if "" <> url
uoInfo.tracking.push({event: "Impression", url:url})
end if
end for
else if "uo:unicornOnce" = elmName
uoInfo.contenturi = m.getValidStr(elm@contenturi)
uoInfo.contenttype = m.getValidStr(elm@contenttype)
cl = m.getValidStr(elm@contentlength)
if "" <> cl
uoInfo.contentlength = cl.toInt()
end if
pl = m.getValidStr(elm@payloadlength)
if "" <> pl
uoInfo.payloadlength = pl.toInt()
end if
ttl = m.getValidStr(elm@ttl)
if "" <> ttl
uoInfo.ttl = ttl.toInt()
end if
else if "uo:requestParameters" = elmName
for each uoparam in elm.getNamedElements("uo:parameter")
key = m.getValidStr(uoparam@key)
val = m.getValidStr(uoparam@value)
if invalid <> key and invalid <> val
uoInfo.parameters[key] = val
end if
end for
end if
end for
return uoInfo
end function
ouxparser.VASTToRAFMap = {
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
ouxparser.parseTracking = function(trckxml as object, adBreak as object) as void
evt = m.getValidStr(trckxml@event)
if "" = evt then return
evt = m.VASTToRAFMap[evt]
url = m.getValidStr(trckxml.getText())
if invalid <> evt
adBreak.tracking.push({event: evt, url:url, triggered:false})
end if
end function
ouxparser.secfloat = createObject("roRegEx", "[0-9]{2}(?:[.][0-9]{1,3})?", "")
ouxparser.parseTimeString = function(hhmmss as string, defaultsec = 0.0 as float) as float
seconds = defaultsec
f = hhmmss.tokenize(":")
if 3 <= f.count()
seconds = f[0].toInt()*3600 + f[1].toInt()*60
secm = m.secfloat.match(f[2])
if invalid <> secm and 0 < secm.count() then
seconds += secm[0].tofloat()
end if
end if
return seconds
end function
ouxparser.parseTimeOffset = function(abxml as object, adBreak as object) as void
timeOffset = m.getValidStr(abxml@timeoffset)
if timeOffset = "start"
adBreak.renderSequence = "preroll"
else if timeOffset = "end"
adBreak.renderSequence = "postroll"
else
adBreak.renderSequence = "midroll"
adBreak.renderTime = m.parseTimeString(timeOffset)
end if
end function
ouxparser.parseAdBreak = function(abxml as object, adBreak as object) as void
trackingEvents = abxml.getNamedElements("vmap:TrackingEvents")
if invalid <> trackingEvents[0]
for each trckxml in trackingEvents[0].getNamedElements("vmap:Tracking")
m.parseTracking(trckxml, adBreak)
end for
end if
m.parseTimeOffset(abxml, adBreak)
asxml = abxml.getNamedElements("vmap:AdSource")[0]
if invalid <> asxml
vdata = asxml.getNamedElements("vmap:VASTAdData")[0]
if invalid = vdata
vdata = asxml.getNamedElements("vmap:VASTData")[0]
end if
if invalid <> vdata
vstxml = vdata.getNamedElements("VAST")[0]
if invalid <> vstxml
ads = m.parseVAST(vstxml)
if 0 < ads.count()
adBreak.ads = ads
end if
end if
end if
end if
end function
ouxparser.parseVAST = function(vstxml as object) as object
ads = []
for each adxml in vstxml.getNamedElementsCi("ad")
ad = m.parseAd(adxml)
if invalid <> ad and (0 < ad.duration or 0 < ad.tracking.count())
ads.push(ad)
end if
end for
return ads
end function
ouxparser.parseAd = function(adxml as object) as object
rAd = {
duration: 0,
streamFormat: "",
adServer: "",
streams: [],
tracking: []
}
if invalid <> adxml@id then rAd["adid"] = adxml@id
for each elm in adxml.getNamedElementsCi("inline")
m.parseChildren(elm, rAd, "ad")
end for
return rAd
end function
ouxparser.addImpressionUrl = function(xml as object, rAd as object) as Void
url = m.getValidStr(xml.getText())
if "" <> url
rAd.tracking.push({event: "Impression", url:url, triggered:false})
end if
end function
ouxparser.parseAdTitle = function(xml as object, rAd as object) as Void
rAd.title = m.getValidStr(xml.getText())
end function
ouxparser.addErrorUrl = function(xml as object, rAd as object) as Void
url = m.getValidStr(xml.getText())
if "" <> url
rAd.tracking.push({event: "Error", url:url, triggered:false})
end if
end function
ouxparser.parseCreatives = function(xml as object, rAd as object) as Void
for each elm in xml.getNamedElementsCi("creative")
m.parseCreative(elm, rAd)
end for
end function
ouxparser.parseCreative = function(xml as object, rAd as object) as Void
for each elm in xml.getNamedElementsCi("linear")
m.parseChildren(elm, rAd, "creative")
end for
apiFramework = m.getValidStr(xml@apiFramework)
if "brightline" = apiFramework.left(10)
for each elm in xml.getNamedElementsCi("companionads")
for each elm in xml.getNamedElementsCi("companion")
m.parseCompanion(elm, rAd, apiFramework)
end for
end for
end if
end function
ouxparser.parseDuration = function(xml as object, rAd as object) as Void
dur = m.getValidStr(xml.getText())
if "" <> dur
rAd.duration = m.parseTimeString(dur)
end if
end function
ouxparser.parseTrackingEvents = function(xml as object, rAd as object) as Void
for each elm in xml.getNamedElementsCi("tracking")
m.parseTracking(elm, rAd)
end for
end function
ouxparser.parseVideoClicks = function(xml as object, rAd as object) as void
clickthrough = xml.ClickThrough[0]
if invalid <> clickthrough
url = m.getValidStr(clickthrough.getText())
if "" <> url
rAd.clickThrough = url
end if
end if
end function
ouxparser.parseMediaFiles = function(xml as object, rAd as object) as Void
for each elm in xml.getNamedElementsCi("mediafile")
m.parseMediaFile(elm, rAd)
end for
end function
ouxparser.parseMediaFile = function(xml as object, rAd as object) as Void
apiFramework = LCase(m.getValidStr(xml@apiFramework))
if "innovid" <> apiFramework then return
mimeType = m.getValidStr(xml@type)
if "application/json" <> mimeType then return
url = m.getValidStr(xml.getText())
if "" = url then return
stream = {
url      : url
width    : m.getValidStr(xml@width).toInt()
height   : m.getValidStr(xml@height).toInt()
provider : apiFramework
mimeType : mimeType
}
rAd.streams.push(stream)
rAd.streamFormat = "iroll"
end function
ouxparser.parseCompanion = function(xml as object, rAd as object, apiFrameworkOfCreative as string) as Void
companion = {url:invalid, mimeType:invalid, tracking:[], provider:apiFrameworkOfCreative}
m.parseChildren(xml, companion, "companion")
if invalid <> companion.url
apiFramework = m.getValidStr(xml@apiFramework)
if "" <> apiFramework
companion["provider"] = apiFramework
end if
companion["width"]  = m.getValidStr(xml@width).toInt()
companion["height"] = m.getValidStr(xml@height).toInt()
rAd.companionAds.push(companion)
rAd.streams = [{url:""}]
end if
end function
ouxparser.parseStaticResource = function(xml as object, obj as object) as Void
mimeType = m.getValidStr(xml@creativeType)
if "application/json" = mimeType
url = m.getValidStr(xml.getText())
if "" <> url
obj.mimeType = mimeType
obj.url = url
end if
end if
end function
ouxparser.parseCompanionClickThrough = function(xml as object, obj as object) as void
url = m.getValidStr(xml.getText())
if "" <> url
obj.clickThrough = url
end if
end function
ouxparser.parseChildren = function(xml as object, rAd as object, tagName as string) as Void
if xml.getChildElements() = invalid then
return
end if
for each elm in xml.getChildElements()
elmName = lcase(elm.getname())
if lcase(tagName) = "ad"
if elmName = "impression"
m.addImpressionUrl(elm, rAd)
else if elmName = "creatives"
m.parseCreatives(elm, rAd)
else if elmName = "error"
m.addErrorUrl(elm, rAd)
else if elmName = "adtitle"
m.parseAdTitle(elm, rAd)
end if
else if lcase(tagName) = "creative"
if elmName = "duration"
m.parseDuration(elm, rAd)
else if elmName = "trackingevents"
m.parseTrackingEvents(elm, rAd)
else if elmName = "videoclicks"
m.parseVideoClicks(elm, rAd)
else if elmName = "mediafiles"
m.parseMediaFiles(elm, rAd)
end if
else if lcase(tagName) = "companion"
if elmName = "staticresource"
m.parseStaticResource(elm, rAd)
else if elmName = "companionclickthrough"
m.parseCompanionClickThrough(elm, rAd)
else if elmName = "trackingevents"
m.parseTrackingEvents(elm, rAd)
end if
end if
end for
end function
rafxssai["OUXParser"] = ouxparser
return rafxssai
end function
function RAFX_SSAI(params as object) as object
    if invalid <> params and invalid <> params["name"]
        p = RAFX_getOnceUXPlugin(params)
        p["__version__"] = "0b.42.8"
        p["__name__"] = params["name"]
        return p
    end if
end function
