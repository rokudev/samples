' Copyright (c) 2018 Roku, Inc. All rights reserved.

' README:
' VideoView is a SGDEX component to play video items or playlists
' In channel developer create VideoView,
' set content - it is a playlist, has childs with items
' to configure starting item, there is jumpToItem field see OnJumpToItem field
' and to configure to play - set control to "play"
' there is possibility to set "buffering" control
'   video = CreateObject("roSGNode", "VideoView")
'   video.content = content
'   video.jumpToItem = index
'   video.control = "play"

' starting point in this file is OnControlSet function

sub Init()
    m.top.ObserveField("content", "OnContentSet")

    ' control of VideoView is not alias to Video node control
    ' this is made to call HandlerConfigVideo to load video url, etc
    ' before actual videoNode.control = "play"
    m.top.ObserveField("control", "OnControlSet")

    ' User can set isContentList after content set of jump to item set
    ' to handle this case lib need to call some callbacks again
    m.top.ObserveField("isContentList", "OnIsContentListChanged")

    ' When VideoView is closed we need to stop Video Node,
    ' Stop RAF task if it exist
    m.top.ObserveField("wasClosed", "OnVideoWasClosed")

    ' jumpToItem - field to navigate between items in playlist
    ' with most cases it will be set once, before VideoView is shown
    m.top.ObserveField("jumpToItem", "OnJumpToItem")

    ' field to set what item should be played next
    ' it triggers content loading for current item
    m.top.ObserveField("currentIndex", "OnCurrentIndex")

    m.top.ObserveField("preloadContent", "OnPreloadContent")

    ' when content for current item is loaded, currentItem field is set
    ' in OnCurrentItem RAF task is created if config for RAF exist
    ' of Video Node control set
    ' It is triggered manually by OnCurrentItem() to make an ability to remove HandlerConfigs while video is playing
    ' m.top.ObserveField("currentItem", "OnCurrentItem")

    ' Time how much endcard should count before close or move to next video
    ' if user don't do anything
    m.top.ObserveField("endcardCountdownTime", "OnEndcardCountdownTimeChange")

    m.top.ObserveField("disableScreenSaver", "OnDisableScreensaver")

    ' endcardView is saved locally to work with it
    m.endcardView = Invalid

    ' based on endcardContent we decide - should we show endcard view or not
    m.endcardContent = Invalid

    ' internal flag to know did we already load content for endcard View or not
    m.isEndcardLoaded = false

    ' internal field to know did we already create the bookmark handler
    m.isBookmarkHandlerCreated = false

    ' Video Node creates dynamically for each video item
    ' this is made because there is some firmware issue and RAF triggers state
    ' of video node
    CreateVideoNode()

    ' Internal flag to know if we able to play current video (if content is loaded)
    m.ableToPlay = false

    ' Internal var to know if endcard time is over and start next video
    ' or close Video View
    m.time = m.top.endcardCountdownTime

    m.top.ObserveField("wasShown", "OnVideoViewWasShown")

    ' PRIVATE field for library managers
    m.ContentManager_id = 0
    m.debug = false

    ' Internal flag to signalize possibility to play content after EndcardView closes
    ' and next content is preloaded in background
    m.shouldStartPlaybackAfterHiddenLoading = false
end sub


' isContentList callback reruns currentIndex callback for case
' if user set isContentList after setting content or jumpToItem
sub OnIsContentListChanged()
    if m.top.content <> invalid and m.top.jumpToItem >= 0
        OnCurrentIndex()
    end if
end sub

' Function deletes current Video Node: stops, remove observes, invalidates
' and removes from parent - from VideoView; then creates new Video Node,
' configure it, set themes and create new observes
sub CreateVideoNode() as Object
    ? "[SGDEX] CreateVideoNode()"
    ClearVideoNode()
    m.isBookmarkHandlerCreated = false

    video = m.top.createChild("Video")
    video.id = "video"
    video.width = "1280"
    video.height = "720"
    video.translation = "[0,0]"
    video.enableUI = "false"
    video.disableScreenSaver = m.top.disableScreenSaver

    'Set m.video before setting theme as theme require m.video to be populated
    m.video = video

    if m.LastThemeAttributes <> Invalid then
        SGDEX_SetTheme(m.LastThemeAttributes)
    end if

    video.ObserveFieldScoped("position", "OnPositionChanged")
    video.ObserveFieldScoped("duration", "OnDurationChanged")
    video.ObserveFieldScoped("state", "OnVideoStateChanged")
