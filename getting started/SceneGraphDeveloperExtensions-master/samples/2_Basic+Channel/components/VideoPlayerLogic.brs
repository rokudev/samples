'This is logic for video playback
function OpenVideoPlayer(content, index, isContentList) as Object
    video = CreateObject("roSGNode", "VideoView")
    content.AddFields({
            HandlerConfigEndcard : {
            name : "CGEndcard"
            fields : {
                param : "Supre cinema"
                currentItemContent: content
            }
        }
    })
    video.content = content
    video.jumpToItem = index
    video.isContentList = isContentList
    video.control = "play"
    m.isEndcardShown = true

    video.currentItem.AddFields({
            HandlerConfigEndcard : {
            name : "CGEndcard"
            fields : {
                param : "Supre cinema"
                currentItemContent: content
            }
        }
    })
    m.top.ComponentController.callFunc("show", {
        view: video
    })

    return video
end function

function OpenVideoPlayerItem(contentItem) as Object
    video = CreateObject("roSGNode", "VideoView")
    video.content = contentItem
    video.isContentList = false

    video.control = "play"

    m.isEndcardShown = true

    m.top.ComponentController.callFunc("show", {
        View: video
    })

    return video
end function

'this function will be called in both cases when video finishes or when user presses back
'when user presses back, View manger will handle it and remove top View from view
sub OnVideoWasClosed(event as Object)
    video = event.getRoSGNode()
    if video <> invalid then
        video.control = "stop"
    end if
end sub
