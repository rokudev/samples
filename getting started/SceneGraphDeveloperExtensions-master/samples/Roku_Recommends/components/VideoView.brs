function OpenVideoView(content as Object, index as Integer) as void
    video = CreateObject("roSGNode", "VideoView")
    video.content = content
    video.jumpToItem = index
    m.top.ComponentController.CallFunc("show", {
        view: video
    })
    video.control = "play"
end function
