' There are two functions depending on whether or not a focus index and isContentList are provided
function OpenVideoPlayer(content, index, isContentList) as Object
    AddBookmarksHandler(content, index)
    ' Create VideoView Object and set its fields
    video = CreateObject("roSGNode", "VideoView")
    video.content = content
    video.jumpToItem = index
    video.isContentList = isContentList
    ' Set it to start playing, it wont begin playback until show() is called
    video.control = "play"
    ' Show the video view
    m.top.ComponentController.callFunc("show", {
        view: video
    })
    return video
end function

function OpenVideoPlayerItem(contentItem) as Object
    ' Create VideoView Object and set its fields
    AddBookmarksHandler(contentItem)

    video = CreateObject("roSGNode", "VideoView")
    video.content = contentItem
    video.isContentList = false
    ' Set it to start playing, it wont begin playback until show() is called
    video.control = "play"
    ' Show the video view
    m.top.ComponentController.callFunc("show", {
        View: video
    })
    return video
end function

Sub AddBookmarksHandler(contentItem as Object, index = invalid as Object)
    if index <> invalid then contentItem = contentItem.getChild(index)
    if contentItem = invalid then return
    contentItem.addField("BookmarksHandler", "assocarray", false)
    contentItem.BookmarksHandler = {name : "RegistryBookmarksHandler", fields : {minBookmark : 10, maxBookmark : 10}}
End Sub
