' Copyright (c) 2018 Roku, Inc. All rights reserved.

' README:
' EndcardView is a SGDEX component to render Endcards
' No business logic is made in Endcard view
' developer should set all fields outside and handle fields triggered
Sub Init()
    ' focusedChild used internally to handle first time shown - what item on View should be shown
    m.top.ObserveField("focusedChild", "OnFocusedChildChange")

    ' posterShape is passed to Grid
    m.top.posterShape = "16x9"
    m.top.ObserveField("posterShape", "OnPosterShape")

    ' content field is node passed directly to grid
    m.top.ObserveField("content", "OnContentChanged")

    ' OnEndcardCountdownTimeChange used internally to update m.time
    m.top.ObserveField("endcardCountdownTime", "OnEndcardCountdownTimeChange")

    ' OnEndcardRowItemFocused and OnRepeatButtonFocused used to stop countdown timer
    m.top.ObserveField("rowItemFocused", "OnEndcardRowItemFocused")
    m.top.ObserveField("repeatButtonFocusedEvent", "OnRepeatButtonFocused")

    ' startTimer is public control field to start a countdown - it is made because
    ' there could be use cases when view is created but not shown, so developer should
    ' start countdown explicitly
    m.top.ObserveField("startTimer", "OnStartTimerSet")

    ' m.FocusableGroup used to check is user focused on View
    m.FocusableGroup = m.top.FindNode("FocusableGroup")

    m.grid = m.top.FindNode("grid")

    ' add fields for themes support
    m.grid.AddField("itemTextColorLine1", "color", true)
    m.grid.AddField("itemTextColorLine2", "color", true)

    ' Timer prompt with countdown
    m.timerLabel = m.top.FindNode("timerLabel")

    ' Configure Repeat button content
    repeatContent = CreateObject("RoSGNode", "ContentNode")
    buttonContent = CreateObject("RoSGNode", "ContentNode")
    buttonContent.title = Tr("Play again")
    repeatContent.AppendChild(buttonContent)
    m.repeatButton = m.top.FindNode("repeatButton")
    m.repeatButton.content = repeatContent

    m.endcardTimer = m.top.FindNode("endcardTimer")
    m.endcardTimer.ObserveField("fire", "OnEndcardTimerFired")

    ' isEndcardFirstFocus Used to know is this a first shown of the View to handle focus
    m.isEndcardFirstFocus = true

    ' m.time is used internally to update label
    m.time = 0

    if m.LastThemeAttributes <> invalid then
        SGDEX_SetTheme(m.LastThemeAttributes)
        SGDEX_SetBackgroundTheme(m.LastThemeAttributes)
    end if
End Sub


' Starts a timer when m.top.startTimer:boolean field is set
'
' @param event [roSGNodeEvent] - m.top.startTimer field event
Sub OnStartTimerSet(event as Object)
    isStartTimer = event.getData()
    if isStartTimer and m.endcardTimer <> Invalid
        m.endcardTimer.control = "start"
    end if
End Sub


' Updates the label prompt according to time and set public field m.top.timerFired
'
' @param event [roSGNodeEvent] - m.endcardTimer.fire field event
Sub OnEndcardTimerFired(event as Object)
    m.time = m.time - 1
    hasNextItemInPlaylist = m.top.hasNextItemInPlaylist
    timerPrompt = Tr("Next video in: {0}")
    if not hasNextItemInPlaylist
        timerPrompt = Tr("Close screen in: {0}")
    end if
    m.timerLabel.text = Substitute(timerPrompt, m.time.ToStr())

    m.top.timerFired = m.time
End Sub


' Handles what node should be focused at first time
'
' @param event [roSGNodeEvent] - m.top.focusedChild field event
Sub OnFocusedChildChange(event as Object)
    if m.top.IsInFocusChain() and m.FocusableGroup.HasFocus() = false and m.repeatButton.HasFocus() = false and m.grid.HasFocus() = false
        if m.grid.content <> invalid and m.grid.content.GetChildCount() > 0
            m.grid.focusable = true
            m.grid.SetFocus(true)
        else if m.repeatButton.IsInFocusChain() = false
            m.repeatButton.SetFocus(true)
        end if
    end if
End Sub


' Handles user movement to Grid to stop countdown
'
' @param event [roSGNodeEvent] - m.top.rowItemFocused field event
Sub OnEndcardRowItemFocused(event as Object)
    ' If user move on endcard, timer hide and Continuous playback will not start.
    if m.isEndcardFirstFocus ' Flag to differentiate first focus appear from user navigate
        m.isEndcardFirstFocus = false
    else
        m.timerLabel.visible = false
        m.time = m.top.endcardCountdownTime
        m.endcardTimer.control = "stop"
    end if
