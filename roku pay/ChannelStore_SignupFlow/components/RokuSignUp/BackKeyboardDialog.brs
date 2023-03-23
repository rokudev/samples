' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

' Overridden key event handler which captures "back" remote key press 
function onKeyEvent(key as String, bPressed as Boolean) as Boolean
    result = false
    if bPressed AND key = "back" then
        m.top.buttonSelected = -1
        result = true
    end if
    return result
end function