end sub

Sub ClearVideoNode()
    if m.video <> Invalid
        m.video.UnobserveFieldScoped("position")
        m.video.UnobserveFieldScoped("duration")
        m.video.UnobserveFieldScoped("state")
        m.video.control = "stop"
        m.video.content = Invalid

        ' TODO Remove after v1.1
        ' Added toStr() to m.top.content to pass by value, not roString reference, so next lines are no longer need
        ' ' this should be done because for some reason video node is not released for some time and new one can't be created
        ' ' m.top.control = "none" ' workaround to release Video View interface field

        m.top.removeChild(m.video)
        m.video = Invalid
    end if
End Sub

sub OnPreloadContent()
    preloadContent = m.top.preloadContent
    if preloadContent and m.top.content <> invalid and m.video <> invalid
        ' preload content only if it not buffering yet
        if m.video.state <> "buffering" and m.video.state <> "playing"
            m.top.control = "prebuffer"
        end if
    end if
end sub

sub OnVideoViewWasShown(event as Object)
    if m.video <> Invalid and not m.video.HasFocus()
        m.video.SetFocus(true)
    end if

    ' this if needed for starting playback
    ' if user set control play before view was shown
    if not m.top.preloadContent then OnCurrentIndex()
end sub

sub OnContentSet(event as Object)
    ' developers should implement their own OnContentSet to update the buttons etc.
    if m.ableToPlay
        ' try to preload content only if content is valid
        OnPreloadContent()
    end if
end sub

' When control of Video View is set, this sub triggers
' it decide should control should be passed to Video Node or not
' if control is "play" or "prebuffer" and we didn't have a content to play
' then content is in loading
' if it is a first shown and jumpToItem didn't set, assume to start playlist form first item
' and set currentIndex to 0
'
' @param event [roSGNodeEvent] - m.top.control field event
sub OnControlSet(event as Object)
    ' Control field is roString type we should change it to String to force firmware to pass
    ' it by value, not reference
    control = event.GetData().toStr()
    if m.video = invalid or control = invalid then return
    if (control = "play" or control = "prebuffer")
        ' TODO Make logic for play or prebuffer here if needed
        ' Play video when ready and no raf config or raf task was not started
        if m.ableToPlay and (m.rafHandlerConfig = Invalid or m.rafTask = invalid)
            GetRafConfigAndPlayVideo(control)
        else
            if m.top.currentIndex = - 1 then m.top.currentIndex = 0
        end if
    else
        m.video.control = control
    end if
end sub

' Handled states of video node
' Check if we should close it
' check if video is finished - should we show Endcards or not
'
' @param event [roSGNodeEvent] - m.video.state field event
sub OnVideoStateChanged(event as Object)
    state = event.GetData()
    m.top.state = state
    handled = false
    if m.video <> Invalid then
        statesToClose = {
            finished: ""
            error: ""
        }

        if state = "finished"
            ' If there is content for endcard, show it and start timer to next video
            if m.endcardContent <> Invalid or m.top.alwaysShowEndcards
                ' Hide Video node and show endcard view
                m.video.visible = false
                m.video.content = invalid

                CreateVideoNode()
                ShowEndcardView()

                ' Handled == true to not close VideoView
                handled = true
                ' If endcard content not available, but there is a playlist item, play it
            else if m.top.content.GetChildCount() > m.top.currentIndex + 1
                CreateVideoNode()

                m.top.currentIndex = m.top.currentIndex + 1
                ' m.top.control = "play" ' currentIndex callback should start playback automatically
                handled = true
            end if
        end if

        if not handled and statesToClose[state] <> Invalid then
            errorCode = m.video.errorCode or (m.video.errorMsg <> invalid and m.video.errorMsg <> "")
            if errorCode <> 0
                ? "[SGDEX] video.errorCode == ";m.video.errorCode; " video.errorMsg == "; m.video.errorMsg
            end if

            ' This field is observed by library, so it will close this View and show previous
            ' if you set this field to non top View it will just remove it from stack
            m.top.close = true
        end if
    end if
