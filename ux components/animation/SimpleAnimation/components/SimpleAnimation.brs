function init()
   m.animation = m.top.FindNode("myAnimation")
   m.animation2= m.top.FindNode("myAnimation2")
   m.animation3= m.top.FindNode("myAnimation3")
   m.colorChangeAnimation = m.top.FindNode("colorChangeAnimation")
   m.brUpAnimation = m.top.FindNode("bottomRectUpAnimation")
   m.brDownAnimation = m.top.FindNode("bottomRectDownAnimation")
   m.video = m.top.FindNode("_video")
   m.label = m.top.FindNode("myLabel")
   m.poster = m.top.FindNode("myPoster")
   m.splash = m.top.FindNode("pleaseWaitSplash")
   m.video.observeField("state", "onPlaybackStateChanged")
   'animation.control = "start"
   'animation2.control = "start"
   'animation3.control = "start"
   playVideo()
end function

function startAnimations() as void
   m.animation.control = "start"
   m.animation2.control = "start"
   m.animation3.control = "start"
   m.colorChangeAnimation.control = "start"
end function

function playVideo() as void    
    vidContent = createObject("RoSGNode", "ContentNode")
    vidContent.url = "https://roku.s.cpl.delvenetworks.com/media/59021fabe3b645968e382ac726cd6c7b/60b4a471ffb74809beb2f7d5a15b3193/roku_ep_111_segment_1_final-cc_mix_033015-a7ec8a288c4bcec001c118181c668de321108861.m3u8"
    vidContent.title = "Test Video"
    vidContent.streamformat = "hls"
    m.video.content = vidContent
    m.video.translation = [0,0]
    m.video.width = 1280
    m.video.height= 720
    m.video.setFocus(true)
    m.video.control = "play"
end function

function onPlaybackStateChanged() as void
    print m.video.state
    if (m.video.state = "playing")
	   m.splash.visible = false
	   m.video.visible = true
	   m.label.visible = true
	   m.poster.visible = true
	   startAnimations()
	   m.video.unobserveField("state")
	endif
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    if press then
        if key = "up" then
		    print "up"
			m.brUpAnimation.control = "start"
            handled = true
		else if (key = "down") then
		    print "down"
			m.brDownAnimation.control = "start"
			handled = true
        end if
    end if
    return handled    
end function
