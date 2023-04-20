Sub init()
    m.top.functionName = "bookmarksHandler"
    m.top.ObserveField("state", "onTaskStateChange")
End Sub

Sub onTaskStateChange()
    if m.top.state = "DONE" OR m.top.state = "STOP" then
        UnblockDestroying()
    end if
End Sub

Sub onVideoViewSet()
    if m.top.videoView <> invalid then
        BlockDestroying()
        m.top.control = "RUN"
    end if
End Sub

Sub bookmarksHandler()
    ''?"RUN bookmarksHandler"
    port = CreateObject("roMessagePort")

    topFields    = m.top.GetFields()
    interval     = topFields.interval
    videoView    = topFields.videoView
    minBookmark  = topFields.minBookmark
    maxBookmark  = topFields.maxBookmark

    videoFields  = videoView.GetFields()
    lastPosition = videoFields.position
    lastState    = videoFields.state
    content      = videoFields.content
    duration     = 0

    'Used for handling trick play'
    lastSavedPosition = lastPosition
    'Used for preventing multiple RemoveBookmark calls'
    bookmarkAlreadyRemoved = false

    if videoView.hasField("currentItem") then
        content = videoFields.currentItem
    end if

    if content <> invalid then
        duration = content.length
    end if

    if duration = 0 then
        duration = videoFields.duration
    end if

    m.top.content = content

    NotifyAboutBookmarkPositionChange(content, port)

    videoView.ObserveField("position", port)
    videoView.ObserveField("duration", port)
    videoView.ObserveField("state", port)
    videoView.ObserveField("content", port)
    videoView.ObserveField("currentItem", port)
    videoView.ObserveField("wasClosed", port)

    'Clear all videoView references to avoid memory leak'
    topFields = invalid
    videoView = invalid
    m.top.videoView = invalid

    while true
        msg = Wait(0, port)
        if type(msg) = "roSGNodeEvent" then
            field = msg.getField()
            data  = msg.getData()
            if field = "state" then
                if data = "paused" then
                    if lastSavedPosition <> lastPosition AND lastPosition >= minBookmark then
                        m.top.position = lastPosition
                        SaveBookmark()
                        lastSavedPosition = lastPosition
                        bookmarkAlreadyRemoved = false
                    end if
                else if data = "finished" then
                    if not bookmarkAlreadyRemoved then
                        m.top.position = 0
                        RemoveBookmark()
                        lastSavedPosition = 0
                        bookmarkAlreadyRemoved = true
                    end if
                    exit while
                end if
                lastState = data
            else if field = "position" then
                if data < minBookmark OR data > duration - maxBookmark then
                    if not bookmarkAlreadyRemoved then
                        m.top.position = 0
                        RemoveBookmark()
                        lastSavedPosition = 0
                        bookmarkAlreadyRemoved = true
                    end if
                else if lastPosition <> data AND (data MOD interval = 0 OR abs(data - lastPosition) > interval) then
                    if lastSavedPosition <> data then
                        m.top.position = data
                        SaveBookmark()
                        lastSavedPosition = data
                        bookmarkAlreadyRemoved = false
                    end if
                end if
                lastPosition = data
            else if field = "duration" then
                duration = data
            else if field = "content" OR field = "currentItem" then
                if data <> invalid AND not data.isSameNode(content) then
                    'Reset previous content bookmarkPosition observer and set observer for new content
                    IgnoreBookmarkPositionChange(content)
                    NotifyAboutBookmarkPositionChange(data, port)
                end if
                content = data
                m.top.content = content
                'Used getFields to minimizing randevouz
                'content = GetFieldsIfNode(data)
            else if field = "wasClosed" then
                exit while
            else if lcase(field) = "bookmarkposition" then
                _PrintBookmarkWarningMessage()
            else
                _PrintUnknownFieldWaringMessage()
            end if
        end if
    end while
    if content <> invalid then
        'Update bookmark position in content node on close
        IgnoreBookmarkPositionChange(content)
        content.bookmarkPosition = lastSavedPosition
    end if
End Sub

Function GetFieldsIfNode(obj as Object) as Object
    if FindMemberFunction(obj, "GetFields") <> invalid then
        obj = obj.GetFields()
    end if
    return obj
End Function

Sub IgnoreBookmarkPositionChange(content as Object, ignore = true as Boolean, port = invalid as Object)
    if content <> invalid then
        if ignore then
            content.unobserveFieldScoped("BookmarkPosition")
        else
            content.observeFieldScoped("BookmarkPosition", port)
        end if
    end if
End Sub

Sub NotifyAboutBookmarkPositionChange(content as Object, port as Object)
    IgnoreBookmarkPositionChange(content, false, port)
End Sub


Sub _PrintBookmarkWarningMessage()
    ?
    ?"WARNING!!!"
    ?"You have changed a BookmarkPosition field of video content, it could cause playback rebuffering and stop"
    ?"Please store bookmark into the registry or do API request for this"
    ?
End Sub

Sub _PrintUnknownFieldWaringMessage()
    ?
    ?"WARNING!!!"
    ?"BookmarksTask::Unknown field triggered '" field "'"
    ?
End Sub

'Used for avoiding extra references storing for BookmarksTask'
Sub UnblockDestroying()
    if m.node <> invalid then
        m.node.RemoveChild(m.top)
        m.node = invalid
    end if
End Sub

Sub BlockDestroying()
    if m.node = invalid then
        m.node = CreateObject("roSGNode", "Node")
    end if
    m.node.appendChild(m.top)
End Sub



'developer have to override this function in own bookmarks handler'
Sub SaveBookmark()
    content = m.top.content
    position = m.top.position
    ?"WARNING: You have to override 'SaveBookmark(content as Object, position as Integer) as Void' function in your "m.top.subtype()" component"
    ?"SaveBookmark for "content.title" = "position
End Sub

Function GetBookmark() as Integer
    content = m.top.content
    ?"WARNING: You have to override 'GetBookmark(content as Object) as Integer' function in your "m.top.subtype()" component"
    ?"GetBookmark for "content.title
    return 0
End Function

Sub RemoveBookmark()
    content = m.top.content
    ?"WARNING: You have to override 'RemoveBookmark(content as Object)' function in your "m.top.subtype()" component"
    ?"RemoveBookmark for "content.title
End Sub