end sub

' When jumpToItem set we move to specified video to play
sub OnJumpToItem()
    content = m.top.content
    ' check of content is available, and there is a child to play
    if content <> Invalid and m.top.jumpToItem >= 0 and content.GetChildCount() > m.top.jumpToItem
        m.top.currentIndex = m.top.jumpToItem
    end if
end sub

' Timer fired handler - to hide EndcardView and go to next video after time ended
' if there is no any video to play, close VideoView
sub OnEndcardTimerFired()  ' Don't insert event as parameter to use this callback as function.
    m.time = m.endcardView.timerFired
    if m.time = 0
        ' when endcard time end, invalidate endcard content
        HideEndcardView()
        ' CreateVideoNode() ' Removed creating new video node each time
        hasNextItemInPlaylist = (m.top.content.GetChildCount() > m.top.currentIndex + 1)
        ' if there is some video in playlist, show Video node and go to next video
        if hasNextItemInPlaylist
            m.top.currentIndex = m.top.currentIndex + 1
            ' m.top.control = "play" ' currentIndex callback should start playback automatically
            m.video.visible = true
            m.video.SetFocus(true)
        else ' if there is no video available, close the View
            m.top.close = true
        end if
    end if
end sub

' Creates EndcardView, configure it with required fields
' check if there is a RAF task - for postrolls
' and observe items to get channel know that user presses a button
' or repeats video on Repeat button selected
sub ShowEndcardView()
    ' We should delete HandlerConfigEndcard only if endcard View was shown
    ' not in case if user started playback and goes back
    if m.top.currentItem <> Invalid
        m.top.currentItem.HandlerConfigEndcard = invalid
    end if

    m.endcardView = CreateObject("roSGNode", "EndcardView")
    m.endcardView.visible = false
    m.top.appendChild(m.endcardView)
    m.endcardView.id = "endcardView"
    m.endcardView.translation = "[0, 0]"
    m.endcardView.endcardCountdownTime = m.top.endcardCountdownTime
    hasNextItemInPlaylist = (m.top.content.GetChildCount() > m.top.currentIndex + 1)
    m.endcardView.hasNextItemInPlaylist = hasNextItemInPlaylist
    if m.top.posterShape <> ""
        m.endcardView.posterShape = m.top.posterShape
    end if

    ' TODO Add check if endcardContent is valid
    if m.endcardContent <> Invalid
        m.endcardView.content = m.endcardContent
    end if

    ' Do not move this line after "m.endcardView.visible = true"
    m.endcardView.ObserveField("visible", "OnEndcardVisible")

    if not (m.RafTask <> Invalid and m.RafTask.state <> "DONE")
        m.endcardView.visible = true
        m.endcardView.SetFocus(true)
        m.endcardView.startTimer = true
    end if

    m.endcardView.ObserveField("rowItemSelected", "OnEndcardRowItemSelected")
    m.endcardView.ObserveField("repeatButtonSelectedEvent", "OnRepeatButtonSelected")
    m.endcardView.ObserveField("timerFired", "OnEndcardTimerFired")

    hasNextItemInPlaylist = (m.top.content.GetChildCount() > m.top.currentIndex + 1)
    if hasNextItemInPlaylist and m.top.preloadContent
        ' Start loading of next item in playlist
        nextItem = m.top.content.getChild(m.top.currentIndex + 1)
        nextHandlerConfigVideo = nextItem.HandlerConfigVideo
        LoadContentHidden(nextItem, nextHandlerConfigVideo)
    end if
end sub

