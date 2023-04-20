' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 
 ' inits grid screen
 ' creates all children
 ' sets all observers 
Function Init()
    ' listen on port 8089
    ? "[HomeScene] Init"

    'main grid screen node
    m.GridScreen = m.top.findNode("GridScreen")
    'video player node
    m.videoPlayer = m.top.findNode("videoPlayer")

    'added handler on item selecting event in grid screen
    m.top.observeField("rowItemSelected", "OnRowItemSelected")
    
    ' loading indicator starts at initializatio of channel
    m.loadingIndicator = m.top.findNode("loadingIndicator")
End Function 

' Row item selected handler
Sub OnRowItemSelected()
    ? "[HomeScene] OnRowItemSelected"
    m.GridScreen.visible = "false"
    selectedItem = m.GridScreen.focusedContent
    
    'init of video player and start playback
    m.videoPlayer.visible = true
    m.videoPlayer.setFocus(true)
    m.videoPlayer.content = selectedItem
    m.videoPlayer.control = "play"
    m.videoPlayer.observeField("state", "OnVideoPlayerStateChange")
End Sub

Sub OnVideoPlayerStateChange()
    ? "HomeScene > OnVideoPlayerStateChange : state == ";m.videoPlayer.state
    if m.videoPlayer.state = "error"
        'hide vide player in case of error
        m.videoPlayer.visible = false
        m.GridScreen.visible = true
        m.GridScreen.setFocus(true)
    else if m.videoPlayer.state = "playing"
    else if m.videoPlayer.state = "finished"
        'hide vide player if video is finished
        m.videoPlayer.visible = false
        m.GridScreen.visible = true
        m.GridScreen.setFocus(true)
    end if
end Sub

' if content set, focus on GridScreen
Sub OnChangeContent()
    ? "OnChangeContent "
    m.GridScreen.setFocus(true)
    m.loadingIndicator.control = "stop"
End Sub

' Main Remote keypress event loop
Function OnkeyEvent(key, press) as Boolean
    ? ">>> HomeScene >> OnkeyEvent"
    result = false
    if press
        ? "key == ";key

        if key = "options"
            ' option key handler
        else if m.GridScreen.visible = false and key = "back"
            'hide vide player and stop playback if back button was pressed
            m.videoPlayer.visible = false
            m.videoPlayer.control = "stop"
            m.GridScreen.visible = true
            m.GridScreen.setFocus(true)
            result = true
        end if
    end if

    return result
End Function
