' ********** Copyright 2016 Roku Inc.  All Rights Reserved. **********

Sub init()
    if CanDecodeAudio()
        loadContent()
    else
        supportDialog()
        m.top.Dialog.observeField("wasClosed", "loadContent")
    end if
End Sub

Sub loadContent()
    m.count = 0
    m.Video = m.top.findNode("Video")
    m.RowList = m.top.findNode("RowList")
    m.BottomBar = m.top.findNode("BottomBar")
    m.ShowBar = m.top.findNode("ShowBar")
    m.HideBar = m.top.findNode("HideBar")
    m.Hint = m.top.findNode("Hint")
    m.Timer = m.top.findNode("Timer")

    showHint()
    m.array = loadContentFeed()

    m.LoadTask = createObject("roSGNode", "RowListContentTask")
    m.LoadTask.observeField("content", "rowListContentChanged")
    m.LoadTask.control = "RUN"

    m.Video.setFocus(true)

    m.Timer.observeField("fire", "hideHint")
    m.RowList.observeField("rowItemSelected", "ChannelChange")
End Sub

Sub hideHint()
    m.Hint.visible = false
End Sub

Sub showHint()
    m.Hint.visible = true
    m.Timer.control = "start"
End Sub

Sub optionsMenu()
    if m.global.Options = 0
        m.ShowBar.control = "start"
        m.RowList.setFocus(true)
        hideHint()
    else
        m.HideBar.control = "start"
        m.Video.setFocus(true)
        showHint()
    End if
End Sub

Function CanDecodeAudio() as Boolean
    dev_info = createObject("roDeviceInfo")
    return dev_info.CanDecodeAudio({"Codec":"eac3"}).result
End Function

Function supportDialog()
    dialog = createObject("roSGNode", "Dialog")
    dialog.title = "Warning"
    dialog.message = "Your current setup is unable to decode Dolby Digital Plus Audio. No audio may be heard if you proceed with playback."
    dialog.buttons = ["Press back to dismiss and play anyways"]
    m.top.dialog = dialog
End Function

Function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false
        if press
            if key="up" and m.global.Options = 1
                m.global.Options = 0
                optionsMenu()
            else if key = "down" and m.global.Options <> 1
                m.global.Options = 1
                optionsMenu()
            end if
            handled = true
        end if
    return handled
End Function

Function ChannelChange()
    m.Video.content = m.RowList.content.getChild(m.RowList.rowItemFocused[0]).getChild(m.RowList.rowItemFocused[1])
    m.Video.control = "play"
    m.global.options = 1
    OptionsMenu()
End Function

Sub rowListContentChanged()
    m.RowList.content = m.LoadTask.content
    if m.count = 0
        m.Video.content = m.RowList.content.getChild(0).getChild(0)
        m.Video.control = "play"
        m.count = 1
    end if
End Sub
