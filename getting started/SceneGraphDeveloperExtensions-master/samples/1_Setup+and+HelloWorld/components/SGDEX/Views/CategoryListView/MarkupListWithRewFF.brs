sub Init()
    m.top.ObserveField("focusedChild", "onFocusChange")
end sub

sub onFocusChange()
    m.top.drawFocusFeedback = m.top.IsInFocusChain() or m.top.drawFocusFeedbackIfViewUnfocused
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    if press
        if key = "rewind"
            m.top.isRewPressed = true
            handled = true
        else if key = "fastforward"
            m.top.isFFPressed = true
            handled = true
        end if
    end if
    return handled
end function