' sub OnEndcardVisible(event as Object)
'     endcardViewVisible = event.GetData()
'     if endcardViewVisible
'         ' Additional clearing of video node when endcard view is shown
'         ' ClearVideoNode() ' Removed creating new video node each time
'     end if
' end sub

' Invalidate EndcardView, reset local config vars
sub HideEndcardView()
    m.endcardView.visible = false
    m.isEndcardLoaded = false
    m.endcardContent = Invalid

    m.endcardView.UnobserveField("rowItemSelected")
    m.endcardView.UnobserveField("repeatButtonSelectedEvent")
    m.endcardView.UnobserveField("timerFired")

    m.top.RemoveChild(m.endcardView)
    m.endcardView = Invalid
end sub

' If user select some item on Endcard View
' this callback triggered there are 2 use cases
' - user pressed on first item (next item in playlist) - move to next item and play
' - user selected some other item - move execution to channel
'
' @param event [roSGNodeEvent] - m.endcardView.rowItemSelected field event - array of integers [row, col]
sub OnEndcardRowItemSelected(event as Object)
    endcardRowItem = event.GetData()
    row = endcardRowItem[0]
    col = endcardRowItem[1]
    endcardRowContent = m.endcardContent.GetChild(row)
    hasNextItemFromPlaylist = (m.top.content.GetChildCount() > m.top.currentIndex + 1)

    ' user pressed on first item - move to next video
    if row = 0 and col = 0 and hasNextItemFromPlaylist
        HideEndcardView()
        ' CreateVideoNode() ' Removed creating new video node each time
        m.top.currentIndex = m.top.currentIndex + 1
        m.top.control = "play"
        m.video.visible = true
        m.video.SetFocus(true)

    ' user pressed other item - move execution to channel
    else if endcardRowContent <> Invalid
        m.top.close = true ' close endcard view when user select some item
        m.top.endcardItemSelected = endcardRowContent.GetChild(col)
    else ' just in case
        m.top.close = true
    end if
end sub

' If user press Repeat button on Endcard View - need to Hide Endcard view
' and configure Video Node to replay current item
sub OnRepeatButtonSelected()
    HideEndcardView()

    ' TODO Possible short workaround
    ' m.top.currentItem = m.video.content

    ' TODO Possible smart workaround
    ' currentIndex is alwaysModify=true field; when value is set, it triggers Video content getter reload, start Raf task, etc.
    ' to replay video it is enought to trigger currentIndex callback and all chain of expected tasks will be done.
    m.top.currentIndex = m.top.currentIndex
    m.top.control = "play"
end sub

' Function handles index of item to play change
' if there is a possibility to load content - HandlerConfigVideo is set - it calls LoadMoreContent
' otherwise - m.top.currentItem field is set
sub OnCurrentIndex()
    currentIndex = m.top.currentIndex
    currentItem = Invalid
    m.ableToPlay = false
    m.isEndcardLoaded = false

    if m.top.isContentList
        currentItem = m.top.content.GetChild(m.top.currentIndex)
    else
        '? "this is not list"
        ' TODO add logic here if needed
        currentItem = m.top.content
    end if

    if currentItem <> Invalid
        HandlerConfigVideo = currentItem.HandlerConfigVideo

        if HandlerConfigVideo = Invalid and m.hiddenLoadTask = invalid and IsContentLoaded()
            m.top.currentItem = currentItem
            OnCurrentItem()
        else if (m.top.wasShown or m.top.preloadContent)
            m.loadingfacade = m.top.createChild("LoadingFacade")
            m.loadingfacade.bEatKeyEvents = false
            ' TODO Possibly refactor this if
            if HandlerConfigVideo <> invalid and m.hiddenLoadTask = invalid
                currentItem.HandlerConfigVideo = invalid
                LoadMoreContent(currentItem, HandlerConfigVideo)
            else if HandlerConfigVideo = invalid and m.hiddenLoadTask <> invalid
                m.shouldStartPlaybackAfterHiddenLoading = true
            end if
        end if
    else if m.top.isContentList and  m.top.content.getChildCount() = 0 and  m.top.content.HandlerConfigVideo <> invalid then
        'we need to load root list first
        config = m.top.content.HandlerConfigVideo

        callback = {
            config: config

            onReceive: function(data)
                gthis = GetGlobalAA()
                'notify this function again
                gthis.top.currentIndex = gthis.top.currentIndex
            end function

            onError: function(data)
                gthis = GetGlobalAA()
                if gthis.top.content.HandlerConfigVideo <> invalid then
                    m.config = gthis.top.content.HandlerConfigVideo
                    gthis.top.content.HandlerConfigVideo = invalid
                end if
                GetContentData(m, m.config, gthis.top.content)
            end function
        }
        'clear callback
        m.top.content.HandlerConfigVideo = invalid
        GetContentData(callback, config, m.top.content)
    end if
