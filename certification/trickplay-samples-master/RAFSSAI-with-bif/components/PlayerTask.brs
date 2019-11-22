'*********************************************************************
'** (c) 2016-2019 Roku, Inc.  All content herein is protected by U.S.
'** copyright and other applicable intellectual property laws and may
'** not be copied without the express permission of Roku, Inc., which
'** reserves all rights.  Reuse of any of this content for any purpose
'** without the permission of Roku, Inc. is strictly prohibited.
'*********************************************************************

Library "Roku_Ads.brs"

sub init()
    m.top.functionName = "playContentWithAds"
end sub

sub playContentWithAds()
    videoPlayer = m.top.video

    RAF = Roku_Ads()
    'RAF.setDebugOutput(true)
    'RAF.clearAdBufferScreenLayers()        ' in case it was set earlier
    'RAF.enableAdBufferMessaging(true, true) ' could have been cleared by custom screen
    'RAF.setAdBufferScreenContent({})

    content = videoPlayer.content
    RAF.SetAdUrl("pkg:/VMAP/vmap.xml")
    RAF.setAdPrefs(true, 2)

    ' for generic measurements api
    ' Nielsen DAR specific
    if content.nielsen_app_id <> invalid
      RAF.enableNielsenDAR(true)
      RAF.setNielsenAppId(content.nielsen_app_id)
      RAF.setNielsenGenre(content.nielsen_genre)
      RAF.setNielsenProgramId(content.nielsen_program_id)
      RAF.setContentLength(content.length)
    end if

    adPods = RAF.getAds() 'array of ad pods
    parseAds(adPods)
    RAF.stitchedAdsInit(adPods)
    keepPlaying = true 'gets set to `false` when showAds() was exited via Back button

    port = CreateObject("roMessagePort")
    videoPlayer.observeField("position", port)
    videoPlayer.observeField("state", port)

    player = {
             sgNode: videoPlayer
             port: port
         }

    while keepPlaying
        msg = wait(0, port)
		if type(msg) = "roSGNodeEvent"
          if msg.getField() = "position"
            ? "position= "; msg.getData()
          else if msg.getField() = "state"
            ? "state= "; msg.getData()
          end if
        curAd = RAF.stitchedAdHandledEvent(msg, player)
        'if curAd<> invalid and curAd.evtHandled
        if curAd<> invalid
          if curAd.adExited
            ? "ad exited."
            keepPlaying = false
            videoPlayer.visible = false
            videoPlayer.control = "stop"
            videoPlayer.setFocus(true)
          end if
          if curAd.adCompleted
            ? "ad completed."
            videoPlayer.setFocus(true)
          end if
       	end if
		end if
    end while
end sub

sub parseAds(adPods as Object)
  for each adBreak in adPods
    adTime = adBreak.renderTime
    for each ad in adBreak.ads
      for each trackingEvent in ad.tracking
        ' Fix event time for impression beacons
        if trackingEvent.event = "Impression"
	  eventTime = adTime
	  trackingEvent.AddReplace("time", eventTime)
        ' Fix event time for first quartile beacons
        else if trackingEvent.event = "FirstQuartile"
	  eventTime = adTime + ad.duration / 4
	  trackingEvent.AddReplace("time", eventTime)
        ' Fix event time for midpoint beacons
        else if trackingEvent.event = "Midpoint"
	  eventTime = adTime + ad.duration / 2
	  trackingEvent.AddReplace("time", eventTime)
        ' Fix event time for third quartile beacons
        else if trackingEvent.event = "ThirdQuartile"
	  eventTime = adTime + (ad.duration * 3) / 4
	  trackingEvent.AddReplace("time", eventTime)
        ' Fix event time for complete beacons
        else if trackingEvent.event = "Complete"
	  eventTime = adTime + ad.duration
	  trackingEvent.AddReplace("time", eventTime)
        end if
      end for

      adTime += ad.duration
    end for
  end for
end sub
