' There are two functions depending on whether or not a focus index and isContentList are provided
function OpenVideoPlayer(content, index, isContentList) as Object
    ' Create VideoView Object and set its fields
    video = CreateObject("roSGNode", "VideoView")
    video.ObserveField("endcardItemSelected", "OnEndcardItemSelected")
    video.content = content
    video.jumpToItem = index
    video.isContentList = isContentList
    ' video.ObserveField("state", "HandleState")
    video.ObserveField("wasClosed","onVideoWasClosed")
    ' Show the video view
    m.top.ComponentController.callFunc("show", {
        view: video
    })
    video.control = "play"

    return video
end function

function OpenVideoPlayerItem(contentItem) as Object
    ' Create VideoView Object and set its fields
    video = CreateObject("roSGNode", "VideoView")
    contentItem.AddFields({
        HandlerConfigEndcard : {
            name : "EndcardHandler"
            fields : {
                param: "Endcard"
                currentItemContent: contentItem.GetFields()
            }
        }
    })
    video.content = contentItem
    video.isContentList = false
    ' video.ObserveField("state", "HandleState")
    video.ObserveField("wasClosed","onVideoWasClosed")
    video.observeField("endcardItemSelected", "OnEndcardItemSelected")
    ' Adding the endcard handler to the video
    ' Show the video view
    m.top.ComponentController.callFunc("show", {
        View: video
    })
    ' Set it to start playing
    video.control = "play"
    return video
end function

sub OnEndcardItemSelected(event as Object)
    item = event.getData()
    video = event.GetRoSGNode()
    video.unobserveField("endcardItemSelected")
    video.close = true

    if item.url <> invalid
        video = OpenVideoPlayerItem(item)
        video.observeField("endcardItemSelected", "OnEndcardItemSelected")
    end if
    ' ? "OnEndcardItemSelected item == "; item
end sub
