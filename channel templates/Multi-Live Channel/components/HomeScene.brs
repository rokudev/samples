
' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

Sub init()
    m.count = 0
    m.AdTimer = m.top.findNode("AdTimer")
    m.Video = m.top.findNode("Video")
    m.RowList = m.top.findNode("RowList")
    m.BottomBar = m.top.findNode("BottomBar")
    m.ShowBar = m.top.findNode("ShowBar")
    m.HideBar = m.top.findNode("HideBar")
    m.Hint = m.top.findNode("Hint")
    m.Timer = m.top.findNode("Timer")
    
    m.Hint.font.size = "20"
    showHint()
    
    m.array = loadConfig()
    if m.array.count() = 1
        m.BottomBar.visible = false
        m.Video.setFocus(true)
    end if
    
    m.AdTimer.control = "start"
    
    m.LoadTask = createObject("roSGNode", "RowListContentTask")
    m.LoadTask.observeField("content", "rowListContentChanged")
    m.LoadTask.control = "RUN"

    m.RowList.setFocus(true)
    m.RowList.rowLabelFont.size = "24"
    
    m.Timer.observeField("fire", "hideHint")
    
    m.AdTimer.observeField("fire", "change")
    m.RowList.observeField("rowItemSelected", "ChannelChange")
End Sub

Sub change()
    m.global.Adtracker = 0
End Sub

Sub  hideHint()
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

function onKeyEvent(key as String, press as Boolean) as Boolean 
    handled = false
        if press
           if key="up" or key = "down"
                   if m.global.Options = 0
                        m.global.Options = 1
                        optionsMenu()
                   else
                        m.global.Options = 0
                        optionsMenu()
                   end if
               handled = true
           end if
        end if
    return handled
end function

Function ChannelChange()
    m.global.AdTracker = 0
    m.Video.content = m.RowList.content.getChild(m.RowList.rowItemFocused[0]).getChild(m.RowList.rowItemFocused[1])
    m.Video.control = "play"
End Function

Sub rowListContentChanged()
    m.RowList.content = m.LoadTask.content
    if m.count = 0
        m.Video.content = m.RowList.content.getChild(0).getChild(0)
        m.Video.control = "play"
        m.count = 1
    end if
End Sub

