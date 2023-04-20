' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
' inits home screen
' handles key events (when this node is in focus)

Function Init()
    ' see debug output on telnet port 8085
    ? "[HomeScene] Init"

    ' set homeScreen as initial screen
	setupHomeScreen()
End Function 

Function setupHomeScreen()
	' get a node defined in HomeScreen.xml with id="HomeScreen"
    m.homeScreen = m.top.findNode("HomeScreen")
	' the UI only responds to key events in the focused Node
    m.homeScreen.setFocus(true)
End Function

' Main Remote keypress event loop
Function OnKeyEvent(key, press) as Boolean
    ? ">>> HomeScene >> OnkeyEvent"
    result = false
    if press then
        if key = "options"
            ' option key (*) handler
        else if key = "back"
            ' if home screen, exit channel
            if m.homeScreen.visible = true
			    ' return false lets system handle key
				' return true after the channel handled the key
				result = false
            end if

        end if
    end if
    return result
End Function
