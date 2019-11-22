' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 

'Main Video Node Initialization
function init()
    m.video = m.top
    m.video.focusable = true
end function

'Custom Event Key Handling
'@param key [String] case-sensitive key string, that identifies which button was pressed.
'@param press [Boolean] true if the key was pressed, and false if the key was released.
'@return [Boolean] message to the firmware to indicate that a particular event has been handled
function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    'handle back key for video exit
    if (key = "back")
    	m.top.navBack = true
    	handled = true
    endif
    return handled
end function