End Sub


' Handles user movement to "Play again" button to stop countdown
'
' @param event [roSGNodeEvent] - m.top.repeatButtonFocusedEvent field event
Sub OnRepeatButtonFocused()
    if m.isEndcardFirstFocus ' Flag to differentiate first focus appear from user navigate
        m.isEndcardFirstFocus = false
    else if m.grid.content <> invalid and m.grid.content.GetChildCount() > 0
        m.timerLabel.visible = false
        m.time = m.top.endcardCountdownTime
        m.endcardTimer.control = "stop"
    end if
End Sub


' Handles change of m.top.posterShape, pass it to grid
'
' @param event [roSGNodeEvent] - m.top.posterShape field event
Sub OnPosterShape(event as Object)
    posterShape = event.GetData()
    rowHeights = m.grid.rowHeights
    rowHeight = rowHeights[0]
    if rowHeight <> invalid
        m.grid.rowItemSize = [GetRowItemSizeForPosterShape(posterShape, rowHeight)]
    end if
End Sub


' Calculates the size of the poster according to posterShape and rowHeight
'
' @param style [string] - posterShape: possible values "portrait", "4x3", "16x9", "square"
' @param rowHeight [integer] - height of the row
' @param topMargin [integer] - optional margin
'
' @return object [array] - array with 2 values: [width, height] what should be set
Function GetRowItemSizeForPosterShape(style as String, rowHeight as Integer, topMargin = 45 as Integer) as Object
    ' topMargin = 45 ' label height + spacing
    height = rowHeight - topMargin
    styles = {
        "portrait": [Int(height * 3 / 4), height]
        "4x3": [Int(height * 4 / 3), height]
        "16x9": [Int(height * 16 / 9), height]
        "square": [height, height]
    }
    if styles[style] = invalid then style = "16x9"
    return styles[style]
End Function


' Handles set of content node, passes node to grid
'
' @param event [roSGNodeEvent] - m.top.content field event
Sub OnContentChanged(event as Object)
    content = event.GetData()
    m.grid.content = content
End Sub


' Handles countdown time to save locally to update the label
'
' @param event [roSGNodeEvent] - m.top.endcardCountdownTime field event
Sub OnEndcardCountdownTimeChange(event as Object)
    endcardCountdownTime = event.GetData()
    m.time = endcardCountdownTime
End Sub

' ***************
' Themes support
' ***************
Sub SGDEX_SetTheme(theme as Object)
    SGDEX_setThemeFieldstoNode(m, {
        TextColor: {
            repeatButton: [
                "focusedColor"
                "color"
            ]
            grid: [
                "rowLabelColor"
                "itemTextColorLine1"
                "itemTextColorLine2"
            ]
            timerLabel: [
                "color"
            ]
        }

        focusRingColor: {
            repeatButton: ["focusBitmapBlendColor"]
            grid: ["focusBitmapBlendColor"]

        }
    }, theme)

    themeAttributes = {
        ' replay button attributes
        buttonsFocusedColor:            { repeatButton: "focusedColor" }
        buttonsUnFocusedColor:          { repeatButton: "color" }
        buttonsfocusRingColor:          { repeatButton: "focusBitmapBlendColor" }


        ' grid attributes
        rowLabelColor:                  { grid: "rowLabelColor" }
        focusRingColor:                 { grid: "focusBitmapBlendColor" }
        focusFootprintBlendColor:       { grid: "focusFootprintBlendColor" }
        itemTextColorLine1:             { grid: "itemTextColorLine1" }
        itemTextColorLine2:             { grid: "itemTextColorLine2" }

        timerLabelColor:                { timerLabel: "color" }
    }
    SGDEX_setThemeFieldstoNode(m, themeAttributes, theme)
End Sub

Sub SGDEX_SetBackgroundTheme(theme as Object)
    if GetInterface(theme.backgroundImageURI, "ifString") <> invalid then
        ' don't use backgroundColor for blending color as it's used for other Views
        ' so developers don't want it to be applied to this View
        colorTheme = { backgroundImageURI: { backgroundImage: "uri" } }
    else
        colorTheme = { backgroundColor: { topRectangle: "color" } }
    end if
    colorTheme.Append({
        endcardGridBackgroundColor: { bottomRectangle: "color" }
    })

    SGDEX_setThemeFieldstoNode(m, colorTheme, theme)
End Sub

Function SGDEX_GetViewType() as String
    return "videoView"
End Function