end sub

' Return false if content handler is running
' Return true otherwise
function IsContentLoaded()
    isLoaded = true
    if m.contentHandler <> invalid and m.contentHandler.state = "run"
        ' if content handler is running the content is not loaded yet
        isLoaded = false
    end if
    return isLoaded
end function

' Function handles case when content for current item to play is set, 2 cases:
' - there is all required content in content node
' - user set HandlerConfigVideo and HandlerConfigVideo Task finishes
' Then it checks what control is set to VideoView - topControl
' if topControl if play or prebuffer we need to configure RAF or pass that control to Video Node
' if there is rafHandler set, it creates RafTask and set current Video Node to it
' callback will be executed after RafTask is finished - when video finishes
' after that EndCard view should be shown and started
' And Invalidate RafTask to prevent memory leaks
sub OnCurrentItem()
    m.ableToPlay = true
    currentItem = m.top.currentItem
    topControl = m.top.control.toStr() ' we should pass it by value, not roString reference

    ' Create new Video Node each time we start new video playback
    ' to prevent firmware issues
    if m.video <> invalid then m.video.visible = true
    ' CreateVideoNode() ' Removed creating new video node each time

    if not m.isBookmarkHandlerCreated then CreateBookmarksHandler()

    ' Set content node that we receive to Video Node
    SetVideoContent(currentItem)
    'invalidate only once as GetRafConfigAndPlayVideo might be called often but config will be deleted from item
    m.rafHandlerConfig = invalid
    ExtractRafConfig()
    if topControl = "play" or topControl = "prebuffer"
        GetRafConfigAndPlayVideo(topControl)
    end if
end sub

sub GetRafConfigAndPlayVideo(control)
    ' If Raf config set, need to create RAF task

    ExtractRafConfig()
    if m.rafHandlerConfig <> invalid and m.rafHandlerConfig.name <> ""
        rafTask = StartRafTask(m.rafHandlerConfig, m.video)
        if rafTask = invalid
            m.video.enableUI = true
            m.video.SetFocus(true)
            m.video.control = control
        end if
    else if m.video <> invalid ' if RAF is not set, just pass control directly to Video Node
        m.video.enableUI = true
        if m.top.wasShown then m.video.SetFocus(true)
        m.video.control = control
    end if
end sub

sub ExtractRafConfig()
    currentItem = m.top.currentItem
    topControl = m.top.control
    if (currentItem.handlerConfigRAF <> invalid and currentItem.handlerConfigRAF.name <> "") then
        m.rafHandlerConfig = currentItem.handlerConfigRAF
        currentItem.handlerConfigRAF = invalid
    else if (m.top.content.handlerConfigRAF <> invalid and m.top.content.handlerConfigRAF.name <> "") then
        m.rafHandlerConfig = m.top.content.handlerConfigRAF
    else if (m.top.handlerConfigRAF <> invalid and m.top.handlerConfigRAF.name <> "") then
        m.rafHandlerConfig = m.top.handlerConfigRAF
    end if
end sub

