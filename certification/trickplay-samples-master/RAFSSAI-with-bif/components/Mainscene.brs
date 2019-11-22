
' ********** Copyright 2016-2019 Roku Corp.  All Rights Reserved. **********

function init()
    m.video = m.top.findNode("myVideo")
    m.playertask = createObject("roSGNode","PlayerTask")
    m.playertask.video = m.video
    m.playertask.control = "RUN"
    playVideo() ' Calls playVideo method
end function

function playVideo() as void

    vidContent = createObject("RoSGNode", "ContentNode")
    vidContent.url = "http://production.smedia.lvp.llnw.net/59021fabe3b645968e382ac726cd6c7b/-P/HHZYyAQwH2HsvMPI9dRM844YFCsrlTO-2zWNBxxgw/video.mp4?x=0&h=88019e9866a54a1418a11d953d464ed5"

	  vidContent.sdbifurl = "https://image.roku.com/ZHZscHItc2Ft/thumbnails/RAFSSAI-with-bif/video-sd.bif"
	  vidContent.hdbifurl = "https://image.roku.com/ZHZscHItc2Ft/thumbnails/RAFSSAI-with-bif/video-hd.bif"
    vidContent.streamformat = "mp4"

    m.video.content = vidContent
    m.video.setFocus(true)
    m.video.control = "play"
end function
