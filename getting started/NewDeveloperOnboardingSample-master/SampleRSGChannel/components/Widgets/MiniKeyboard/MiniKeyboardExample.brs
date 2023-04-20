' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
'
' We will initialize the MiniKeyboard example by centering the example and
' setting up the button so that it will clear the text within the
' MiniKeyboard example
sub init()
    m.miniKeyboard = m.top.findNode("exampleMiniKeyboard")

    m.button = m.top.findNode("clearButton")
    m.button.observeField("buttonSelected", "clearMiniKeyboardText")

    examplerect = m.top.boundingRect()
    centerx = (1280 - examplerect.width) / 2
    centery = (720 - examplerect.height) / 2
    m.top.translation = [ centerx, centery ]
end sub

' When the user selects the button, the MiniKeyboard will clear the text.
sub clearMiniKeyboardText()
    m.miniKeyboard.text = ""
end sub

' This onKeyEvent will handle when the MiniKeyboard component will lose
' focus and give focus to the button node, and vice versa.
function onKeyEvent(key as String, press as Boolean)
    handled = false

    if press
        if key = "down"
            m.button.setFocus(true)
            handled = true
        else if key = "up"
            m.miniKeyboard.setFocus(true)
            handled = true
        end if
    end if

    return handled
end function