sub CreateBookmarksHandler()
    currentItem = m.top.currentItem
    if currentItem <> invalid then
        BookmarksHandler = currentItem.BookmarksHandler
        if BookmarksHandler <> invalid AND BookmarksHandler.name <> invalid then
            node = GetNodeFromChannel(BookmarksHandler.name)
            if node <> invalid then
                m.isBookmarkHandlerCreated = true
                if BookmarksHandler.fields <> invalid then node.setFields(BookmarksHandler.fields)
                node.videoView = m.top
            else
                ?"Error : Unable to create BookmarksHandler with type " NodeName
            end if
        else
            '?"Error : Invalid BookmarksHandler config"
        end if
    end if
end sub

' Function creates a Raf handler task with provided config and video
'
' @param rafHandlerConfig [AA] - config {name : "name_of_handler_in_channel", fields : {"some_field":"some_value"}}
' @param video [Video Node] - video node that should be passed to RafTask
'
' @return RafTask [Object] - Raf handler task that was created
function StartRafTask(rafHandlerConfig as Object, video as Object) as Object
    callback = {
        onReceive: function(data)
            m.onResult(data)
        end function

        onError: function(data)
            m.onResult(data)
        end function

        onResult: function(data)
            endcardView = GetGlobalAA().endcardView
            if endcardView <> Invalid
                endcardView.visible = true
                endcardView.setFocus(true)
                endcardView.startTimer = true
            end if
            if GetGlobalAA().RafTask <> Invalid
                GetGlobalAA().RafTask.video = Invalid
                GetGlobalAA().RafTask = Invalid
            end if
        end function
    }
    m.RafTask = GetContentData(callback, rafHandlerConfig, CreateObject("roSGNode", "ContentNode"))
    if m.RafTask <> Invalid
        m.RafTask.video = video
    end if
    return m.RafTask
end function

' Function to save max time locally
' @param event [roSGNodeEvent] - m.top.endcardCountdownTime field event - integer with number of seconds
sub OnEndcardCountdownTimeChange(event as Object)
    endcardCountdownTime = event.GetData()
    m.time = endcardCountdownTime
end sub

' This function will be called in both cases when video finishes or when user presses back
' when user presses back, View manger will handle it and remove top View from view
' Should stop video node and Raf task here to prevent some bugs

' @param event [roSGNodeEvent] - m.top.wasClosed field event - boolean
sub OnVideoWasClosed(event as Object)
    ClearVideoNode()

    if m.RafTask <> Invalid
        m.RafTask.control = "stop"
    end if
end sub

' Updates duration in interface
Sub OnDurationChanged(event as Object)
    duration = event.GetData()
    m.top.duration = duration
End Sub

' Handles position of video playback
' m.top.endcardLoadTime - how much seconds to the end of playback we should load endcards
' If Time has come - load Endcard content

' @param event [roSGNodeEvent] - m.video.position field event - float
sub OnPositionChanged(event as Object)
    duration = m.video.duration
    position = event.GetData()
    m.top.position = position

    ' If required time comes
    if duration - position <= m.top.endcardLoadTime
        m.top.endcardTrigger = true
        if m.isEndcardLoaded = false
            HandlerConfigEndcard = m.top.currentItem.HandlerConfigEndcard
            endcardContent = CreateObject("roSGNode", "ContentNode")
            if HandlerConfigEndcard <> Invalid AND HandlerConfigEndcard.name <> Invalid ' if there is a name for handler, try to load content
                LoadEndcardContent(endcardContent, HandlerConfigEndcard)
                m.isEndcardLoaded = true
            ' if user didn't specify HandlerConfigEndcards, we add next item in playlist
            ' to show at endcards by default
            else if m.top.alwaysShowEndcards OR HandlerConfigEndcard <> Invalid ' if there is empty HandlerConfigEndcard add default endcards.
                nextItem = Utils_CopyNode(m.top.content.GetChild(m.top.currentIndex + 1))
                if nextItem <> Invalid
                    rowContent = CreateObject("roSGNode", "ContentNode")
                    rowContent.AppendChild(nextItem)
                    endcardContent.AppendChild(rowContent)
                end if
                m.endcardContent = endcardContent
                m.isEndcardLoaded = true
            end if
        end if
    else if m.top.endcardTrigger = true
        m.top.endcardTrigger = false
    end if
end sub

' ******************************************************************************
' ** Helper functions
' ******************************************************************************

' Sets content to video node
'
' @param content [ContentNode] - content to set to Video Node
sub SetVideoContent(content as Object)
    if content <> Invalid and m.video <> Invalid
        if m.video.content = invalid or not m.video.content.isSameNode(content)
            m.video.content = content.clone(false) ' clone - To make sure if we update content node in View it will not affect playback
        end if
    end if
end sub

' Loads content with HandlerConfig and set if to m.top.currentItem
'
' @param content [ContentNode] - content to set to m.top.currentItem
' @param HandlerConfig [AA] - config with Content getter to create
sub LoadMoreContent(content, HandlerConfig)
    ' Need to hide previous video player if it exist before loading content for new one
    if m.video <> invalid then m.video.visible = false
    callback = {
        lastFocusedItem: m.top.currentIndex
        content: content
        config: HandlerConfig
        mAllowEmptyResponse: true

        onReceive: function(data)
            top = GetGlobalAA().top
            loadingfacade = GetGlobalAA().loadingfacade
            top.RemoveChild(loadingfacade)
            GetGlobalAA().loadingfacade = invalid

            GetGlobalAA().top.currentItem = data
            OnCurrentItem()
        end function

        onError: function(data)
            if m.lastFocusedItem = GetGlobalAA().top.currentIndex
                if m.content.HandlerConfigVideo <> invalid then
                    m.config = m.content.HandlerConfigVideo
                    m.content.HandlerConfigVideo = invalid
                end if
                GetContentData(m, m.config, m.content)
            end if
        end function
    }

    m.contentHandler = GetContentData(callback, HandlerConfig, content)
end sub

' Load content for item in background
sub LoadContentHidden(content, HandlerConfig)
    if content.HandlerConfigVideo <> invalid
        content.HandlerConfigVideo = invalid
    end if
    if content <> invalid and HandlerConfig = invalid
        ' RDE-2412: start preloading of the content
        ' when there is no handler config for video
        globalAA = GetGlobalAA()
        globalAA.video.content = content
        globalAA.video.control = "prebuffer"
    else
        callback = {
            mAllowEmptyResponse: true

            onReceive: function(data)
                top = GetGlobalAA().top
                globalAA = GetGlobalAA()

                ' Remove loading facade if it is shown
                ' It is shown automatically after endcards timer finished
                loadingfacade = GetGlobalAA().loadingfacade
                if loadingFacade <> invalid
                    top.RemoveChild(loadingfacade)
                    globalAA.loadingfacade = invalid
                end if

                if globalAA.shouldStartPlaybackAfterHiddenLoading
                    globalAA.top.currentItem = data
                    OnCurrentItem()
                    globalAA.shouldStartPlaybackAfterHiddenLoading = false
                else
                    ' Endcard is still shown
                    if globalAA.top.preloadContent
                        ' Which means that content is loaded so VideoView can
                        ' prebuffer Video node
                        globalAA.video.content = data
                        globalAA.video.control = "prebuffer"
                    end if
                end if

                globalAA.hiddenLoadTask = invalid
            end function
        }

        m.hiddenLoadTask = GetContentData(callback, HandlerConfig, content)
    end if
end sub

' Loads content for Endcards with HandlerConfig
' prepares content node
' and set if to m.top.currentItem
'
' @param content [ContentNode] - content to set to m.endcardContent
' @param HandlerConfig [AA] - config with Content getter to create
sub LoadEndcardContent(content, HandlerConfig)
    callback = {
        nextItem: Utils_CopyNode(m.top.content.GetChild(m.top.currentIndex + 1))
        content: content
        HandlerConfig: HandlerConfig
        onReceive: function(content) ' content is the same node that passed to LoadEndcardContent
            if m.nextItem <> Invalid and content <> Invalid and content.GetChild(0) <> Invalid
                content.GetChild(0).InsertChild(m.nextItem, 0)
            end if
            GetGlobalAA().endcardContent = content
        end function

        onError: function(content)
            if m.content.HandlerConfigEndcard <> invalid then
                m.config = m.content.HandlerConfigEndcard
                m.content.HandlerConfigEndcard = invalid
            end if
            GetGlobalAA().endcardContent = content
            GetContentData(m, m.HandlerConfig, m.content)
        end function
    }

    GetContentData(callback, HandlerConfig, content)
end sub

' ******************************************************************************
' ** Themes functions
' ******************************************************************************

sub SGDEX_SetTheme(theme as Object)
    SGDEX_setThemeFieldstoNode(m, {
        TextColor: {
            video: [
                "bufferingTextColor",
                "retrievingTextColor"
                {
                    trickPlayBar:  [
                        "textColor"
                        "thumbBlendColor"
                        "trackBlendColor"
                        "currentTimeMarkerBlendColor"
                    ]
                    retrievingBar: [
                        "trackBlendColor"
                    ]
                    bufferingBar: [
                        "trackBlendColor"
                    ]
                }
            ]
        }
        progressBarColor: {
            video: [{
                trickPlayBar:  [
                    "filledBarBlendColor"
                ]
                retrievingBar: [
                    "filledBarBlendColor"
                ]
                bufferingBar: [
                    "filledBarBlendColor"
                ]
            }]
        }
    }, theme)

    themeAttributes = {
        ' trickplay Bar customization
        trickPlayBarTextColor:                      { video: { trickPlayBar: "textColor" } }
        trickPlayBarTrackImageUri:                  { video: { trickPlayBar: "trackImageUri" } }
        trickPlayBarTrackBlendColor:                { video: { trickPlayBar: "trackBlendColor" } }
        trickPlayBarThumbBlendColor:                { video: { trickPlayBar: "thumbBlendColor" } }
        trickPlayBarFilledBarImageUri:              { video: { trickPlayBar: "filledBarImageUri" } }
        trickPlayBarFilledBarBlendColor:            { video: { trickPlayBar: "filledBarBlendColor" } }
        trickPlayBarCurrentTimeMarkerBlendColor:    { video: { trickPlayBar: "currentTimeMarkerBlendColor" } }

        ' Buffering Bar customization
        bufferingTextColor:                         { video: "bufferingTextColor" }
        bufferingBarEmptyBarImageUri:               { video: { bufferingBar: "emptyBarImageUri" } }
        bufferingBarFilledBarImageUri:              { video: { bufferingBar: "filledBarImageUri" } }
        bufferingBarTrackImageUri:                  { video: { bufferingBar: "trackImageUri" } }

        bufferingBarTrackBlendColor:                { video: { bufferingBar: "trackBlendColor" } }
        bufferingBarEmptyBarBlendColor:             { video: { bufferingBar: "emptyBarBlendColor" } }
        bufferingBarFilledBarBlendColor:            { video: { bufferingBar: "filledBarBlendColor" } }

        ' Retrieving Bar customization
        retrievingTextColor:                        { video: "retrievingTextColor" }
        retrievingBarEmptyBarImageUri:              { video: { retrievingBar: "emptyBarImageUri" } }
        retrievingBarFilledBarImageUri:             { video: { retrievingBar: "filledBarImageUri" } }
        retrievingBarTrackImageUri:                 { video: { retrievingBar: "trackImageUri" } }

        retrievingBarTrackBlendColor:               { video: { retrievingBar: "trackBlendColor" } }
        retrievingBarEmptyBarBlendColor:            { video: { retrievingBar: "emptyBarBlendColor" } }
        retrievingBarFilledBarBlendColor:           { video: { retrievingBar: "filledBarBlendColor" } }
    }
    SGDEX_setThemeFieldstoNode(m, themeAttributes, theme)
end sub

function SGDEX_GetViewType() as String
    return "videoView"
end function

sub OnDisableScreensaver(event)
    disableScreenSaver = event.GetData()
    if m.video = invalid or disableScreenSaver = invalid then return
    m.video.disableScreenSaver = disableScreenSaver
end sub
